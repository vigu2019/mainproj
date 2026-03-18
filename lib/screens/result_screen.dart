import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utils/media_saver.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;

    if (extra == null || extra is! Map<String, dynamic>) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F5F9), // Slate 100
        body: Center(
          child: Text('Error: Expected map data, but got null or invalid format.', style: TextStyle(color: Color(0xFF0F172A))),
        ),
      );
    }

    final String imageUrl = extra['image_url'];
    final Map<String, dynamic> counts = extra['counts'] as Map<String, dynamic>;

    final int total = counts.values.fold<int>(0, (sum, v) => sum + (v as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B), size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analysis Report',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generated on ${DateFormat('MMM d, yyyy - h:mm a').format(DateTime.now())}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Download Image Button
                GestureDetector(
                  onTap: () => MediaSaver.downloadAndSaveImage(context, imageUrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.download_rounded, color: Color(0xFF3B82F6), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Download Image',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Main Desktop Layout (Horizontal Split)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel: Processed Image (70%)
                  Expanded(
                    flex: 7,
                    child: Container(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain, // Maintain aspect ratio within large box
                          loadingBuilder: (context, child, p) {
                            if (p == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 2),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Right Panel: Data Analytics (30%)
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(28),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Object Metrics',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Total Overview Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF), // Blue 50
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFBFDBFE)), // Blue 200
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Detections',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E3A8A), // Blue 900
                                  ),
                                ),
                                Text(
                                  total.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1D4ED8), // Blue 700
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          const Text(
                            'Breakdown',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Detailed List
                          Expanded(
                            child: counts.isEmpty
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 48,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No detections found.',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    itemCount: counts.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    itemBuilder: (context, index) {
                                      final entry = counts.entries.elementAt(index);
                                      final color = _getColorForIndex(index);

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10, height: 10,
                                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _capitalize(entry.key),
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              entry.value.toString(),
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber
      Color(0xFF8B5CF6), // Violet
      Color(0xFFEC4899), // Pink
      Color(0xFF06B6D4), // Cyan
    ];
    return colors[index % colors.length];
  }
}
