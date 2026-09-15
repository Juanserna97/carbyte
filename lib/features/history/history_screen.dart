import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  final List<Map<String, dynamic>> _records = const [
    {
      'date': '14 Sep, 2026 • 15:42',
      'vehicle': 'Mercedes-AMG GLA 45',
      'dtcCount': 3,
      'dtcs': ['P0301', 'P0171', 'P0420'],
      'status': 'Atención Requerida',
      'isResolved': false,
    },
    {
      'date': '02 Sep, 2026 • 11:20',
      'vehicle': 'Mercedes-AMG GLA 45',
      'dtcCount': 1,
      'dtcs': ['P0420'],
      'status': 'Resuelto',
      'isResolved': true,
    },
    {
      'date': '18 Ago, 2026 • 09:15',
      'vehicle': 'Mercedes-AMG GLA 45',
      'dtcCount': 0,
      'dtcs': <String>[],
      'status': 'Saludable',
      'isResolved': true,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          s.navHistory,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          itemCount: _records.length,
          itemBuilder: (context, index) {
            final item = _records[index];
            final dtcs = item['dtcs'] as List<String>;
            final isResolved = item['isResolved'] as bool;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.push('/dtc_details'),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['date'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.muted,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isResolved ? AppTheme.success : AppTheme.error)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (isResolved ? AppTheme.success : AppTheme.error)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                item['status'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isResolved ? AppTheme.success : AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['vehicle'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (dtcs.isEmpty)
                              Text(
                                s.noActiveIssues,
                                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.muted),
                              )
                            else
                              Wrap(
                                spacing: 6,
                                children: dtcs
                                    .map(
                                      (code) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.card,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.border),
                                        ),
                                        child: Text(
                                          code,
                                          style: GoogleFonts.sourceCodePro(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.secondary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: AppTheme.muted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
