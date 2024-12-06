import 'package:get/get.dart';
import '../models/advertiser.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';
import 'dart:io';
import 'package:http/http.dart';

class AdvertiserApi {
  final HttpService _httpService = Get.find<HttpService>();

  // 注册广告主
  Future<Advertiser> register(Map<String, dynamic> data) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.advertiserRegister,
      data: data,
    );
    
    return Advertiser.fromJson(response);
  }

  // 获取广告主信息
  Future<Advertiser> getInfo() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.advertiserInfo,
    );
    
    return Advertiser.fromJson(response);
  }

  // 更新广告主信息
  Future<Advertiser> updateInfo(Map<String, dynamic> data) async {
    final response = await _httpService.put<Map<String, dynamic>>(
      ApiConstants.advertiserInfo,
      data: data,
    );
    
    return Advertiser.fromJson(response);
  }

  // 充值账户余额
  Future<double> recharge(double amount, String paymentMethod) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.advertiserRecharge,
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
    
    return response['balance']?.toDouble() ?? 0.0;
  }

  // 获取账单明细
  Future<List<Map<String, dynamic>>> getBillingHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.advertiserBilling,
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );
    
    return response.map((json) => json as Map<String, dynamic>).toList();
  }

  // 更新投放设置
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _httpService.put(
      ApiConstants.advertiserSettings,
      data: settings,
    );
  }

  // 广告主注册
  Future<void> registerAdvertiser(Map<String, dynamic> data) async {
    await _httpService.post(
      ApiConstants.advertiserRegister,
      data: data,
    );
  }

  // 上传认证材料
  Future<void> uploadVerificationFiles(String id, List<String> files) async {
    final formData = FormData({
      'files': files.map((path) => MultipartFile(File(path))).toList(),
    });
    
    await _httpService.post(
      '${ApiConstants.advertiserVerification}/$id',
      data: formData,
    );
  }

  // 获取认证状态
  Future<Map<String, dynamic>> getVerificationStatus(String id) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.advertiserVerification}/$id',
    );
    
    return response;
  }
} 