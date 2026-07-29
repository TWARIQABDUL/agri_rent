import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/preferences_service.dart';
import '../../domain/entities/google_auth_result.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<GoogleAuthResult> signInWithGoogle({String? presetRole});

  Future<UserModel> completeGoogleSignUp(String role);

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> authStateChanges();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<UserModel?> reloadCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;
  final PreferencesService preferencesService;

  AuthRemoteDataSourceImpl(
    this.firebaseAuth,
    this.googleSignIn,
    this.firestore,
    this.preferencesService,
  );

  /// Mirrors the authenticated user into the `users` collection so Farmers
  /// and Owners actually exist in Firestore, not just as local role prefs.
  ///
  /// The Firestore rules split CREATE (requires role/verified/createdAt) and
  /// UPDATE (rejects any write touching verified/createdAt). Using set(merge)
  /// for both can be classified as UPDATE by the rules evaluator, so we route
  /// explicitly: creates through set() and updates through update().
  Future<void> _upsertUserProfile(fb.User user, {String? role}) async {
    final docRef = firestore.collection('users').doc(user.uid);

    if (role != null) {
      // Sign-up path — write the full profile matching the CREATE rule.
      await docRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'role': role,
        'verified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    // Sign-in refresh path — touch only the keys the UPDATE rule permits.
    // If the profile doc is somehow missing (account created outside this
    // app), fall back to a minimal CREATE with a default role rather than
    // exploding on a permission error.
    try {
      await docRef.update({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        final fallbackRole = await preferencesService.getRole()
            ?? PreferencesService.roleFarmer;
        await docRef.set({
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'role': fallbackRole,
          'verified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        rethrow;
      }
    }
  }

  /// Local `role` prefs are per-device, not per-account — without this, a
  /// device that just signed up as an Owner would keep showing the Owner
  /// dashboard even after logging into a Farmer account on the same phone.
  /// Firestore's `users/{uid}.role` is the source of truth; this pulls it
  /// down into the local cache whenever a specific account signs in.
  Future<void> _syncLocalRoleFromFirestore(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).get();
    final role = snapshot.data()?['role'] as String?;
    debugPrint(
      '[AgriRent][Auth] Firestore role for $uid: $role '
      '(doc exists: ${snapshot.exists})',
    );
    if (role != null) {
      await preferencesService.setRole(role);
      debugPrint('[AgriRent][Auth] local role synced to: $role');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'null-user',
        message: 'Sign-in returned no user.',
      );
    }
    await _upsertUserProfile(user);
    await _syncLocalRoleFromFirestore(user.uid);
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'null-user',
        message: 'Sign-up returned no user.',
      );
    }
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
    final signedUpUser = firebaseAuth.currentUser ?? user;
    final role = await preferencesService.getRole();
    debugPrint(
      '[AgriRent][Auth] signUp: local role read for Firestore write: $role',
    );
    await _upsertUserProfile(signedUpUser, role: role);
    // Fire-and-forget: send verification email so a link is waiting in the
    // user's inbox by the time they land on the app. Failures here shouldn't
    // block sign-up (Firebase throttles resends aggressively).
    try {
      if (!signedUpUser.emailVerified) {
        await signedUpUser.sendEmailVerification();
      }
    } catch (e) {
      debugPrint('[AgriRent][Auth] verification email send failed: $e');
    }
    return UserModel.fromFirebaseUser(signedUpUser);
  }

  @override
  Future<GoogleAuthResult> signInWithGoogle({String? presetRole}) async {
    final googleUser = await googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'null-user',
        message: 'Google sign-in returned no user.',
      );
    }
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (!isNewUser) {
      // Returning Google user — update the existing profile and pull role.
      await _upsertUserProfile(user);
      await _syncLocalRoleFromFirestore(user.uid);
      return GoogleAuthResult(
        user: UserModel.fromFirebaseUser(user),
        isNewUser: false,
        profilePersisted: true,
      );
    }

    if (presetRole != null) {
      // Sign-Up page already knows the role — persist locally + Firestore now.
      await preferencesService.setRole(presetRole);
      await _upsertUserProfile(user, role: presetRole);
      return GoogleAuthResult(
        user: UserModel.fromFirebaseUser(user),
        isNewUser: true,
        profilePersisted: true,
      );
    }

    // Sign-In page path: brand-new Google account with no role picked yet.
    // Defer the Firestore write; the BLoC will emit NeedsRoleForGoogleSignUp
    // so the UI can collect a role, then call completeGoogleSignUp().
    return GoogleAuthResult(
      user: UserModel.fromFirebaseUser(user),
      isNewUser: true,
      profilePersisted: false,
    );
  }

  @override
  Future<UserModel> completeGoogleSignUp(String role) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'no-current-user',
        message: 'Sign in with Google before choosing a role.',
      );
    }
    await preferencesService.setRole(role);
    await _upsertUserProfile(user, role: role);
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    // Only clear the account-scoped pref (role) so the next account starts
    // clean. Language, currency and notification toggles are device-level —
    // they should survive an account switch, otherwise a user who set the
    // app to Kinyarwanda loses it every time they sign out.
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
      preferencesService.clearAccountScoped(),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    await _syncLocalRoleFromFirestore(user.uid);
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw fb.FirebaseAuthException(
        code: 'no-current-user',
        message: 'You must be signed in to verify your email.',
      );
    }
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  @override
  Future<UserModel?> reloadCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    await user.reload();
    final refreshed = firebaseAuth.currentUser;
    if (refreshed == null) return null;

    // If the email link was just clicked, force a fresh ID token so the
    // updated email_verified claim rides along in every subsequent Firestore
    // write. The security rule that lets us auto-promote KYC verified relies
    // on request.auth.token.email_verified being true.
    if (refreshed.emailVerified) {
      await refreshed.getIdToken(true);
      await _promoteKycVerifiedIfNeeded(refreshed.uid);
    }

    return UserModel.fromFirebaseUser(refreshed);
  }

  /// Flip the Firestore `verified` KYC flag to true once the user's email
  /// has been verified. Guarded server-side by a security rule that only
  /// allows this update when the auth token itself confirms email_verified.
  Future<void> _promoteKycVerifiedIfNeeded(String uid) async {
    try {
      final docRef = firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;
      final alreadyVerified = snapshot.data()?['verified'] as bool? ?? false;
      if (alreadyVerified) return;
      await docRef.update({
        'verified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[AgriRent][Auth] KYC verified auto-promoted for $uid');
    } catch (e) {
      debugPrint('[AgriRent][Auth] KYC auto-promotion failed: $e');
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    // Firebase's own auth-state stream fires as soon as sign-in completes
    // internally — often before the explicit signIn/signUp call below has
    // finished its own role sync. Without awaiting the sync here too, a
    // listener elsewhere (e.g. MainShell) can race ahead and read the
    // *previous* account's stale local role when switching accounts on the
    // same device. asyncMap makes this stream itself the guarantee: no
    // event reaches listeners until the role sync for that user is done.
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      await _syncLocalRoleFromFirestore(user.uid);
      return UserModel.fromFirebaseUser(user);
    });
  }
}
