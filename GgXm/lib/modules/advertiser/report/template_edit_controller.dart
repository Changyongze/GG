import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/report_template.dart';
import '../../../api/report_api.dart';

class TemplateEditController extends GetxController {
  final ReportApi _reportApi = ReportApi();
  
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final selectedMetrics = <String>{}.obs;
  final isDefault = false.obs;
  final isLoading = false.obs;
  final template = Rxn<ReportTemplate>();

  final metricOptions = [
    {'value': 'impressions', 'label': '展示量'},
    {'value': 'clicks', 'label': '点击量'},
    {'value': 'conversions', 'label': '转化量'},
    {'value': 'cost', 'label': '花费'},
    {'value': 'ctr', 'label': '点击率'},
    {'value': 'cvr', 'label': '转化率'},
    {'value': 'cpm', 'label': '千次展示成本'},
    {'value': 'cpc', 'label': '点击成本'},
    {'value': 'cpa', 'label': '转化成本'},
  ];

  final sections = <Map<String, dynamic>>[].obs;
  final previewData = Rxn<Map<String, dynamic>>();

  final sectionTypes = [
    {'type': 'overview', 'label': '数据概览', 'icon': Icons.dashboard},
    {'type': 'trend', 'label': '趋势分析', 'icon': Icons.trending_up},
    {'type': 'comparison', 'label': '同比分析', 'icon': Icons.compare_arrows},
    {'type': 'audience', 'label': '受众分析', 'icon': Icons.people},
    {'type': 'region', 'label': '地域分析', 'icon': Icons.map},
    {'type': 'schedule', 'label': '时段分析', 'icon': Icons.schedule},
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ReportTemplate) {
      template.value = Get.arguments as ReportTemplate;
      _initTemplateData();
    } else {
      // 新建模板时的默认布局
      sections.addAll([
        {'type': 'overview', 'metrics': <String>[]},
        {'type': 'trend', 'metrics': <String>[]},
      ]);
    }
  }

  void _initTemplateData() {
    final data = template.value!;
    nameController.text = data.name;
    descriptionController.text = data.description;
    selectedMetrics.addAll(data.metrics);
    isDefault.value = data.isDefault;
    sections.addAll(List<Map<String, dynamic>>.from(data.layout['sections']));
  }

  String getMetricLabel(String value) {
    final option = metricOptions.firstWhere(
      (o) => o['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return option['label'] as String;
  }

  Future<void> saveTemplate() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedMetrics.isEmpty) {
      Get.snackbar('错误', '请至少选择一个指标');
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'name': nameController.text,
        'description': descriptionController.text,
        'metrics': selectedMetrics.toList(),
        'layout': {
          'type': 'custom',
          'sections': sections.toList(),
        },
        'is_default': isDefault.value,
      };

      if (template.value != null) {
        await _reportApi.updateTemplate(template.value!.id, data);
        Get.snackbar('提示', '模板更新成功');
      } else {
        await _reportApi.createTemplate(data);
        Get.snackbar('提示', '模板创建成功');
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void addSection(String type) {
    sections.add({
      'type': type,
      'metrics': selectedMetrics.toList(),
    });
  }

  void removeSection(int index) {
    sections.removeAt(index);
  }

  void moveSection(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = sections.removeAt(oldIndex);
    sections.insert(newIndex, item);
  }

  void updateSectionMetrics(int index, List<String> metrics) {
    sections[index] = {
      ...sections[index],
      'metrics': metrics,
    };
  }

  String getSectionLabel(String type) {
    final section = sectionTypes.firstWhere(
      (s) => s['type'] == type,
      orElse: () => {'type': type, 'label': type},
    );
    return section['label'] as String;
  }

  IconData getSectionIcon(String type) {
    final section = sectionTypes.firstWhere(
      (s) => s['type'] == type,
      orElse: () => {'type': type, 'icon': Icons.article},
    );
    return section['icon'] as IconData;
  }

  Future<void> loadPreviewData() async {
    if (selectedMetrics.isEmpty) {
      Get.snackbar('错误', '请至少选择一个指标');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: 实现预览数据API
      await Future.delayed(const Duration(seconds: 1)); // 模拟API调用
      previewData.value = {
        'overview': {
          'impressions': 12345,
          'clicks': 678,
          'conversions': 89,
          'cost': 1234.56,
        },
        'trend': [
          {'date': '2024-01-01', 'impressions': 1000, 'clicks': 50},
          {'date': '2024-01-02', 'impressions': 1200, 'clicks': 60},
        ],
        // ... 其他模拟数据
      };
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
} 