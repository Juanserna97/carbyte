import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Map<String, dynamic>>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  static const String _storageKey = 'carbyte_diagnostic_history';

  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(jsonStr);
        state = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        return;
      } catch (_) {}
    }

    // Default seed records for initial demonstration
    state = [
      {
        'id': 'rec-1',
        'date': '14 Sep, 2026 • 15:42',
        'vehicle': 'Mercedes-AMG GLA 45',
        'dtcCount': 3,
        'dtcs': ['P0301', 'P0171', 'P0420'],
        'statusType': 'attention',
        'isResolved': false,
      },
      {
        'id': 'rec-2',
        'date': '02 Sep, 2026 • 11:20',
        'vehicle': 'Mercedes-AMG GLA 45',
        'dtcCount': 1,
        'dtcs': ['P0420'],
        'statusType': 'resolved',
        'isResolved': true,
      },
      {
        'id': 'rec-3',
        'date': '18 Ago, 2026 • 09:15',
        'vehicle': 'Mercedes-AMG GLA 45',
        'dtcCount': 0,
        'dtcs': <String>[],
        'statusType': 'healthy',
        'isResolved': true,
      },
    ];
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> deleteRecord(String id) async {
    state = state.where((item) => item['id'] != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state));
  }

  Future<void> addRecord(Map<String, dynamic> record) async {
    state = [record, ...state];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state));
  }
}
