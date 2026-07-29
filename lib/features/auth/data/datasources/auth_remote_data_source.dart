import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/preferences_service.dart';
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

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> authStateChanges();
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
  /// Field set here must match the deployed Firestore security rules
  /// exactly: create requires `verified == false` and `createdAt ==
  /// request.time`; update only allows changes to a fixed key set that does
  /// not include `photoUrl` (that stays local, sourced from Firebase Auth).
  Future<void> _upsertUserProfile(fb.User user, {String? role}) async {
    final data = <String, dynamic>{
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (role != null) {
      data['role'] = role;
      data['verified'] = false;
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
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
    return UserModel.fromFirebaseUser(signedUpUser);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
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
    final role = isNewUser ? await preferencesService.getRole() : null;
    await _upsertUserProfile(user, role: role);
    if (!isNewUser) {
      await _syncLocalRoleFromFirestore(user.uid);
    }
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    await _syncLocalRoleFromFirestore(user.uid);
    return UserModel.fromFirebaseUser(user);
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
