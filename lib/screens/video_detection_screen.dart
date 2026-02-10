import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;


class VideoDetectionScreen extends StatefulWidget {
  const VideoDetectionScreen({super.key});

  @override
  State<VideoDetectionScreen> createState() => _VideoDetectionScreenState();
}

class _VideoDetectionScreenState extends State<VideoDetectionScreen> {
  File? _selectedVideo;
  Uint8List? _videoBytes;

  String _selectedModel = 'Enhanced';
  bool _isLoading = false;

  bool get hasVideo => _selectedVideo != null || _videoBytes != null;

  // ---------------- PICK VIDEO ----------------
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

  // ---------------- RUN ANALYSIS ----------------
  Future<void> _runVideoAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('http://127.0.0.1:8000/predict/video');
    final request = http.MultipartRequest('POST', uri);

    request.fields['model_type'] = _selectedModel.toLowerCase();

    if (_videoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _videoBytes!,
          filename: 'video.mp4',
        ),
      );
    } else if (_selectedVideo != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedVideo!.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final result = jsonDecode(responseBody);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    final videoPath = result['video_path'];

    // ✅ WEB SAFE NAVIGATION
    context.go(
      '/video-result?path=${Uri.encodeComponent(videoPath)}',
    );
  }

  // ---------------- VIDEO PREVIEW ----------------
  Widget _videoPreview() {
    if (!hasVideo) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.videocam_outlined, size: 64, color: Colors.black54),
          SizedBox(height: 12),
          Text(
            'Click to upload video',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 56, color: Colors.green),
        const SizedBox(height: 12),
        const Text(
          'Video selected',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          _selectedVideo != null
              ? _selectedVideo!.path.split('/').last
              : 'Video loaded',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFB8C00), Color(0xFF7DA2FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Video Analysis',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Upload a video to analyze small object density',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),

                const SizedBox(height: 28),

                // ✅ FULL WIDTH VIDEO CARD
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: InkWell(
                    onTap: _pickVideo,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(child: _videoPreview()),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Select Model',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _modelChip('Baseline'),
                    const SizedBox(width: 12),
                    _modelChip('Enhanced'),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5F8CFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: hasVideo && !_isLoading
                        ? _runVideoAnalysis
                        : null,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Run Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'VisGrad - Video Analysis',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- MODEL CHIP ----------------
  Widget _modelChip(String model) {
    final bool isSelected = _selectedModel == model;

    return ChoiceChip(
      label: Text(model),
      selected: isSelected,
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF5F8CFF) : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) {
        setState(() {
          _selectedModel = model;
        });
      },
    );
  }
}
