import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';

class TermsPrivacyScreen extends ConsumerWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          s.termsTitle,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGlowGradient,
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppTheme.secondary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARBYTE LEGAL & PRIVACY',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.termsPrivacySubtitle,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: Driving Safety
              _buildSectionCard(
                icon: LucideIcons.alertTriangle,
                iconColor: AppTheme.warning,
                title: s.termsSection1Title,
                content: s.termsSection1Desc,
              ),

              const SizedBox(height: 16),

              // Section 2: Hardware & OBD Port
              _buildSectionCard(
                icon: LucideIcons.cpu,
                iconColor: AppTheme.secondary,
                title: s.termsSection2Title,
                content: s.termsSection2Desc,
              ),

              const SizedBox(height: 16),

              // Section 3: Data Privacy
              _buildSectionCard(
                icon: LucideIcons.lock,
                iconColor: AppTheme.success,
                title: s.termsSection3Title,
                content: s.termsSection3Desc,
              ),

              const SizedBox(height: 16),

              // Section 4: Mechanical Disclaimer
              _buildSectionCard(
                icon: LucideIcons.wrench,
                iconColor: AppTheme.primary,
                title: s.termsSection4Title,
                content: s.termsSection4Desc,
              ),

              const SizedBox(height: 32),

              // Understood Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    s.understoodBtn,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
