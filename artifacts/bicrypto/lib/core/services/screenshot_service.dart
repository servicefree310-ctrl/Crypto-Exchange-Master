import 'dart:io';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:developer' as dev;

@injectable
class ScreenshotService {
  /// Capture screenshot and return the file path for sharing
  Future<String?> captureToFile({
    required GlobalKey key,
    String? fileName,
  }) async {
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/${fileName ?? 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png'}');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      dev.log('❌ SCREENSHOT_SERVICE: Error saving screenshot: $e');
      return null;
    }
  }
}
