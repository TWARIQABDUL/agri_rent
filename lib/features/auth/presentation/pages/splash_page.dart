import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../injection_container.dart';
import '../../../main_shell/main_shell.dart';
import '../bloc/auth_bloc.dart';
import 'role_selection_page.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const Color _bg = Color(0xFF0D2A13);
  static const Color _accent = Color(0xFFF9A825);
  static const Color _accentLight = Color(0xFFFBC02D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _brand(),
                        const Spacer(flex: 2),
                        _hero(),
                        const SizedBox(height: 32),
                        const Text(
                          'Rent Farm\nEquipment,\nGrow Together!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Connect with nearby owners to rent tractors, pumps, '
                          'and tools — whenever your farm needs them.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                        const Spacer(flex: 1),
                        SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => _startOnboarding(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: GestureDetector(
                            onTap: () => _goToSignIn(context),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Log in',
                                    style: TextStyle(
                                      color: _accentLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          'AgriRent',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    return Center(
      child: SvgPicture.asset(
        'assets/images/tractor.svg',
        width: 300,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.agriculture, size: 120, color: _accent),
        ),
      ),
    );
  }

  Future<void> _startOnboarding(BuildContext context) async {
    final selectedRole = await Navigator.of(context).push<UserRole>(
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
    );
    if (selectedRole == null || !context.mounted) return;

    final role = selectedRole == UserRole.owner
        ? PreferencesService.roleOwner
        : PreferencesService.roleFarmer;
    debugPrint('[AgriRent][Splash] role selected: $role');
    await sl<PreferencesService>().setRole(role);
    if (!context.mounted) return;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpPage()));
  }

  void _goToSignIn(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignInPage()));
  }
}
