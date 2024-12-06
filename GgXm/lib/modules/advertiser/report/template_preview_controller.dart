import 'package:get/get.dart';
import '../../../models/report_template.dart';

class TemplatePreviewController extends GetxController {
  final template = Rxn<Map<String, dynamic>>();
  final previewData = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final currentSection = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    template.value = args['template'] as Map<String, dynamic>;
    previewData.value = args['preview_data'] as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> get sections {
    return List<Map<String, dynamic>>.from(template.value?['layout']['sections'] ?? []);
  }

  void nextSection() {
    if (currentSection.value < sections.length - 1) {
      currentSection.value++;
    }
  }

  void previousSection() {
    if (currentSection.value > 0) {
      currentSection.value--;
    }
  }

  String getMetricLabel(String metric) {
    final labels = {
      'impressions': '展示量',
      'clicks': '点击量',
      'conversions': '转化量',
      'cost': '花费',
      'ctr': '点击率',
      'cvr': '转化率',
      'cpm': '千次展示成本',
      'cpc': '点击成本',
      'cpa': '转化成本',
    };
    return labels[metric] ?? metric;
  }

  String formatMetricValue(dynamic value, String metric) {
    if (value == null) return '-';
    
    switch (metric) {
      case 'ctr':
      case 'cvr':
        return '${(value as num).toStringAsFixed(2)}%';
      case 'cost':
      case 'cpm':
      case 'cpc':
      case 'cpa':
        return '¥${(value as num).toStringAsFixed(2)}';
      default:
        if (value is num && value >= 10000) {
          return '${(value / 10000).toStringAsFixed(1)}w';
        }
        return value.toString();
    }
  }

  Color getMetricColor(String metric, num value) {
    switch (metric) {
      case 'ctr':
      case 'cvr':
        if (value >= 5) return Colors.red;
        if (value >= 3) return Colors.orange;
        return Colors.blue;
      case 'cost':
      case 'cpm':
      case 'cpc':
      case 'cpa':
        if (value >= 1000) return Colors.red;
        if (value >= 500) return Colors.orange;
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Map<String, dynamic>? getSectionData(String type) {
    switch (type) {
      case 'overview':
        return previewData.value?['overview'];
      case 'trend':
        return previewData.value?['trend'];
      case 'comparison':
        return previewData.value?['comparison'];
      case 'audience':
        return previewData.value?['audience'];
      case 'region':
        return previewData.value?['region'];
      case 'schedule':
        return previewData.value?['schedule'];
      default:
        return null;
    }
  }

  String getSectionLabel(String type) {
    final labels = {
      'overview': '数据概览',
      'trend': '趋势分析',
      'comparison': '同比分析',
      'audience': '受众分析',
      'region': '地域分析',
      'schedule': '时段分析',
    };
    return labels[type] ?? type;
  }

  IconData getSectionIcon(String type) {
    final icons = {
      'overview': Icons.dashboard,
      'trend': Icons.trending_up,
      'comparison': Icons.compare_arrows,
      'audience': Icons.people,
      'region': Icons.map,
      'schedule': Icons.schedule,
    };
    return icons[type] ?? Icons.article;
  }
} 