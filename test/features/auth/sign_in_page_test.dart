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
import 'package:agri_rent/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopAuthRepository implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<GoogleAuthResult> signInWithGoogle({String? presetRole}) =>
      throw UnimplementedError();

  @override
  Future<User> completeGoogleSignUp(String role) => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<User?> reloadCurrentUser() async => null;
}

void main() {
  late AuthBloc bloc;
  late _NoopAuthRepository repo;

  setUp(() {
    repo = _NoopAuthRepository();
    bloc = AuthBloc(
      SignInWithEmail(repo),
      SignUpWithEmail(repo),
      SignInWithGoogle(repo),
      SignOut(repo),
      GetCurrentUser(repo),
      SendPasswordReset(repo),
      SendEmailVerification(repo),
      ReloadCurrentUser(repo),
      CompleteGoogleSignUp(repo),
      repo,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  Widget makeTestable() => MaterialApp(
    home: BlocProvider<AuthBloc>.value(value: bloc, child: const SignInPage()),
  );

  group('SignInPage', () {
    testWidgets('renders the expected layout elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('AgriRent'), findsOneWidget);
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('Sign in to continue.'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('or continue with'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Sign Up'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows required-field errors when submitting empty form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows email format error for invalid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'not-an-email');
      await tester.enterText(fields.at(1), 'validpass');
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('shows password length error for short password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'jane@example.com');
      await tester.enterText(fields.at(1), '123');
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      expect(find.text('Enter a valid email address'), findsNothing);
    });
  });
}
