import '../entities/google_auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// If [presetRole] is provided (Sign-Up page passes the toggle value), a
  /// new Google user is immediately given that role in Firestore. If null and
  /// the user is new, the profile write is deferred so the UI can prompt.
  Future<GoogleAuthResult> signInWithGoogle({String? presetRole});

  /// Completes the Firestore profile write for a Google user who authenticated
  /// but hadn't yet chosen a role.
  Future<User> completeGoogleSignUp(String role);

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Stream<User?> authStateChanges();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<User?> reloadCurrentUser();
}
