import 'package:get/get.dart';
import '../models/report_template.dart';
import '../models/report_export.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class ReportApi {
  final HttpService _httpService = Get.find<HttpService>();

  // 获取报告模板列表
  Future<List<ReportTemplate>> getTemplates() async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.reportTemplates,
    );
    
    return response.map((json) => ReportTemplate.fromJson(json)).toList();
  }

  // 创建报告模板
  Future<ReportTemplate> createTemplate(Map<String, dynamic> data) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.reportTemplates,
      data: data,
    );
    
    return ReportTemplate.fromJson(response);
  }

  // 更新报告模板
  Future<ReportTemplate> updateTemplate(String id, Map<String, dynamic> data) async {
    final response = await _httpService.put<Map<String, dynamic>>(
      '${ApiConstants.reportTemplates}/$id',
      data: data,
    );
    
    return ReportTemplate.fromJson(response);
  }

  // 删除报告模板
  Future<void> deleteTemplate(String id) async {
    await _httpService.delete(
      '${ApiConstants.reportTemplates}/$id',
    );
  }

  // 导出报告
  Future<String> exportReport(Map<String, dynamic> data) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.reportExport,
      data: data,
    );
    
    return response['download_url'] as String;
  }

  // 获取自动生成的分析报告
  Future<Map<String, dynamic>> getAnalysisReport(String campaignId) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.adCampaigns}/$campaignId/analysis-report',
    );
    
    return response;
  }

  // 创建导出任务
  Future<ReportExport> createExportTask(Map<String, dynamic> data) async {
    final response = await _httpService.post<Map<String, dynamic>>(
      ApiConstants.reportExport,
      data: data,
    );
    
    return ReportExport.fromJson(response);
  }

  // 获取导出任务列表
  Future<List<ReportExport>> getExportTasks({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.reportExports,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    
    return response.map((json) => ReportExport.fromJson(json)).toList();
  }

  // 获取导出任务状态
  Future<ReportExport> getExportTaskStatus(String taskId) async {
    final response = await _httpService.get<Map<String, dynamic>>(
      '${ApiConstants.reportExports}/$taskId',
    );
    
    return ReportExport.fromJson(response);
  }

  // 取消导出任务
  Future<void> cancelExportTask(String taskId) async {
    await _httpService.post(
      '${ApiConstants.reportExports}/$taskId/cancel',
    );
  }
} 