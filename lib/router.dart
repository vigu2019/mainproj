import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/landing_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/image_detection_screen.dart';
import 'screens/video_detection_screen.dart';
import 'screens/result_screen.dart';
import 'screens/video_result_screen.dart';
import 'screens/compare_result_screen.dart';
import 'screens/admin_screen.dart';
import 'widgets/dashboard_layout.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/intro',
  routes: [
    GoRoute(
      path: '/intro',
      builder: (context, state) => const LandingScreen(),
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return DashboardLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) => const IntroScreen(), // Renamed internally to Home
        ),
        GoRoute(
          path: '/image',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) => const ImageUploadScreen(),
        ),
        GoRoute(
          path: '/video',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) => const VideoDetectionScreen(),
        ),
        GoRoute(
          path: '/result',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) => const ResultScreen(),
        ),
        GoRoute(
          path: '/video-result',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final videoUrl = extra['video_url'] ?? '';
            final events = extra['events'] as List<dynamic>? ?? [];
            return VideoResultScreen(videoUrl: videoUrl, events: events);
          },
        ),
        GoRoute(
          path: '/compare-result',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) => const CompareResultScreen(),
        ),
        GoRoute(
          path: '/admin',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) => const AdminScreen(),
        ),
      ],
    ),
  ],
);
