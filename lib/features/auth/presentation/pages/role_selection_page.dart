import 'package:flutter/material.dart';

enum UserRole { farmer, owner }

class RoleSelectionPage extends StatefulWidget {
  final UserRole? currentRole;

  const RoleSelectionPage({super.key, this.currentRole});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _greenDark = Color(0xFF1B5E20);
  static const Color _greenTint = Color(0xFFE8F1E5);
  static const Color _amberTint = Color(0xFFFEF3D6);
  static const Color _amberIcon = Color(0xFF9A7400);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _dark = Color(0xFF1A1A1A);

  late UserRole _selected = widget.currentRole ?? UserRole.farmer;

  @override
  Widget build(BuildContext context) {
    final ctaLabel =
        _selected == UserRole.farmer ? 'Continue as Farmer' : 'Continue as Owner';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _dark,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Choose Your Role',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Choose how you want to use AgriRent. You can switch '
                      'back anytime from your profile.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _roleCard(
                      role: UserRole.farmer,
                      title: 'Farmer',
                      subtitle: 'Rent equipment',
                      iconBg: _greenTint,
                      iconColor: _greenDark,
                      icon: Icons.agriculture,
                      description:
                          'Browse and book tractors, pumps, sprayers and '
                          'more from owners near you.',
                      features: const [
                        'Search & filter nearby equipment',
                        'Track bookings & leave reviews',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _roleCard(
                      role: UserRole.owner,
                      title: 'Owner',
                      subtitle: 'List & earn',
                      iconBg: _amberTint,
                      iconColor: _amberIcon,
                      icon: Icons.home_work_outlined,
                      description:
                          'List your equipment, manage rental requests and '
                          'earn income from idle machines.',
                      features: const [
                        'Add listings & set your own rates',
                        'Accept requests & track earnings',
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _footer(ctaLabel),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String description,
    required List<String> features,
  }) {
    final selected = _selected == role;
    final isCurrent = widget.currentRole == role;

    return InkWell(
      onTap: () => setState(() => _selected = role),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? _greenTint : Colors.white,
          border: Border.all(
            color: selected ? _green : _border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _green,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'Current',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _checkMark(selected),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: _dark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 9),
            ...features.map(_featureRow),
          ],
        ),
      ),
    );
  }

  Widget _checkMark(bool selected) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: selected ? _green : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _green : _border,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 15)
          : null,
    );
  }

  Widget _featureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check, color: _green, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(String label) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
