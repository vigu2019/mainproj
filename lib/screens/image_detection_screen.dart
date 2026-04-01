import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../services/stats_service.dart';
import '../services/database_service.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _selectedImage;
  Uint8List? _imageBytes;

  String _selectedModel = 'Enhanced';
  bool _loading = false;

  bool get hasImage => _selectedImage != null || _imageBytes != null;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        if (file.bytes != null) {
          _imageBytes = file.bytes;
          _selectedImage = null;
        } else if (file.path != null) {
          _selectedImage = File(file.path!);
          _imageBytes = null;
        }
      });
    }
  }

  Future<void> _runAnalysis() async {
    if (!hasImage) return;
    setState(() => _loading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/predict'),
      );

      request.fields['model_type'] = _selectedModel.toLowerCase();

      if (_imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes('file', _imageBytes!, filename: 'image.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', _selectedImage!.path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      setState(() => _loading = false);
      if (!mounted) return;

      context.push('/result', extra: data);

      // Persist in background (non-blocking)
      try {
        await StatsService.incrementScans();
      } catch (_) {}

      try {
        await DatabaseService().insertScan({
          'type': 'Image',
          'model': _selectedModel,
          'item_count': data['total'] ?? 0,
          'timestamp': DateTime.now().toString(),
          'status': 'Completed',
        });
      } catch (_) {}
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _runCompare() async {
    if (!hasImage) return;
    setState(() => _loading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/compare'),
      );

      if (_imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes('file', _imageBytes!, filename: 'image.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', _selectedImage!.path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      setState(() => _loading = false);
      if (!mounted) return;

      context.push('/compare-result', extra: data);

      try {
        await StatsService.incrementScans();
      } catch (_) {}

      try {
        await DatabaseService().insertScan({
          'type': 'Image',
          'model': 'Compare',
          'item_count': (data['enhanced_total'] ?? 0) as int,
          'timestamp': DateTime.now().toString(),
          'status': 'Completed',
        });
      } catch (_) {}
    } catch (e) {
      setState(() => _loading = false);
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
                  child: const Icon(Icons.image_search_rounded, color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Analysis Workplace',
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
                      'Upload high-res aerial imagery for static object detection.',
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
                      onTap: _pickImage,
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasImage ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                            boxShadow: hasImage ? [
                              BoxShadow(
                                color: const Color(0xFF94A3B8).withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: hasImage
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: _imageBytes != null
                                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                      : Image.file(_selectedImage!, fit: BoxFit.cover),
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
                                      child: const Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF3B82F6)),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Drag and drop an image here',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'or click to browse files (JPG, PNG)',
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
                          if (hasImage) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF3B82F6), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedImage != null ? _selectedImage!.path.split('\\').last.split('/').last : 'memory_image.jpg',
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
                                      _selectedImage = null;
                                      _imageBytes = null;
                                    }),
                                    child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 18),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Process Buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: hasImage && !_loading ? _runCompare : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: hasImage ? Colors.white : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: hasImage ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox.shrink()
                                          : Text(
                                              'Compare Models',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: hasImage ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: hasImage && !_loading ? _runAnalysis : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: hasImage ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9), // Blue 500 / Slate 100
                                      borderRadius: BorderRadius.circular(12),
                                      border: hasImage ? null : Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: hasImage ? [
                                        BoxShadow(
                                          color: const Color(0xFF3B82F6).withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        )
                                      ] : null,
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20, height: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : Text(
                                              'Process Imagery',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: hasImage ? Colors.white : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
