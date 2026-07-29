import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../../injection_container.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/pages/verify_email_page.dart';
import '../owner/presentation/pages/owner_shell.dart';
import 'main_shell.dart';

/// Sends a signed-in user to the workspace their saved role belongs to.
///
/// Everything that lands a user in the app after authentication routes here
/// rather than to a shell directly, so switching role from Profile changes
/// where the app opens next time. Unverified email accounts are held here
/// too — they see the verification gate instead of a shell.
class RoleHome extends StatelessWidget {
  const RoleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const _Loader();
        }
        if (!authState.user.emailVerified) {
          return const VerifyEmailPage();
        }
        return FutureBuilder<String?>(
          future: sl<PreferencesService>().getRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _Loader();
            }
            return snapshot.data == PreferencesService.roleOwner
                ? const OwnerShell()
                : const MainShell();
          },
        );
      },
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Center(child: CircularProgressIndicator(color: AppColors.green)),
    );
  }
}
