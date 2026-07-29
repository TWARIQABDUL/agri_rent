import 'package:agri_rent/core/services/preferences_service.dart';
import 'package:agri_rent/features/auth/domain/entities/user.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agri_rent/features/auth/presentation/pages/personal_details_page.dart';
import 'package:agri_rent/features/auth/presentation/pages/profile_page.dart';
import 'package:agri_rent/features/auth/presentation/pages/settings_page.dart';
import 'package:agri_rent/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/auth_test_helpers.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthBloc authBloc;
  late PreferencesService preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'pref_role': PreferencesService.roleFarmer,
      'pref_language': 'English',
      'pref_currency': 'RWF',
    });
    await sl.reset();
    preferences = PreferencesService();
    sl.registerSingleton<PreferencesService>(preferences);
    repository = FakeAuthRepository()
      ..currentUser = const User(
        id: 'farmer-1',
        email: 'jean@example.com',
        displayName: 'Jean Bosco',
      );
    authBloc = makeAuthBloc(repository);
    await authenticate(authBloc);
  });

  tearDown(() async {
    await authBloc.close();
    await repository.close();
    await sl.reset();
  });

  Widget app(Widget page) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(home: page),
    );
  }

  testWidgets('Profile renders user data and switches role', (tester) async {
    String? changedRole;
    await tester.pumpWidget(
      app(ProfilePage(onRoleChanged: (role) => changedRole = role)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Jean Bosco'), findsOneWidget);
    expect(find.text('jean@example.com'), findsOneWidget);
    expect(find.text('Currently browsing as Farmer'), findsOneWidget);
    expect(find.text('Switch Role'), findsOneWidget);

    await tester.tap(find.text('Switch Role'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Your Role'), findsOneWidget);

    await tester.tap(find.text('Owner'));
    await tester.pump();
    await tester.tap(find.text('Continue as Owner'));
    await tester.pumpAndSettle();

    expect(changedRole, PreferencesService.roleOwner);
    expect(await preferences.getRole(), PreferencesService.roleOwner);
  });

  testWidgets('Personal Details pre-fills, validates, and saves', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const PersonalDetailsPage()));
    await tester.pump();

    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.text('Identity Verification (KYC)'), findsOneWidget);
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller?.text,
      'Jean Bosco',
    );

    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    expect(find.text('Changes saved'), findsOneWidget);

    await tester.enterText(fields.at(0), '');
    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    expect(find.text('Full name is required'), findsOneWidget);
  });

  testWidgets('Settings restores and updates notification preferences', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SettingsPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Push notifications'), findsOneWidget);
    expect(find.text('Email updates'), findsOneWidget);
    expect(find.text('SMS alerts'), findsOneWidget);
    expect(find.text('AgriRent · Version 1.0.0'), findsOneWidget);

    final switches = find.byType(Switch);
    await tester.tap(switches.at(0));
    await tester.tap(switches.at(2));
    await tester.pump();
    expect(await preferences.getPushNotifications(), isFalse);
    expect(await preferences.getSmsNotifications(), isTrue);
  });

  testWidgets('Settings language and currency pickers persist choices', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SettingsPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kinyarwanda'));
    await tester.pumpAndSettle();
    expect(await preferences.getLanguage(), 'Kinyarwanda');

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD'));
    await tester.pumpAndSettle();
    expect(await preferences.getCurrency(), 'USD');

    await tester.tap(find.text('Terms & Privacy'));
    await tester.pump();
    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
