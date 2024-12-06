import 'package:get/get.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ErrorHandler {
  static void handleError(dynamic error, String defaultMessage) {
    String message = defaultMessage;

    if (error is DioError) {
      message = _handleDioError(error);
    } else if (error is SocketException) {
      message = '网络连接失败，请检查网络设置';
    } else if (error is FormatException) {
      message = '数据格式错误';
    } else if (error is FileSystemException) {
      message = _handleFileSystemError(error);
    }

    // 显示错误消息
    Get.snackbar(
      '错误',
      message,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );

    // 记录错误日志
    _logError(error, message);
  }

  static String _handleDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioErrorType.sendTimeout:
        return '发送请求超时，请重试';
      case DioErrorType.receiveTimeout:
        return '接收数据超时，请重试';
      case DioErrorType.badResponse:
        return _handleHttpError(error.response?.statusCode);
      case DioErrorType.cancel:
        return '请求已取消';
      default:
        return '网络请求失败，请重试';
    }
  }

  static String _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '无权访问';
      case 404:
        return '请求资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败（$statusCode）';
    }
  }

  static String _handleFileSystemError(FileSystemException error) {
    switch (error.osError?.errorCode) {
      case 2: // No such file or directory
        return '文件或目录不存在';
      case 13: // Permission denied
        return '无权限访问文件';
      case 17: // File exists
        return '文件已存在';
      case 28: // No space left on device
        return '设备存储空间不足';
      default:
        return '文件操作失败: ${error.message}';
    }
  }

  static void _logError(dynamic error, String message) {
    // TODO: 实现错误日志记录
    print('Error: $message');
    print('Stack trace: ${error.stackTrace}');
  }
} 