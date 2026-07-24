import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final AuthRepository authRepository;

  StreamSubscription<User?>? _authSubscription;

  AuthBloc(
    this.signInWithEmail,
    this.signUpWithEmail,
    this.signInWithGoogle,
    this.signOut,
    this.getCurrentUser,
    this.authRepository,
  ) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignOutRequested>(_onSignOut);
    on<AuthStateChanged>(_onAuthStateChanged);

    _authSubscription = authRepository.authStateChanges().listen(
      (user) => add(AuthStateChanged(user)),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await getCurrentUser(NoParams());
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInWithEmail(
        SignInWithEmailParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUpWithEmail(
        SignUpWithEmailParams(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
        ),
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogle(NoParams());
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signOut(NoParams());
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  String _friendlyError(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google sign-in was canceled.';
        case GoogleSignInExceptionCode.interrupted:
          return 'Google sign-in was interrupted. Please try again.';
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          return 'Google sign-in is not configured. '
              'Check Firebase setup (SHA-1 and Google provider).';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google sign-in UI could not be shown.';
        case GoogleSignInExceptionCode.userMismatch:
          return 'The signed-in account does not match. Try again.';
        case GoogleSignInExceptionCode.unknownError:
          return 'Google sign-in failed. Please try again.';
      }
    }
    if (error is fb.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Incorrect email or password. Please try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'account-exists-with-different-credential':
          return 'This email is already used with a different sign-in method.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
