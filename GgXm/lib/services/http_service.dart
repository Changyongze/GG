import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';

class HttpService extends GetxService {
  late final Dio _dio;
  
  Future<HttpService> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _requestInterceptor,
      onResponse: _responseInterceptor,
      onError: _errorInterceptor,
    ));

    return this;
  }

  // 请求拦截器
  void _requestInterceptor(RequestOptions options, RequestInterceptorHandler handler) {
    // 从本地存储获取token
    final token = Get.find<StorageService>().getString('token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // 响应拦截器
  void _responseInterceptor(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  // 错误拦截器
  void _errorInterceptor(DioException err, ErrorInterceptorHandler handler) {
    // 统一错误处理
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(err.message);
      case DioExceptionType.badResponse:
        throw BadResponseException(err.response?.statusMessage);
      default:
        throw OtherException(err.message);
    }
  }

  // GET请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // POST请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

// 自定义异常
class TimeoutException implements Exception {
  final String? message;
  TimeoutException(this.message);
}

class BadResponseException implements Exception {
  final String? message;
  BadResponseException(this.message);
}

class OtherException implements Exception {
  final String? message;
  OtherException(this.message);
} 