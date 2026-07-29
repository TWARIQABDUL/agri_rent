import 'package:agri_rent/core/services/preferences_service.dart';
import 'package:agri_rent/features/auth/domain/entities/user.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/auth_test_helpers.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService preferences;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      preferences = PreferencesService();
    });

    test('provides defaults and persists all supported preferences', () async {
      expect(await preferences.getRole(), PreferencesService.roleFarmer);
      expect(await preferences.getLanguage(), 'English');
      expect(await preferences.getCurrency(), 'RWF');
      expect(await preferences.getPushNotifications(), isTrue);
      expect(await preferences.getEmailNotifications(), isTrue);
      expect(await preferences.getSmsNotifications(), isFalse);

      await preferences.setRole(PreferencesService.roleOwner);
      await preferences.setLanguage('Kinyarwanda');
      await preferences.setCurrency('USD');
      await preferences.setPushNotifications(false);
      await preferences.setEmailNotifications(false);
      await preferences.setSmsNotifications(true);

      expect(await preferences.getRole(), PreferencesService.roleOwner);
      expect(await preferences.getLanguage(), 'Kinyarwanda');
      expect(await preferences.getCurrency(), 'USD');
      expect(await preferences.getPushNotifications(), isFalse);
      expect(await preferences.getEmailNotifications(), isFalse);
      expect(await preferences.getSmsNotifications(), isTrue);

      await preferences.clear();
      expect(await preferences.getRole(), PreferencesService.roleFarmer);
      expect(await preferences.getLanguage(), 'English');
      expect(await preferences.getCurrency(), 'RWF');
    });
  });

  group('AuthBloc', () {
    late FakeAuthRepository repository;
    late AuthBloc bloc;

    setUp(() {
      repository = FakeAuthRepository();
      bloc = makeAuthBloc(repository);
    });

    tearDown(() async {
      await bloc.close();
      await repository.close();
    });

    test('checks authenticated and unauthenticated status', () async {
      repository.currentUser = const User(
        id: 'user-1',
        email: 'jean@example.com',
      );
      final authenticated = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<Authenticated>()]),
      );
      bloc.add(CheckAuthStatusEvent());
      await authenticated;

      repository.currentUser = null;
      final unauthenticated = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<Unauthenticated>()]),
      );
      bloc.add(CheckAuthStatusEvent());
      await unauthenticated;
    });

    test('signs in, signs up, uses Google, and signs out', () async {
      bloc.add(
        const SignInWithEmailRequested(
          email: 'jean@example.com',
          password: 'secret1',
        ),
      );
      await bloc.stream.firstWhere((state) => state is Authenticated);
      expect(repository.submittedEmail, 'jean@example.com');

      bloc.add(
        const SignUpWithEmailRequested(
          email: 'alice@example.com',
          password: 'secret2',
          displayName: 'Alice',
        ),
      );
      await bloc.stream.firstWhere(
        (state) =>
            state is Authenticated && state.user.email == 'alice@example.com',
      );
      expect(repository.submittedName, 'Alice');

      bloc.add(SignInWithGoogleRequested());
      await bloc.stream.firstWhere(
        (state) =>
            state is Authenticated && state.user.email == 'google@example.com',
      );
      expect(repository.googleCalls, 1);

      bloc.add(SignOutRequested());
      await bloc.stream.firstWhere((state) => state is Unauthenticated);
      expect(repository.signOutCalls, 1);
    });

    test('maps common Firebase errors to friendly messages', () async {
      repository.error = firebase.FirebaseAuthException(
        code: 'invalid-credential',
      );
      bloc.add(
        const SignInWithEmailRequested(
          email: 'jean@example.com',
          password: 'wrong',
        ),
      );
      final state = await bloc.stream.firstWhere((state) => state is AuthError);
      expect((state as AuthError).message, contains('Incorrect email'));

      repository.error = firebase.FirebaseAuthException(
        code: 'network-request-failed',
      );
      bloc.add(SignInWithGoogleRequested());
      final networkState = await bloc.stream.firstWhere(
        (state) => state is AuthError && state.message.contains('Network'),
      );
      expect((networkState as AuthError).message, contains('connection'));
    });

    test('reacts to repository auth-state changes', () async {
      const user = User(id: 'stream-user', email: 'stream@example.com');
      repository.authController.add(user);
      final signedIn = await bloc.stream.firstWhere(
        (state) => state is Authenticated,
      );
      expect((signedIn as Authenticated).user, user);

      repository.authController.add(null);
      expect(
        await bloc.stream.firstWhere((state) => state is Unauthenticated),
        isA<Unauthenticated>(),
      );
    });
  });
}
