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

  Future<User> signInWithGoogle();

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Stream<User?> authStateChanges();
}
