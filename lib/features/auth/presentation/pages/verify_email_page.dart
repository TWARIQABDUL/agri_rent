import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main_shell/role_home.dart';
import '../bloc/auth_bloc.dart';
import 'splash_page.dart';

/// Hard gate placed between authentication and the shell for accounts that
/// haven't yet verified their email. Google users bypass this because
/// Firebase marks Google-sourced emails as verified on sign-in.
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  static const Color _green = Color(0xFF3D6B34);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _tint = Color(0xFFE8F1E5);
  static const Color _amberBg = Color(0xFFFFF4D6);
  static const Color _amberBorder = Color(0xFFF5C24C);
  static const Color _amberDark = Color(0xFF8A6300);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated && state.user.emailVerified) {
                // Verification just completed — enter the app.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleHome()),
                  (route) => false,
                );
              } else if (state is Unauthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashPage()),
                  (route) => false,
                );
              } else if (state is VerificationEmailSent) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Verification email sent. Check your inbox.',
                      ),
                      backgroundColor: _green,
                    ),
                  );
              } else if (state is Authenticated && !state.user.emailVerified) {
                // Firebase reload finished but the flag is still false.
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text(
                        "We couldn't find a verification yet. "
                        'Click the link in the email, then try again.',
                      ),
                      backgroundColor: Colors.orange.shade700,
                    ),
                  );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
              }
            },
            builder: (context, state) {
              final user = state is Authenticated ? state.user : null;
              final email = user?.email ?? '';
              final busy = state is AuthLoading;
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _hero(),
                      const SizedBox(height: 28),
                      const Text(
                        'Verify your email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _dark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          text: 'We sent a verification link to ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: _muted,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: email,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _dark,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. Tap the link, then come back here and hit '
                                  "\"I've verified\".",
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      _amberInfoBox(),
                      const SizedBox(height: 22),
                      _primaryButton(
                        context,
                        label: "I've verified",
                        icon: Icons.check_circle_outline,
                        busy: busy,
                        onPressed: () => context.read<AuthBloc>().add(
                          const RefreshVerificationStatusRequested(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _secondaryButton(
                        context,
                        label: 'Resend email',
                        icon: Icons.mail_outline,
                        onPressed: busy
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const EmailVerificationResendRequested(),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              context.read<AuthBloc>().add(SignOutRequested()),
                          style: TextButton.styleFrom(foregroundColor: _muted),
                          child: const Text(
                            'Use a different account',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Center(
      child: Container(
        width: 132,
        height: 132,
        decoration: const BoxDecoration(color: _tint, shape: BoxShape.circle),
        child: const Icon(
          Icons.mark_email_read_outlined,
          size: 68,
          color: _green,
        ),
      ),
    );
  }

  Widget _amberInfoBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _amberBg,
        border: Border.all(color: _amberBorder, width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: _amberDark),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Can't find it? Check spam or promotions. Links expire in "
              '1 hour — use Resend to get a new one.',
              style: TextStyle(fontSize: 12.5, color: _amberDark, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool busy,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _green.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _secondaryButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _green,
          side: const BorderSide(color: _green, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
