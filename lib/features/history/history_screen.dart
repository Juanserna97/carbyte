import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref, dynamic s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 26),
            const SizedBox(width: 10),
            Text(
              s.clearHistoryConfirmTitle,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
              ),
            ),
          ],
        ),
        content: Text(
          s.clearHistoryConfirmDesc,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppTheme.muted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              s.cancel,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(historyProvider.notifier).clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.historyClearedSnack),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: Text(
              s.clearHistoryBtn,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final records = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          s.navHistory,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          if (records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
              tooltip: s.clearHistoryTooltip,
              onPressed: () => _showClearHistoryDialog(context, ref, s),
            ),
        ],
      ),
      body: SafeArea(
        child: records.isEmpty
            ? _buildEmptyState(context, s)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final item = records[index];
                  final id = (item['id'] ?? index.toString()) as String;
                  final dtcs = (item['dtcs'] as List<dynamic>?)?.cast<String>() ?? [];
                  final isResolved = (item['isResolved'] as bool?) ?? false;
                  final statusType = (item['statusType'] as String?) ?? 'attention';

                  String statusLabel;
                  if (statusType == 'resolved') {
                    statusLabel = s.historyStatusResolved;
                  } else if (statusType == 'healthy') {
                    statusLabel = s.historyStatusHealthy;
                  } else {
                    statusLabel = s.historyStatusAttention;
                  }

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
                                    (item['date'] ?? '') as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.muted,
                                    ),
                                  ),
                                  Row(
                                    children: [
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
                                          statusLabel,
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: isResolved ? AppTheme.success : AppTheme.error,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.muted),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          await ref.read(historyProvider.notifier).deleteRecord(id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(s.historyRecordDeletedSnack),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (item['vehicle'] ?? '') as String,
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

  Widget _buildEmptyState(BuildContext context, dynamic s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                size: 48,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.emptyHistoryTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.emptyHistoryDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.push('/diagnostics'),
              icon: const Icon(Icons.document_scanner_rounded, size: 18),
              label: Text(
                s.btnScanVehicle,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
