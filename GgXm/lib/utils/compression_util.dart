import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;

class CompressionUtil {
  // 压缩级别
  static const int COMPRESSION_LEVEL = 9; // 最高压缩级别

  // 压缩文件
  static Future<List<int>> compressFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileName = basename(filePath);
    
    final archive = Archive();
    final compressed = ZipEncoder().encode(
      archive..addFile(ArchiveFile(
        fileName,
        bytes.length,
        bytes,
      )),
      level: COMPRESSION_LEVEL,
    );

    return compressed ?? [];
  }

  // 压缩图片
  static Future<List<int>> compressImage(List<int> imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // 调整图片尺寸
    var resized = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      resized = img.copyResize(
        image,
        width: maxWidth,
        height: maxHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // 压缩图片
    return img.encodeJpg(resized, quality: quality);
  }

  // 批量压缩
  static Future<Map<String, List<int>>> compressFiles(
    List<String> filePaths, {
    bool parallel = true,
  }) async {
    final results = <String, List<int>>{};
    
    if (parallel) {
      // 并行压缩
      final futures = filePaths.map((path) async {
        final compressed = await compressFile(path);
        return MapEntry(path, compressed);
      });
      
      final entries = await Future.wait(futures);
      results.addEntries(entries);
    } else {
      // 串行压缩
      for (final path in filePaths) {
        final compressed = await compressFile(path);
        results[path] = compressed;
      }
    }

    return results;
  }

  // 解压文件
  static Future<void> decompressFile(
    List<int> compressedData,
    String outputPath,
  ) async {
    final archive = ZipDecoder().decodeBytes(compressedData);
    
    for (final file in archive.files) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(join(outputPath, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
  }

  // 估算压缩后大小
  static int estimateCompressedSize(int originalSize) {
    // 根据经验值估算，通常可以压缩到原大小的40-60%
    return (originalSize * 0.5).round();
  }
} 