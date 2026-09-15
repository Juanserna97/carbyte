import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({bool toConnection = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;

    if (context.canPop()) {
      context.pop();
    } else {
      if (toConnection) {
        context.go('/connection');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    final List<Map<String, dynamic>> pages = [
      {
        'badge': s.onboardingBadge1,
        'title': s.onboardingTitle1,
        'description': s.onboardingDesc1,
        'tip': s.onboardingTip1,
        'icon': LucideIcons.search,
        'graphic': _buildPortGraphic(s.onboardingDlc),
      },
      {
        'badge': s.onboardingBadge2,
        'title': s.onboardingTitle2,
        'description': s.onboardingDesc2,
        'tip': s.onboardingTip2,
        'icon': LucideIcons.plug,
        'graphic': _buildDongleGraphic(s.onboardingPwrLed),
      },
      {
        'badge': s.onboardingBadge3,
        'title': s.onboardingTitle3,
        'description': s.onboardingDesc3,
        'tip': s.onboardingTip3,
        'icon': LucideIcons.power,
        'graphic': _buildIgnitionGraphic(s.onboardingIgnitionOn),
      },
      {
        'badge': s.onboardingBadge4,
        'title': s.onboardingTitle4,
        'description': s.onboardingDesc4,
        'tip': s.onboardingTip4,
        'icon': Icons.bluetooth_connected_rounded,
        'graphic': _buildBluetoothGraphic(s.onboardingReadyToPair),
      },
    ];

    final totalPages = pages.length;
    final isLastPage = _currentPage == totalPages - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button or placeholder
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.text, size: 20),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 44),

                  // Step indicator pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      '${s.stepText} ${_currentPage + 1} / $totalPages',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),

                  // Skip button
                  TextButton(
                    onPressed: () => _completeOnboarding(toConnection: false),
                    child: Text(
                      s.skipBtn,
                      style: GoogleFonts.outfit(
                        color: AppTheme.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / totalPages,
                  backgroundColor: AppTheme.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                  minHeight: 3,
                ),
              ),
            ),

            // Main Swiper
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Technical Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            page['badge'],
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Visual Interactive Graphic
                        page['graphic'] as Widget,

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          page['description'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.muted,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Pro Tip Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.secondary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  page['tip'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.text,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalPages,
                      (index) => InkWell(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 28 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppTheme.secondary : AppTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main Button
                  if (isLastPage) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _completeOnboarding(toConnection: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bluetooth_searching_rounded, size: 20, color: AppTheme.background),
                            const SizedBox(width: 8),
                            Text(
                              s.connectScannerNow,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppTheme.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _completeOnboarding(toConnection: false),
                      child: Text(
                        s.exploreAppFirst,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.muted,
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.nextBtn,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Visual Step Graphics ---

  Widget _buildPortGraphic(String label) {
    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.gauge, size: 48, color: AppTheme.secondary),
          const SizedBox(height: 14),
          // 16-pin connector representation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                8,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Container(
                    width: 4,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.sourceCodePro(fontSize: 10, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildDongleGraphic(String label) {
    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.secondary),
                ),
                child: const Icon(LucideIcons.plug, size: 36, color: AppTheme.secondary),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.success.withValues(alpha: 0.8), blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.sourceCodePro(fontSize: 10, color: AppTheme.success, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIgnitionGraphic(String label) {
    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.background,
              border: Border.all(color: AppTheme.secondary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ENGINE',
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.muted),
                  ),
                  Text(
                    'START',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.secondary),
                  ),
                  Text(
                    'STOP',
                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: GoogleFonts.sourceCodePro(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothGraphic(String label) {
    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                ),
              ),
              const Icon(Icons.bluetooth_searching_rounded, size: 40, color: AppTheme.secondary),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.success),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
