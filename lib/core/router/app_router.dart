import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/diagnostics/diagnostics_screen.dart';
import '../../features/live_data/live_data_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/terms_privacy_screen.dart';

import '../../features/obd_connection/connection_screen.dart';
import '../../features/dtc/dtc_details_screen.dart';

final initialRouteProvider = Provider<String>((ref) => '/');

final appRouterProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.watch(initialRouteProvider);
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/connection',
        builder: (context, state) => const ConnectionScreen(),
      ),
      GoRoute(
        path: '/dtc_details',
        builder: (context, state) => const DtcDetailsScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/diagnostics',
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: '/live_data',
        builder: (context, state) => const LiveDataScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/terms_privacy',
        builder: (context, state) => const TermsPrivacyScreen(),
      ),
    ],
  );
});
