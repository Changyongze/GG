import 'dart:io';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoService extends GetxService {
  static const maxDuration = Duration(minutes: 1); // 最大1分钟
  static const maxFileSize = 50 * 1024 * 1024; // 最大50MB
  static const allowedFormats = [
    'mp4', 'mov', 'avi', 'wmv', 'flv'
  ];

  Future<VideoService> init() async {
    return this;
  }

  Future<bool> validateVideo(File file) async {
    // 检查文件格式
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedFormats.contains(extension)) {
      Get.snackbar('错误', '不支持的视频格式，请使用MP4、MOV等常见格式');
      return false;
    }

    // 检查文件大小
    final size = await file.length();
    if (size > maxFileSize) {
      Get.snackbar('错误', '视频文件过大，请控制在50MB以内');
      return false;
    }

    // 检查视频时长
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();

    if (duration > maxDuration) {
      Get.snackbar('错误', '视频时长超过1分钟，请剪辑后重试');
      return false;
    }

    return true;
  }

  Future<File?> compressVideo(File file) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo?.file == null) {
        throw '视频压缩失败';
      }

      return mediaInfo!.file!;
    } catch (e) {
      Get.snackbar('错误', '视频压缩失败：${e.toString()}');
      return null;
    }
  }

  Future<void> cancelCompression() async {
    await VideoCompress.cancelCompression();
  }

  Future<String?> getThumbnail(File file) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        file.path,
        quality: 50,
        position: -1, // 默认取中间帧
      );
      return thumbnail.path;
    } catch (e) {
      print('获取缩略图失败: $e');
      return null;
    }
  }

  double getCompressionProgress() {
    return VideoCompress.compressProgress$.value;
  }

  Stream<double> get compressionProgress => VideoCompress.compressProgress$;

  // 视频上传
  Future<String> uploadVideo(File videoFile) async {
    // TODO: 实现视频上传、转码、存储
  }
  
  // 视频转码
  Future<void> transcodeVideo(String videoId, List<String> formats) async {
    // TODO: 实现视频转码
  }
  
  // 获取播放地址
  Future<String> getPlayUrl(String videoId, String format) async {
    // TODO: 获取视频播放地址
  }
} 