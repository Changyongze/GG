import 'package:get/get.dart';
import 'dart:io';
import '../models/ad_material.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class AdMaterialApi {
  final HttpService _httpService = Get.find<HttpService>();

  // 上传广告素材
  Future<AdMaterial> uploadMaterial(String campaignId, {
    required String title,
    required String description,
    required File file,
    String type = 'video',
    File? coverFile,
  }) async {
    final formData = FormData({
      'title': title,
      'description': description,
      'type': type,
      'file': MultipartFile(file),
      if (coverFile != null) 'cover_file': MultipartFile(coverFile),
    });

    final response = await _httpService.post<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$campaignId/materials',
      data: formData,
    );
    
    return AdMaterial.fromJson(response);
  }

  // 获取广告素材列表
  Future<List<AdMaterial>> getMaterials(String campaignId) async {
    final response = await _httpService.get<List<dynamic>>(
      '${ApiConstants.adCampaigns}/$campaignId/materials',
    );
    
    return response.map((json) => AdMaterial.fromJson(json)).toList();
  }

  // 删除广告素材
  Future<void> deleteMaterial(String campaignId, String materialId) async {
    await _httpService.delete(
      '${ApiConstants.adCampaigns}/$campaignId/materials/$materialId',
    );
  }
} 