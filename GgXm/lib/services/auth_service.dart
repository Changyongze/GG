import 'dart:convert';
import 'package:get/get.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final _authApi = AuthApi();
  final _storage = Get.find<StorageService>();
  
  final currentUser = Rxn<User>();
  final isLoggedIn = false.obs;

  Future<AuthService> init() async {
    // 从本地存储加载用户信息
    final userJson = _storage.getString(ApiConstants.userKey);
    if (userJson != null) {
      try {
        currentUser.value = User.fromJson(jsonDecode(userJson));
        isLoggedIn.value = true;
      } catch (e) {
        print('Failed to load user: $e');
      }
    }
    return this;
  }

  Future<void> sendVerificationCode(String phone) async {
    await _authApi.sendVerificationCode(phone);
  }

  Future<bool> login(String phone, String code) async {
    try {
      final response = await _authApi.login(phone, code);
      
      // 保存token
      await _storage.setString(ApiConstants.tokenKey, response['token']);
      
      // 保存用户信息
      currentUser.value = User.fromJson(response['user']);
      await _storage.setString(
        ApiConstants.userKey,
        jsonEncode(currentUser.value!.toJson()),
      );
      
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(String phone, String code, String password) async {
    try {
      final response = await _authApi.register(phone, code, password);
      
      // 保存token
      await _storage.setString(ApiConstants.tokenKey, response['token']);
      
      // 保存用户信息
      currentUser.value = User.fromJson(response['user']);
      await _storage.setString(
        ApiConstants.userKey,
        jsonEncode(currentUser.value!.toJson()),
      );
      
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required String nickname,
    required String gender,
    required int age,
    required String region,
    required List<String> interests,
    String? avatarUrl,
  }) async {
    try {
      final user = await _authApi.updateProfile(
        nickname: nickname,
        gender: gender,
        age: age,
        region: region,
        interests: interests,
        avatarUrl: avatarUrl,
      );
      
      currentUser.value = user;
      await _storage.setString(
        ApiConstants.userKey,
        jsonEncode(user.toJson()),
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateUserInfo({
    String? nickname,
    String? avatar,
    String? gender,
    int? age,
    String? region,
    List<String>? interests,
  }) async {
    try {
      final user = await _authApi.updateProfile(
        nickname: nickname,
        gender: gender,
        age: age,
        region: region,
        interests: interests,
        avatarUrl: avatar,
      );
      
      currentUser.value = user;
      await _storage.setString(
        ApiConstants.userKey,
        jsonEncode(user.toJson()),
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    currentUser.value = null;
    isLoggedIn.value = false;
    _storage.remove(ApiConstants.tokenKey);
    _storage.remove(ApiConstants.userKey);
    Get.offAllNamed(Routes.LOGIN);
  }
} 