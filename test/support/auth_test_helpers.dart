import 'dart:async';

import 'package:agri_rent/features/auth/domain/entities/user.dart';
import 'package:agri_rent/features/auth/domain/entities/google_auth_result.dart';
import 'package:agri_rent/features/auth/domain/repositories/auth_repository.dart';
import 'package:agri_rent/features/auth/domain/usecases/complete_google_sign_up.dart';
import 'package:agri_rent/features/auth/domain/usecases/get_current_user.dart';
import 'package:agri_rent/features/auth/domain/usecases/reload_current_user.dart';
import 'package:agri_rent/features/auth/domain/usecases/send_email_verification.dart';
import 'package:agri_rent/features/auth/domain/usecases/send_password_reset.dart';
import 'package:agri_rent/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:agri_rent/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:agri_rent/features/auth/domain/usecases/sign_out.dart';
import 'package:agri_rent/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';

class FakeAuthRepository implements AuthRepository {
  final authController = StreamController<User?>.broadcast(sync: true);

  User? currentUser;
  Object? error;
  String? submittedEmail;
  String? submittedPassword;
  String? submittedName;
  var googleCalls = 0;
  var signOutCalls = 0;

  @override
  Stream<User?> authStateChanges() => authController.stream;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (error != null) throw error!;
    submittedEmail = email;
    submittedPassword = password;
    return currentUser ??
        User(id: 'user-1', email: email, displayName: 'Jean Bosco');
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (error != null) throw error!;
    submittedEmail = email;
    submittedPassword = password;
    submittedName = displayName;
    return User(id: 'user-1', email: email, displayName: displayName);
  }

  @override
  Future<GoogleAuthResult> signInWithGoogle({String? presetRole}) async {
    if (error != null) throw error!;
    googleCalls++;
    return GoogleAuthResult(
      user:
          currentUser ??
          const User(
            id: 'google-1',
            email: 'google@example.com',
            displayName: 'Google User',
          ),
      isNewUser: false,
      profilePersisted: true,
    );
  }

  @override
  Future<User> completeGoogleSignUp(String role) async {
    if (error != null) throw error!;
    return currentUser ??
        User(
          id: 'google-1',
          email: 'google@example.com',
          displayName: 'Google User',
          role: role,
        );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (error != null) throw error!;
    submittedEmail = email;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (error != null) throw error!;
  }

  @override
  Future<User?> reloadCurrentUser() async {
    if (error != null) throw error!;
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    if (error != null) throw error!;
    signOutCalls++;
  }

  Future<void> close() => authController.close();
}

AuthBloc makeAuthBloc(FakeAuthRepository repository) {
  return AuthBloc(
    SignInWithEmail(repository),
    SignUpWithEmail(repository),
    SignInWithGoogle(repository),
    SignOut(repository),
    GetCurrentUser(repository),
    SendPasswordReset(repository),
    SendEmailVerification(repository),
    ReloadCurrentUser(repository),
    CompleteGoogleSignUp(repository),
    repository,
  );
}

Future<void> authenticate(AuthBloc bloc) async {
  final authenticated = bloc.stream.firstWhere(
    (state) => state is Authenticated,
  );
  bloc.add(CheckAuthStatusEvent());
  await authenticated;
}
