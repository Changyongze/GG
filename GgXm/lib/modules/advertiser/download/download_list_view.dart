import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../models/download_task.dart';
import 'download_list_controller.dart';

class DownloadListView extends GetView<DownloadListController> {
  const DownloadListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: controller.clearCompletedTasks,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_done,
                  size: 64.r,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无下载任务',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: controller.tasks.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final task = controller.tasks[index];
            return _buildTaskCard(task);
          },
        );
      }),
    );
  }

  Widget _buildTaskCard(DownloadTask task) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTaskIcon(task),
                  size: 24.r,
                  color: _getTaskColor(task),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    task.filename,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildTaskStatus(task),
              ],
            ),
            if (task.isDownloading) ...[
              SizedBox(height: 16.h),
              LinearProgressIndicator(
                value: task.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 8.h),
              Text(
                '${(task.progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (task.error != null) ...[
              SizedBox(height: 8.h),
              Text(
                task.error!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(task.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                _buildActionButtons(task),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTaskIcon(DownloadTask task) {
    if (task.isCompleted) return Icons.check_circle;
    if (task.isFailed) return Icons.error;
    if (task.isPaused) return Icons.pause_circle;
    if (task.isDownloading) return Icons.download;
    return Icons.hourglass_empty;
  }

  Color _getTaskColor(DownloadTask task) {
    if (task.isCompleted) return Colors.green;
    if (task.isFailed) return Colors.red;
    if (task.isPaused) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildTaskStatus(DownloadTask task) {
    String text;
    Color color;

    if (task.isCompleted) {
      text = '已完成';
      color = Colors.green;
    } else if (task.isFailed) {
      text = '失败';
      color = Colors.red;
    } else if (task.isPaused) {
      text = '已暂停';
      color = Colors.orange;
    } else if (task.isDownloading) {
      text = '下载中';
      color = Colors.blue;
    } else {
      text = '等待中';
      color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(DownloadTask task) {
    if (task.isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => controller.openFile(task.savePath),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => controller.shareFile(task.savePath),
          ),
        ],
      );
    }

    if (task.isFailed) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => controller.retryFailedTask(task),
      );
    }

    if (task.isDownloading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => controller.pauseDownload(task.id),
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () => _showCancelDialog(task),
          ),
        ],
      );
    }

    if (task.isPaused) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => controller.resumeDownload(task.id),
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () => _showCancelDialog(task),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Future<void> _showCancelDialog(DownloadTask task) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('取消下载'),
        content: Text('确定要取消下载"${task.filename}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.cancelDownload(task.id);
    }
  }
} 