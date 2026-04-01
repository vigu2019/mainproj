import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../services/stats_service.dart';
import '../services/database_service.dart';
import 'package:dio/dio.dart';

class VideoDetectionScreen extends StatefulWidget {
  const VideoDetectionScreen({super.key});

  @override
  State<VideoDetectionScreen> createState() => _VideoDetectionScreenState();
}

class _VideoDetectionScreenState extends State<VideoDetectionScreen> {
  File? _selectedVideo;
  Uint8List? _videoBytes;

  String _selectedModel = 'Enhanced';
  bool _loading = false;
  double _uploadProgress = 0.0;

  bool get hasVideo => _selectedVideo != null || _videoBytes != null;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;

      setState(() {
        if (file.bytes != null) {
          _videoBytes = file.bytes;
          _selectedVideo = null;
        } else if (file.path != null) {
          _selectedVideo = File(file.path!);
          _videoBytes = null;
        }
      });
    }
  }

  Future<void> _runVideoAnalysis() async {
    setState(() {
      _loading = true;
      _uploadProgress = 0.0;
    });

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'model_type': _selectedModel.toLowerCase(),
      });

      if (_videoBytes != null) {
        formData.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(_videoBytes!, filename: 'video.mp4'),
          ),
        );
      } else if (_selectedVideo != null) {
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(_selectedVideo!.path, filename: 'video.mp4'),
          ),
        );
      }

      final response = await dio.post(
        'http://127.0.0.1:8000/predict/video',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (total != -1) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      setState(() {
        _loading = false;
        _uploadProgress = 0.0;
      });

      if (!mounted) return;

      // Navigate immediately — do NOT block on DB
      context.push('/video-result', extra: response.data);
      try {
        await StatsService.incrementScans();
      } catch (_) {}

      try {
        final events = (response.data['events'] as List<dynamic>?) ?? [];
        await DatabaseService().insertScan({
          'type': 'Video',
          'model': _selectedModel,
          'item_count': events.length,
          'timestamp': DateTime.now().toString(),
          'status': 'Completed',
        });
      } catch (_) {}
    } catch (e) {
      setState(() {
        _loading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.video_library_rounded, color: Color(0xFF06B6D4), size: 24), // Cyan
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Stream Workplace',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Process continuous temporal patterns and motion data feeds.',
                      style: TextStyle(
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

            // Main Desktop Layout (Horizontal Split)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel: Upload Zone (70%)
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasVideo ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                            boxShadow: hasVideo ? [
                              BoxShadow(
                                color: const Color(0xFF94A3B8).withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: hasVideo
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF06B6D4).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_circle_fill_rounded, size: 64, color: Color(0xFF06B6D4)),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Media Source Ready',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC), // Slate 50
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: const Icon(Icons.video_library_outlined, size: 40, color: Color(0xFF06B6D4)),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Drag and drop a video here',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'or click to browse files (MP4, MOV)',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Right Panel: Settings & Execution (30%)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configuration',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Detection Model',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _buildSegmentButton('Baseline')),
                                Expanded(child: _buildSegmentButton('Enhanced')),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Selected File Info
                          if (hasVideo) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.movie_creation_outlined, color: Color(0xFF06B6D4), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedVideo != null ? _selectedVideo!.path.split('\\').last.split('/').last : 'video_stream.mp4',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF334155),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedVideo = null;
                                      _videoBytes = null;
                                    }),
                                    child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 18),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Process Button
                          GestureDetector(
                            onTap: hasVideo && !_loading ? _runVideoAnalysis : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 56,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: hasVideo ? const Color(0xFF06B6D4) : const Color(0xFFF1F5F9), // Cyan 500 / Slate 100
                                borderRadius: BorderRadius.circular(12),
                                border: hasVideo ? null : Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: hasVideo ? [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ] : null,
                              ),
                              child: Stack(
                                children: [
                                  if (_loading)
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: _uploadProgress,
                                          child: Container(color: Colors.white.withOpacity(0.2)),
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: _loading
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 16, height: 16,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Uploading... ${(_uploadProgress * 100).toInt()}%',
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Process Stream',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: hasVideo ? Colors.white : const Color(0xFF94A3B8),
                                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String title) {
    final isSelected = _selectedModel == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedModel = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
