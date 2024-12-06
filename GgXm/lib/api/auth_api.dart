import 'package:get/get.dart';
import '../models/user.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class AuthApi {
  final HttpService _httpService = Get.find<HttpService>();

  Future<void> sendVerificationCode(String phone) async {
    await _httpService.post(
      ApiConstants.sendCode,
      data: {'phone': phone},
    );
  }

  Future<Map<String, dynamic>> login(String phone, String code) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'phone': phone,
        'code': code,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> register(String phone, String code, String password) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'phone': phone,
        'code': code,
        'password': password,
      },
    );
    return response;
  }

  Future<User> updateProfile({
    required String nickname,
    required String gender,
    required int age,
    required String region,
    required List<String> interests,
    String? avatarUrl,
  }) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.updateProfile,
      data: {
        'nickname': nickname,
        'gender': gender,
        'age': age,
        'region': region,
        'interests': interests,
        if (avatarUrl != null) 'avatar': avatarUrl,
      },
    );
    return User.fromJson(response['user']);
  }
} 