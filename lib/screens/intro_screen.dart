import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../services/stats_service.dart';
import 'package:intl/intl.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _totalScans = 1248; // Initial value, will be updated dynamically
  bool _isBackendOnline = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _checkBackendStatus();
    // Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkBackendStatus());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBackendStatus() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/')).timeout(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isBackendOnline = response.statusCode == 200;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBackendOnline = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    final scans = await StatsService.getTotalScans();
    if (mounted) {
      setState(() {
        _totalScans = scans;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A), // Slate 900
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Here\'s what\'s happening in your workspace today.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF64748B), // Slate 500
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: _isBackendOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444), // Emerald or Red
                          shape: BoxShape.circle,
                        ), 
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isBackendOnline ? 'Backend Online' : 'Backend Offline',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),

            // Action Cards
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'New Image Scan',
                    subtitle: 'Analyze static aerial imagery for objects.',
                    icon: Icons.image_search_rounded,
                    color: const Color(0xFF3B82F6), // Blue 500
                    route: '/image',
                    enabled: _isBackendOnline,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'New Video Stream',
                    subtitle: 'Process temporal motion via video feeds.',
                    icon: Icons.video_call_rounded,
                    color: const Color(0xFF06B6D4), // Cyan 500
                    route: '/video',
                    enabled: _isBackendOnline,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Scans',
                    value: NumberFormat('#,###').format(_totalScans),
                    trend: '+12% this week',
                    icon: Icons.analytics_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            const Text(
              'Recent Detections',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),

            // Mock History Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94A3B8).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHistoryRow('drone_sector_7.mp4', 'Video', 'Completed', '2 hrs ago'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildHistoryRow('sat_img_alpha_99.jpg', 'Image', 'Completed', '5 hrs ago'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildHistoryRow('feed_beta_live.mov', 'Video', 'Failed', '1 day ago', isError: true),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildHistoryRow('campus_scan_01.png', 'Image', 'Completed', '2 days ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required String route, required bool enabled}) {
    final effectiveColor = enabled ? color : const Color(0xFF94A3B8); // Gray out when disabled

    return GestureDetector(
      onTap: enabled ? () => context.go(route) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: enabled ? [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: effectiveColor, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  enabled ? 'Start Analysis' : 'Backend Offline',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(enabled ? Icons.arrow_forward_rounded : Icons.warning_rounded, size: 16, color: effectiveColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String trend, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669), // Emerald 600
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String title, String type, String status, String time, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              type == 'Video' ? Icons.videocam_rounded : Icons.image_rounded,
              color: const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              type,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
