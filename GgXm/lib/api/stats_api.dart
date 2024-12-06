import 'package:get/get.dart';
import '../models/campaign_stats.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class StatsApi {
  final HttpService _httpService = Get.find<HttpService>();

  // 获取广告计划统计数据
  Future<CampaignStats> getCampaignStats(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$campaignId/stats',
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    
    return CampaignStats.fromJson(response);
  }

  // 获取广告主账户统计数据
  Future<Map<String, dynamic>> getAccountStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      ApiConstants.advertiserStats,
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    
    return response;
  }

  // 获取投放建议
  Future<List<Map<String, dynamic>>> getOptimizationSuggestions(
    String campaignId,
  ) async {
    final response = await _httpService.get<List<dynamic>>(
      '${ApiConstants.adCampaigns}/$campaignId/suggestions',
    );
    
    return response.cast<Map<String, dynamic>>();
  }
} 