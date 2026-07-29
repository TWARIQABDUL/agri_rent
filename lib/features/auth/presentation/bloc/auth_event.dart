part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignInWithGoogleRequested extends AuthEvent {
  final String? presetRole;

  const SignInWithGoogleRequested({this.presetRole});

  @override
  List<Object?> get props => [presetRole];
}

class CompleteGoogleSignUpRequested extends AuthEvent {
  final String role;

  const CompleteGoogleSignUpRequested(this.role);

  @override
  List<Object?> get props => [role];
}

class SignOutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class EmailVerificationResendRequested extends AuthEvent {
  const EmailVerificationResendRequested();
}

class RefreshVerificationStatusRequested extends AuthEvent {
  const RefreshVerificationStatusRequested();
}

class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
