import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/intro_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/image_detection_screen.dart';
import 'screens/video_detection_screen.dart';
import 'screens/result_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const IntroScreen(),
    ),

    GoRoute(
      path: '/mode',
      builder: (context, state) => const ModeSelectionScreen(),
    ),

    GoRoute(
      path: '/image',
      builder: (context, state) => const ImageUploadScreen(),
    ),

    GoRoute(
      path: '/video',
      builder: (context, state) => const VideoDetectionScreen(),
    ),

    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultScreen(),
    ),
  ],
);
