import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;
  
  const DashboardLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Determine active route for sidebar highlighting
    final String location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 Background
      body: Row(
        children: [
          // Sidebar Menu
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Brand
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // Blue 50
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: Color(0xFF3B82F6), // Blue 500
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SO-YOLOv8',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A), // Slate 900
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'DASHBOARD',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8), // Slate 400
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                _SidebarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Overview',
                  isActive: location == '/' || location == '/mode',
                  onTap: () => context.go('/'),
                ),
                _SidebarItem(
                  icon: Icons.image_rounded,
                  label: 'Image Analysis',
                  isActive: location == '/image',
                  onTap: () => context.go('/image'),
                ),
                _SidebarItem(
                  icon: Icons.videocam_rounded,
                  label: 'Video Stream',
                  isActive: location == '/video',
                  onTap: () => context.go('/video'),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'REPORTS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                _SidebarItem(
                  icon: Icons.history_rounded,
                  label: 'Recent Detections',
                  isActive: false,
                  onTap: () {
                    // Mock feature
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recent Detections module coming soon.')),
                    );
                  },
                ),
                
                const Spacer(),

                // User / Settings Footer
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))), // Slate 200
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF64748B), size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin User',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Text(
                              'admin@so-yolo.local',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: ClipRRect(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent, // Blue 50
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF64748B), // Blue 500 / Slate 500
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF475569), // Blue 700 / Slate 600
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
