import 'package:flutter/material.dart';

import '../../core/services/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../../injection_container.dart';
import '../owner/presentation/pages/owner_shell.dart';
import 'main_shell.dart';

/// Sends a signed-in user to the workspace their saved role belongs to.
///
/// Everything that lands a user in the app after authentication routes here
/// rather than to a shell directly, so switching role from Profile changes
/// where the app opens next time.
class RoleHome extends StatelessWidget {
  const RoleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: sl<PreferencesService>().getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }

        return snapshot.data == PreferencesService.roleOwner
            ? const OwnerShell()
            : const MainShell();
      },
    );
  }
}
