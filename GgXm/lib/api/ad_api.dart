import 'package:get/get.dart';
import '../models/ad.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class AdApi {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<Ad>> getAds({String? category}) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.ads,
      queryParameters: {
        if (category != null) 'category': category,
      },
    );
    
    return response.map((json) => Ad.fromJson(json)).toList();
  }

  Future<Ad> getAdDetail(String id) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.ads}/$id',
    );
    
    return Ad.fromJson(response);
  }

  Future<void> earnPoints(String adId) async {
    await _httpService.post(
      '${ApiConstants.ads}/$adId/earn-points',
    );
  }

  Future<void> likeAd(String adId) async {
    await _httpService.post(
      '${ApiConstants.ads}/$adId/like',
    );
  }

  Future<void> shareAd(String adId) async {
    await _httpService.post(
      '${ApiConstants.ads}/$adId/share',
    );
  }

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
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.adCampaigns,
      queryParameters: {
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    return response.map((json) => AdCampaign.fromJson(json)).toList();
  }

  // 获取广告统计数据
  Future<AdStats> getAdStats(
    String adId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$adId/stats',
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
    return AdStats.fromJson(response);
  }

  // 更新广告计划状态
  Future<void> updateCampaignStatus(String id, CampaignStatus status) async {
    await _httpService.put(
      '${ApiConstants.adCampaigns}/$id/status',
      data: {'status': status.name},
    );
  }

  // 上传广告视频
  Future<String> uploadVideo(File videoFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        videoFile.path,
        filename: basename(videoFile.path),
      ),
    });

    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.uploadVideo,
      data: formData,
    );

    return response['url'] as String;
  }

  Future<Map<String, dynamic>> estimateEffects(Map<String, dynamic> data) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/estimate',
      data: data,
    );
    
    return response;
  }

  // 获取推荐广告列表
  Future<List<Ad>> getRecommendedAds({int page = 1, int pageSize = 10}) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.recommendedAds,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.map((json) => Ad.fromJson(json)).toList();
  }

  // 获取广告详情
  Future<Ad> getAdDetail(String id) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.ads}/$id',
    );
    return Ad.fromJson(response);
  }

  // 点赞广告
  Future<void> likeAd(String id) async {
    await _httpService.post(
      '${ApiConstants.ads}/$id/like',
    );
  }

  // 取消点赞
  Future<void> unlikeAd(String id) async {
    await _httpService.delete(
      '${ApiConstants.ads}/$id/like',
    );
  }

  // 获取广告评论
  Future<List<Comment>> getAdComments(String id, {int page = 1, int pageSize = 20}) async {
    final response = await _httpService.get<List<dynamic>>(
      '${ApiConstants.ads}/$id/comments',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.map((json) => Comment.fromJson(json)).toList();
  }

  // 发表评论
  Future<Comment> addComment(String adId, String content) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.ads}/$adId/comments',
      data: {'content': content},
    );
    return Comment.fromJson(response);
  }

  // 删除评论
  Future<void> deleteComment(String adId, String commentId) async {
    await _httpService.delete(
      '${ApiConstants.ads}/$adId/comments/$commentId',
    );
  }

  // 举报广告
  Future<void> reportAd(String id, String reason) async {
    await _httpService.post(
      '${ApiConstants.ads}/$id/report',
      data: {'reason': reason},
    );
  }

  // 获取广告历史表现数据
  Future<Map<String, dynamic>> getAdHistoricalPerformance(String adId) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.ads}/$adId/historical-performance',
    );
    return response;
  }

  // 获取同类广告表现数据
  Future<Map<String, dynamic>> getSimilarAdsPerformance(
    String adId,
    Map<String, dynamic> params,
  ) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.ads}/$adId/similar-ads',
      queryParameters: params,
    );
    return response;
  }

  // 获取广告投放建议
  Future<AdSuggestion> getAdSuggestions(
    String adId,
    Map<String, dynamic> params,
  ) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.ads}/$adId/suggestions',
      queryParameters: params,
    );
    return AdSuggestion.fromJson(response);
  }

  // 导出广告建议报告
  Future<String> exportAdSuggestionReport(
    String adId,
    AdSuggestion suggestions,
  ) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.ads}/$adId/export-suggestions',
      data: {
        'suggestions': suggestions,
        'format': 'pdf',
      },
    );
    return response['download_url'] as String;
  }

  // 更新广告设置
  Future<void> updateAdSettings(
    String adId,
    Map<String, dynamic> settings,
  ) async {
    await _httpService.put(
      '${ApiConstants.ads}/$adId/settings',
      data: settings,
    );
  }

  // 预测广告效果
  Future<Map<String, dynamic>> predictAdPerformance(
    String adId,
    Map<String, dynamic> params,
  ) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.ads}/$adId/predict',
      data: params,
    );
    return response;
  }
} 