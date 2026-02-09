import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFB8C00),
                Color(0xFF7DA2FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: -120, left: -120, child: _bgCircle(350)),
              Positioned(bottom: -140, right: -140, child: _bgCircle(350)),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      const Text(
                        'Choose Analysis Mode',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select how you want to analyze small object density',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 64),

                      Row(
                        children: [
                          Expanded(
                            child: _modeCard(
                              title: 'Image Analysis',
                              subtitle: 'Single Aerial Image',
                              icon: Icons.image_outlined,
                              bullets: const [
                                'Object count',
                                'Density heatmap',
                                'Classification',
                              ],
                              onTap: () {
                                context.go('/image');
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _modeCard(
                              title: 'Video Analysis',
                              subtitle: 'Frame-Wise Density',
                              icon: Icons.videocam_outlined,
                              bullets: const [
                                'Object Count',
                                'Live detection',
                                'Statistics',
                              ],
                              onTap: () {
                                context.go('/video');
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      _overviewPanel(),

                      const Spacer(),

                      const Text(
                        'VisGrad - Small Object Density Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bgCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.12),
      ),
    );
  }

  static Widget _modeCard({
    required String title,
    required String subtitle,
    required List<String> bullets,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF5F8CFF)),
            const SizedBox(height: 16),
            Text(
              title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            ...bullets.map(
                  (b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: Color(0xFF5F8CFF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _overviewPanel() {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20),
          childrenPadding: const EdgeInsets.all(20),
          title: const Text(
            'Dataset & Model Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          children: [
            _overviewRow('Datasets', 'VisDrone - Video Dataset - NWPU'),
            _overviewRow('No. of classes', '10'),
            _overviewRow(
              'Models',
              'YOLOv8 Baseline, VisGrad YOLO Model',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _overviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style:
              const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
