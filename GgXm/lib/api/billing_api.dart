import 'package:get/get.dart';
import '../models/billing_record.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class BillingApi {
  final HttpService _httpService = Get.find<HttpService>();

  // 获取账单记录
  Future<List<BillingRecord>> getBillingRecords({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.billingRecords,
      queryParameters: {
        if (type != null) 'type': type,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );
    
    return response.map((json) => BillingRecord.fromJson(json)).toList();
  }

  // 获取账户余额
  Future<Map<String, dynamic>> getBalance() async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.advertiserBalance,
    );
    
    return response;
  }

  // 充值
  Future<Map<String, dynamic>> recharge(double amount, String paymentMethod) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.advertiserRecharge,
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
    
    return response;
  }

  // 获取账单统计
  Future<Map<String, dynamic>> getBillingStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.billingStats,
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    
    return response;
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.advertiserRecharge}/$orderId/status',
    );
    
    return response;
  }
} 