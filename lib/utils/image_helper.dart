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
            const Text('Backend returned no image', style: TextStyle(color: Color(0xFF94A3B8))),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 36, color: Colors.amber),
              SizedBox(height: 8),
              Text('Image failed to load', style: TextStyle(color: Colors.amber, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (input.startsWith('/')) {
      return Image.network(
        'http://127.0.0.1:8000$input',
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator(color: loaderColor, strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 36, color: Colors.amber),
              SizedBox(height: 8),
              Text('Relative URL failed to load', style: TextStyle(color: Colors.amber, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    try {
      String b64 = input;
      if (input.startsWith('data:image')) {
        b64 = input.split(',').last;
      }
      // Sanitize base64 string
      b64 = b64.replaceAll(RegExp(r'\s+'), '');
      if (b64.length % 4 > 0) {
        b64 += '=' * (4 - (b64.length % 4));
      }

      final Uint8List bytes = base64Decode(b64);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 36, color: Colors.amber),
              SizedBox(height: 8),
              Text('Image failed to load', style: TextStyle(color: Colors.amber, fontSize: 12)),
            ],
          ),
        ),
      );
    } catch (e) {
      final debugString = input.length > 15 ? '${input.substring(0, 15)}...' : input;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text('Invalid image data ($debugString)', style: TextStyle(color: Colors.redAccent.shade100, fontSize: 12)),
          ],
        ),
      );
    }
  }
}
