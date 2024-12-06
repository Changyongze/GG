import 'package:get/get.dart';
import '../../../models/report_export.dart';
import '../../../api/report_api.dart';

class ExportListController extends GetxController {
  final ReportApi _reportApi = ReportApi();
  
  final exports = <ReportExport>[].obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  static const pageSize = 20;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadExports(refresh: true);
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // 只有有正在处理的任务时才自动刷新
      if (exports.any((e) => e.isProcessing)) {
        refreshExports();
      }
    });
  }

  Future<void> loadExports({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final response = await _reportApi.getExportTasks(
        page: currentPage.value,
        pageSize: pageSize,
      );
      
      if (refresh) {
        exports.clear();
      }
      
      if (response.length < pageSize) {
        hasMore.value = false;
      }
      
      exports.addAll(response);
      currentPage.value++;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshExports() async {
    await loadExports(refresh: true);
  }

  Future<void> cancelExport(String taskId) async {
    try {
      await _reportApi.cancelExportTask(taskId);
      await refreshExports();
      Get.snackbar('提示', '任务已取消');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void downloadReport(String url) {
    // TODO: 实现文件下载
    launchUrl(Uri.parse(url));
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
} 