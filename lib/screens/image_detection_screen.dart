import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
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

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/predict'),
    );

    request.fields['model_type'] = _selectedModel.toLowerCase();

    if (_imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: 'image.jpg',
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    setState(() => _loading = false);

    context.go('/result', extra: data);
  }

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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Upload Image',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () => context.go('/mode'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: hasImage
                            ? (_imageBytes != null
                            ? Image.memory(_imageBytes!)
                            : Image.file(_selectedImage!))
                            : const Text(
                          'Tap to select image',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Baseline'),
                      selected: _selectedModel == 'Baseline',
                      onSelected: (_) {
                        setState(() => _selectedModel = 'Baseline');
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Enhanced'),
                      selected: _selectedModel == 'Enhanced',
                      onSelected: (_) {
                        setState(() => _selectedModel = 'Enhanced');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasImage && !_loading ? _runAnalysis : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5F8CFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text(
                      'Run Analysis',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
