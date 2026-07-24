import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import 'splash_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _greenDark = Color(0xFF1B5E20);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _tint = Color(0xFFE8F1E5);
  static const Color _redTint = Color(0xFFFDECEA);
  static const Color _red = Color(0xFFD32F2F);

  final PreferencesService _prefs = sl<PreferencesService>();

  int _langIndex = 0;
  int _currencyIndex = 0;
  bool _push = true;
  bool _email = true;
  bool _sms = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lang = await _prefs.getLanguage();
    final currency = await _prefs.getCurrency();
    final push = await _prefs.getPushNotifications();
    final email = await _prefs.getEmailNotifications();
    final sms = await _prefs.getSmsNotifications();
    if (!mounted) return;
    setState(() {
      final li = PreferencesService.languages.indexOf(lang);
      if (li != -1) _langIndex = li;
      final ci = PreferencesService.currencies.indexOf(currency);
      if (ci != -1) _currencyIndex = ci;
      _push = push;
      _email = email;
      _sms = sms;
      _loading = false;
    });
  }

  Future<void> _cycleLanguage() async {
    final next = (_langIndex + 1) % PreferencesService.languages.length;
    setState(() => _langIndex = next);
    await _prefs.setLanguage(PreferencesService.languages[next]);
  }

  Future<void> _cycleCurrency() async {
    final next = (_currencyIndex + 1) % PreferencesService.currencies.length;
    setState(() => _currencyIndex = next);
    await _prefs.setCurrency(PreferencesService.currencies[next]);
  }

  Future<void> _setPush(bool v) async {
    setState(() => _push = v);
    await _prefs.setPushNotifications(v);
  }

  Future<void> _setEmail(bool v) async {
    setState(() => _email = v);
    await _prefs.setEmailNotifications(v);
  }

  Future<void> _setSms(bool v) async {
    setState(() => _sms = v);
    await _prefs.setSmsNotifications(v);
  }

  void _comingSoon(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label — coming soon')));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashPage()),
              (route) => false,
            );
          }
        },
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel('Notifications'),
                    _group([
                      _rowToggle(
                        icon: Icons.notifications_outlined,
                        label: 'Push notifications',
                        subtitle: 'Booking & request alerts',
                        value: _push,
                        onChanged: _setPush,
                      ),
                      _rowToggle(
                        icon: Icons.mail_outline,
                        label: 'Email updates',
                        subtitle: 'Receipts & monthly summary',
                        value: _email,
                        onChanged: _setEmail,
                      ),
                      _rowToggle(
                        icon: Icons.chat_bubble_outline,
                        label: 'SMS alerts',
                        subtitle: 'For payments & payouts',
                        value: _sms,
                        onChanged: _setSms,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionLabel('Preferences'),
                    _group([
                      _rowClickable(
                        icon: Icons.language,
                        label: 'Language',
                        value: PreferencesService.languages[_langIndex],
                        onTap: _cycleLanguage,
                      ),
                      _rowClickable(
                        icon: Icons.attach_money,
                        label: 'Currency',
                        value: PreferencesService.currencies[_currencyIndex],
                        onTap: _cycleCurrency,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionLabel('Security'),
                    _group([
                      _rowClickable(
                        icon: Icons.lock_outline,
                        label: 'Change password',
                        onTap: () => _comingSoon('Change password'),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionLabel('About'),
                    _group([
                      _rowClickable(
                        icon: Icons.description_outlined,
                        label: 'Terms & Privacy',
                        onTap: () => _comingSoon('Terms & Privacy'),
                      ),
                      _rowClickable(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () => _comingSoon('Help & Support'),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionLabel('Account'),
                    _group([
                      _rowDanger(
                        icon: Icons.logout,
                        label: 'Log Out',
                        onTap: () =>
                            context.read<AuthBloc>().add(SignOutRequested()),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'AgriRent · Version 1.0.0',
                        style: TextStyle(fontSize: 12, color: _muted),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _muted,
        ),
      ),
    );
  }

  Widget _group(List<Widget> rows) {
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

  Widget _rowIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _tint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: _greenDark, size: 19),
    );
  }

  Widget _rowToggle({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _rowIcon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _green,
          ),
        ],
      ),
    );
  }

  Widget _rowClickable({
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _rowIcon(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _greenDark,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: _muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _rowDanger({
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _redTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _red, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
