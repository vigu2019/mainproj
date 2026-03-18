import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

class MediaSaver {
  static Future<void> _downloadWeb(BuildContext context, String url, String filename) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Starting download... please wait'), backgroundColor: Color(0xFF10B981)),
        );
      }

      // 1. Fetch the file data
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download file data. Status code: ${response.statusCode}');
      }

      // 2. Create a blob from the bytes
      final blob = html.Blob([response.bodyBytes]);
      
      // 3. Create a temporary URL for the blob
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      // 4. Create an anchor element and trigger download
      final anchor = html.AnchorElement(href: blobUrl)
        ..target = 'blank'
        ..download = filename;

      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      
      // 5. Clean up the URL
      html.Url.revokeObjectUrl(blobUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download complete!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to download: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<void> downloadAndSaveImage(BuildContext context, String url) async {
    final fileName = 'soyolo_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _downloadWeb(context, url, fileName);
  }

  static Future<void> downloadAndSaveVideo(BuildContext context, String url) async {
    final fileName = 'soyolo_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await _downloadWeb(context, url, fileName);
  }
}
