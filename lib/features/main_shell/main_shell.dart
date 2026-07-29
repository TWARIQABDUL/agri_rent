import 'package:flutter/material.dart';

import '../../core/services/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../../injection_container.dart';
import '../auth/presentation/pages/profile_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../home/presentation/widgets/custom_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await sl<PreferencesService>().getRole();
    debugPrint('[AgriRent][MainShell] local role read: $role');
    if (!mounted) return;
    setState(() => _role = role);
  }

  List<Widget> _pagesFor(String? role) {
    final isOwner = role == PreferencesService.roleOwner;
    return [
      isOwner
          ? const _ComingSoon(title: 'Owner Dashboard')
          : const HomePage(),
      _ComingSoon(title: isOwner ? 'Rental Requests' : 'My Bookings'),
      const _ComingSoon(title: 'Wallet'),
      const _ComingSoon(title: 'Favorites'),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _tab, children: _pagesFor(_role)),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;

  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Text(
            'Coming soon',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
