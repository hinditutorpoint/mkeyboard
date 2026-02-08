import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'font_support_checker.dart';

class ExportService {
  // Save as TXT file
  static Future<File?> saveAsTxt(String content, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');
      await file.writeAsString(content);
      return file;
    } catch (e) {
      debugPrint('Error saving TXT: $e');
      return null;
    }
  }

  // Save as PDF with font embedding
  static Future<File?> saveAsPdf(
    String content,
    String fileName, {
    bool containsHindi = false,
    bool containsGondi = false,
    bool containsGunjalaGondi = false,
    bool containsOlChiki = false,
  }) async {
    try {
      final pdf = pw.Document();

      // Load custom fonts from assets
      pw.Font? hindiFont;
      pw.Font? gondiFont;

      if (containsHindi) {
        final hindiFontData = await _loadFontData(
          'assets/fonts/NotoSansDevanagari-Regular.ttf',
        );
        if (hindiFontData != null) {
          hindiFont = pw.Font.ttf(hindiFontData);
        }
      }

      if (containsGondi) {
        final gondiFontData = await _loadFontData(
          'assets/fonts/NotoSansMasaramGondi-Regular.ttf',
        );
        if (gondiFontData != null) {
          gondiFont = pw.Font.ttf(gondiFontData);
        }
      }

      if (containsGunjalaGondi) {
        final gunjalaGondiFontData = await _loadFontData(
          'assets/fonts/NotoSansGunjalaGondi-Regular.ttf',
        );
        if (gunjalaGondiFontData != null) {
          gondiFont = pw.Font.ttf(gunjalaGondiFontData);
        }
      }

      if (containsOlChiki) {
        final olChikiFontData = await _loadFontData(
          'assets/fonts/NotoSansOlChiki-Regular.ttf',
        );
        if (olChikiFontData != null) {
          gondiFont = pw.Font.ttf(olChikiFontData);
        }
      }

      // Determine which font to use
      pw.Font? customFont = gondiFont ?? hindiFont;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Text(
              content,
              style: pw.TextStyle(fontSize: 14, font: customFont),
            ),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }

  static Future<ByteData?> _loadFontData(String path) async {
    try {
      final data = await DefaultAssetBundle.of(
        WidgetsBinding.instance.rootElement!,
      ).load(path);
      return data;
    } catch (e) {
      debugPrint('Error loading font: $e');
      return null;
    }
  }

  // Save as PNG (screenshot)
  static Future<File?> saveAsPng(Uint8List imageBytes, String fileName) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'shared_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        // Save to gallery
        await SaverGallery.saveFile(
          filePath: file.path,
          fileName: fileName,
          skipIfExists: true,
        );

        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error saving PNG: $e');
      return null;
    }
  }

  // Share as text or image based on font support
  static Future<void> smartShare(
    String text,
    ScreenshotController screenshotController,
  ) async {
    try {
      final containsGondi = FontSupportChecker.containsGondiCharacters(text);

      if (containsGondi) {
        final supportsGondi = await FontSupportChecker.supportsMasaramGondi();

        if (supportsGondi) {
          // Share as text
          await SharePlus.instance.share(ShareParams(text: text));
        } else {
          // Share as image (fallback)
          await _shareAsImage(screenshotController);
        }
      } else {
        // No special characters, share as text
        await SharePlus.instance.share(ShareParams(text: text));
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  static Future<void> _shareAsImage(ScreenshotController controller) async {
    try {
      final imageBytes = await controller.capture();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final file = File(
          '${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(imageBytes);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Shared from Hindi Keyboard',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  // Share as specific format
  static Future<void> shareFile(File file) async {
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }
}
