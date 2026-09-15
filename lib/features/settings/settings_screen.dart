import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/obd_providers.dart';
import '../../core/providers/vehicle_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _metricUnits = true;
  bool _fastPolling = true;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final isMockMode = ref.watch(mockModeProvider);
    final currentLang = ref.watch(languageProvider);
    final activeLang = ref.watch(activeLanguageProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          s.settingsTitle,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Vehicle & Profile Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car_filled_rounded, color: AppTheme.secondary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(vehicleProvider).vehicleName,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.vehicleProfile,
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_rounded, color: AppTheme.secondary, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(s.systemPreferences),
            _buildNavTile(
              title: s.languageOption,
              subtitle: '${currentLang.displayNameIn(activeLang)}${currentLang == AppLanguage.auto ? " (${activeLang.displayName})" : ""}',
              icon: Icons.language_rounded,
              onTap: () => _showLanguageSelector(context, currentLang),
            ),
            _buildSwitchTile(
              title: s.metricUnits,
              subtitle: _metricUnits ? 'km/h, °C, bar, kPa' : 'mph, °F, psi',
              icon: Icons.straighten_rounded,
              value: _metricUnits,
              onChanged: (val) => setState(() => _metricUnits = val),
            ),
            _buildSwitchTile(
              title: s.mockMode,
              subtitle: s.mockModeSubtitle,
              icon: Icons.science_outlined,
              value: isMockMode,
              onChanged: (val) => ref.read(mockModeProvider.notifier).state = val,
            ),
            _buildSwitchTile(
              title: s.fastPolling,
              subtitle: s.fastPollingSubtitle,
              icon: Icons.bolt_rounded,
              value: _fastPolling,
              onChanged: (val) => setState(() => _fastPolling = val),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(s.hardwareCommunication),
            _buildNavTile(
              title: s.savedAdapters,
              subtitle: 'CARBYTE Simulator Link',
              icon: Icons.bluetooth_connected_rounded,
              onTap: () => context.push('/connection'),
            ),
            _buildNavTile(
              title: s.diagnosticProtocol,
              subtitle: 'Automático (ISO 15765-4 CAN 11-bit / 500k)',
              icon: Icons.cable_rounded,
              onTap: () {},
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(s.information),
            _buildNavTile(
              title: s.aboutCarbyte,
              subtitle: 'Versión 1.0.0 (Build 2026.09)',
              icon: Icons.info_outline_rounded,
              onTap: () {},
            ),
            _buildNavTile(
              title: s.termsPrivacy,
              subtitle: 'Seguridad y protección de datos vehiculares',
              icon: Icons.shield_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppTheme.muted,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppTheme.secondary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.muted, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, AppLanguage currentLang) {
    final s = ref.read(stringsProvider);
    final activeLang = ref.read(activeLanguageProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.border),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.muted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.selectLanguageTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...AppLanguage.values.map((lang) {
                  final isSelected = currentLang == lang;
                  String title = lang.displayNameIn(activeLang);
                  String? subtitle;
                  if (lang == AppLanguage.auto) {
                    subtitle = activeLang == AppLanguage.es ? 'Detectado: Español' : 'Detected: English';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.secondary : AppTheme.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      title: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppTheme.secondary : AppTheme.text,
                        ),
                      ),
                      subtitle: subtitle != null
                          ? Text(
                              subtitle,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.muted,
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 22)
                          : null,
                      onTap: () {
                        ref.read(languageProvider.notifier).setLanguage(lang);
                        Navigator.pop(modalContext);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
