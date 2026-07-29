import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../injection_container.dart';
import '../../../main_shell/role_home.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import 'personal_details_page.dart';
import 'role_selection_page.dart';
import 'settings_page.dart';
import 'splash_page.dart';

class ProfilePage extends StatefulWidget {
  final ValueChanged<String>? onRoleChanged;

  const ProfilePage({super.key, this.onRoleChanged});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _greenDark = Color(0xFF1B5E20);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _tint = Color(0xFFE8F1E5);
  static const Color _redTint = Color(0xFFFDECEA);
  static const Color _red = Color(0xFFD32F2F);

  final PreferencesService _prefs = sl<PreferencesService>();

  String _roleLabel = 'Farmer';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _prefs.getRole();
    debugPrint('[AgriRent][ProfilePage] local role read: $role');
    if (!mounted) return;
    setState(() {
      _roleLabel = role == PreferencesService.roleOwner ? 'Owner' : 'Farmer';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _dark,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: _openSettings,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(color: _border, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: _dark,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashPage()),
              (route) => false,
            );
          } else if (state is VerificationEmailSent) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Verification email sent. Check your inbox.'),
                  backgroundColor: _green,
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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileCard(user),
                  if (user != null && !user.emailVerified) ...[
                    const SizedBox(height: 14),
                    _verifyEmailBanner(context),
                  ],
                  const SizedBox(height: 18),
                  _statsRow(),
                  const SizedBox(height: 24),
                  _menuGroup([
                    _menuRow(
                      icon: Icons.person_outline,
                      label: 'Personal Details',
                      subtitle: 'Edit info & verification (KYC)',
                      onTap: _openPersonalDetails,
                    ),
                    _menuRow(
                      icon: Icons.swap_horiz,
                      label: 'Switch Role',
                      subtitle: 'Currently browsing as $_roleLabel',
                      onTap: _switchRole,
                    ),
                    _menuRow(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      subtitle: 'Notifications, language & security',
                      onTap: _openSettings,
                    ),
                    _dangerRow(
                      icon: Icons.logout,
                      label: 'Log Out',
                      onTap: () =>
                          context.read<AuthBloc>().add(SignOutRequested()),
                    ),
                  ]),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  void _openPersonalDetails() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PersonalDetailsPage()));
  }

  /// Rebuilding from [RoleHome] rather than popping, because the two roles run
  /// different shells with different tabs.
  Future<void> _switchRole() async {
    final current = _roleLabel == 'Owner' ? UserRole.owner : UserRole.farmer;
    final chosen = await Navigator.of(context).push<UserRole>(
      MaterialPageRoute(
        builder: (_) => RoleSelectionPage(currentRole: current),
      ),
    );
    if (chosen == null || chosen == current || !mounted) return;

    final role = chosen == UserRole.owner
        ? PreferencesService.roleOwner
        : PreferencesService.roleFarmer;
    await _prefs.setRole(role);
    if (!mounted) return;

    widget.onRoleChanged?.call(role);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleHome()),
      (route) => false,
    );
  }

  Widget _verifyEmailBanner(BuildContext context) {
    const amberBg = Color(0xFFFFF4D6);
    const amberBorder = Color(0xFFF5C24C);
    const amberDark = Color(0xFF8A6300);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: amberBg,
        border: Border.all(color: amberBorder, width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                color: amberDark,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verify your email',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: amberDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'We sent a link to your inbox. Verify to unlock all AgriRent '
            'features and secure your account.',
            style: TextStyle(fontSize: 12.5, color: amberDark, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => context.read<AuthBloc>().add(
                  const EmailVerificationResendRequested(),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: amberDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text(
                  'Resend',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => context.read<AuthBloc>().add(
                  const RefreshVerificationStatusRequested(),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: amberDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  "I've verified",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileCard(User? user) {
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : (user?.email.split('@').first ?? 'Guest');
    final email = user?.email ?? '';
    final initials = _initialsFrom(name);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(color: _tint, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: _greenDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(fontSize: 13.5, color: _muted),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _tint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.layers, size: 13, color: _greenDark),
                    const SizedBox(width: 5),
                    Text(
                      '$_roleLabel · Musanze',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _greenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _statCell('8', 'Rentals'),
          _statDivider(),
          _statCell('4.8', 'Rating'),
          _statDivider(),
          _statCell('2024', 'Member'),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 40, color: _border);

  Widget _statCell(String n, String t) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              n,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
            const SizedBox(height: 3),
            Text(t, style: const TextStyle(fontSize: 12, color: _muted)),
          ],
        ),
      ),
    );
  }

  Widget _menuGroup(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(const Divider(height: 1, color: _border));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _tint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: _greenDark, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12.5, color: _muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _muted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _dangerRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _redTint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: _red, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initialsFrom(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
