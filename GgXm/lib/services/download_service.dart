import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class DownloadService extends GetxService {
  final Dio _dio = Dio();
  
  Future<void> downloadFile(
    String url,
    String fileName, {
    Function(double)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';
      
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );
      
      await OpenFile.open(savePath);
    } catch (e) {
      rethrow;
    }
  }
} 