import 'package:get/get.dart';
import '../../../models/download_task.dart';
import '../../../services/download_service.dart';

class DownloadListController extends GetxController {
  final _downloadService = Get.find<DownloadService>();
  
  final tasks = <DownloadTask>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
    _startTasksListener();
  }

  void _loadTasks() {
    tasks.value = _downloadService.tasks;
  }

  void _startTasksListener() {
    ever(_downloadService.tasks, (tasks) {
      _loadTasks();
    });
  }

  Future<void> pauseDownload(String id) async {
    await _downloadService.pauseDownload(id);
  }

  Future<void> resumeDownload(String id) async {
    await _downloadService.resumeDownload(id);
  }

  Future<void> cancelDownload(String id) async {
    await _downloadService.cancelDownload(id);
  }

  Future<void> openFile(String path) async {
    await _downloadService.openFile(path);
  }

  Future<void> shareFile(String path) async {
    await _downloadService.shareFile(path);
  }

  void clearCompletedTasks() {
    // TODO: 清理已完成的任务
  }

  void retryFailedTask(DownloadTask task) {
    _downloadService.startDownload(task.url, task.filename);
  }
} 