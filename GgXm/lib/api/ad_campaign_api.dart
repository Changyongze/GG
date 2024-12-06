import 'package:get/get.dart';
import '../models/ad_campaign.dart';
import '../models/campaign_analysis.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class AdCampaignApi {
  final HttpService _httpService = Get.find<HttpService>();

  // 创建广告计划
  Future<AdCampaign> createCampaign(Map<String, dynamic> data) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.adCampaigns,
      data: data,
    );
    
    return AdCampaign.fromJson(response);
  }

  // 获取广告计划列表
  Future<List<AdCampaign>> getCampaigns({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.adCampaigns,
      queryParameters: {
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );
    
    return response.map((json) => AdCampaign.fromJson(json)).toList();
  }

  // 获取广告计划详情
  Future<AdCampaign> getCampaignDetail(String id) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$id',
    );
    
    return AdCampaign.fromJson(response);
  }

  // 更新广告计划
  Future<AdCampaign> updateCampaign(String id, Map<String, dynamic> data) async {
    final response = await _httpService.put<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$id',
      data: data,
    );
    
    return AdCampaign.fromJson(response);
  }

  // 更新广告计划状态
  Future<void> updateCampaignStatus(String id, String status) async {
    await _httpService.put(
      '${ApiConstants.adCampaigns}/$id/status',
      data: {'status': status},
    );
  }

  // 获取广告计划统计数据
  Future<Map<String, dynamic>> getCampaignStats(
    String id, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$id/stats',
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    
    return response;
  }

  Future<CampaignAnalysis> getCampaignAnalysis(String id) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$id/analysis',
    );
    
    return CampaignAnalysis.fromJson(response);
  }
} 