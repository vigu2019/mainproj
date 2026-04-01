import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  static Widget buildImage(String input, {BoxFit fit = BoxFit.contain, Color loaderColor = const Color(0xFF3B82F6)}) {
    if (input.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            const Text('No image data', style: TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    if (input.startsWith('http')) {
      return Image.network(
        input,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator(color: loaderColor, strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
        ),
      );
    }

    // It is raw base64 or data uri
    try {
      String b64 = input;
      if (input.startsWith('data:image')) {
        b64 = input.split(',').last;
      }
      final Uint8List bytes = base64Decode(b64);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
        ),
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text('Invalid image data', style: TextStyle(color: Colors.redAccent.shade100)),
          ],
        ),
      );
    }
  }
}
