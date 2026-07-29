import 'package:agri_rent/core/services/preferences_service.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agri_rent/features/auth/presentation/pages/sign_up_page.dart';
import 'package:agri_rent/features/auth/presentation/pages/splash_page.dart';
import 'package:agri_rent/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/auth_test_helpers.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthBloc authBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    sl.registerSingleton<PreferencesService>(PreferencesService());
    repository = FakeAuthRepository();
    authBloc = makeAuthBloc(repository);
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

  testWidgets('Splash opens sign up with the farmer role selected', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SplashPage()));
    final unauthenticated = authBloc.stream.firstWhere(
      (state) => state is Unauthenticated,
    );
    authBloc.add(CheckAuthStatusEvent());
    await tester.runAsync(() => unauthenticated);
    await tester.pump();

    expect(find.text('Rent Farm\nEquipment,\nGrow Together!'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Already have an account?'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Get Started'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Farmer'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Sign Up'), findsWidgets);
  });

  testWidgets('Sign Up validates fields and terms', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1300));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SignUpPage()));
    await tester.pump();

    expect(find.text('Welcome to AgriRent,'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alice Farmer');
    await tester.enterText(fields.at(1), 'alice@example.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Please accept the Terms to continue'), findsOneWidget);
  });
}
