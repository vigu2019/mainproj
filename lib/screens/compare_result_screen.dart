import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utils/image_helper.dart';

class CompareResultScreen extends StatelessWidget {
  const CompareResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;

    if (extra == null || extra is! Map<String, dynamic>) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        body: Center(
          child: Text('Error: Expected map data, but got null or invalid format.', style: TextStyle(color: Color(0xFF0F172A))),
        ),
      );
    }

    final String baselineUrl = extra['baseline_image_url'] ?? extra['baseline_image'] ?? extra['baseline_base64'] ?? '';
    final String enhancedUrl = extra['enhanced_image_url'] ?? extra['enhanced_image'] ?? extra['enhanced_base64'] ?? '';
    final Map<String, dynamic> baselineCounts = extra['baseline_counts'] != null ? Map<String, dynamic>.from(extra['baseline_counts']) : {};
    final Map<String, dynamic> enhancedCounts = extra['enhanced_counts'] != null ? Map<String, dynamic>.from(extra['enhanced_counts']) : {};
    final int baselineTotal = ((extra['baseline_total'] ?? 0) as num).toInt();
    final int enhancedTotal = ((extra['enhanced_total'] ?? 0) as num).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Header
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
                      'Model Comparison',
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

            const SizedBox(height: 32),

            // Main Desktop Layout (Horizontal Split 50/50)
            Expanded(
              child: Row(
                children: [
                  // Left Panel: Baseline
                  Expanded(
                    child: _buildModelPanel(
                      title: 'Baseline Model',
                      imageUrl: baselineUrl,
                      total: baselineTotal,
                      counts: baselineCounts,
                      color: const Color(0xFF64748B), // Slate 500
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Panel: Enhanced
                  Expanded(
                    child: _buildModelPanel(
                      title: 'Enhanced Model',
                      imageUrl: enhancedUrl,
                      total: enhancedTotal,
                      counts: enhancedCounts,
                      color: const Color(0xFF3B82F6), // Blue 500
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

  Widget _buildModelPanel({
    required String title,
    required String imageUrl,
    required int total,
    required Map<String, dynamic> counts,
    required Color color,
  }) {
    return Container(
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
        children: [
          // Title Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          
          // Image Area
          Expanded(
            flex: 6,
            child: ClipRect(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: ImageHelper.buildImage(imageUrl, fit: BoxFit.contain, loaderColor: color),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Stats Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Detections',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        total.toString(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: counts.isEmpty
                        ? const Center(
                            child: Text(
                              'No detections found.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: counts.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final entry = counts.entries.elementAt(index);
                              final c = _getColorForIndex(index);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _capitalize(entry.key),
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      entry.value.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
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
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
      Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }
}
