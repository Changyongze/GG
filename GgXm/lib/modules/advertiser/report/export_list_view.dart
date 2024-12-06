import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../models/report_export.dart';
import 'export_list_controller.dart';

class ExportListView extends GetView<ExportListController> {
  const ExportListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导出记录'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.exports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.exports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_download_off,
                  size: 64.r,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无导出记录',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshExports,
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: controller.exports.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final export = controller.exports[index];
              return _buildExportCard(export);
            },
          ),
        );
      }),
    );
  }

  Widget _buildExportCard(ReportExport export) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    export.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(export),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              label: '导出格式',
              value: export.format.toUpperCase(),
            ),
            SizedBox(height: 8.h),
            _buildInfoRow(
              label: '创建时间',
              value: DateFormat('yyyy-MM-dd HH:mm').format(export.createdAt),
            ),
            if (export.completedAt != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow(
                label: '完成时间',
                value: DateFormat('yyyy-MM-dd HH:mm').format(export.completedAt!),
              ),
            ],
            SizedBox(height: 16.h),
            _buildActionButtons(export),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ReportExport export) {
    Color color;
    String label;
    IconData icon;

    if (export.isCompleted) {
      color = Colors.green;
      label = '已完成';
      icon = Icons.check_circle;
    } else if (export.isFailed) {
      color = Colors.red;
      label = '失败';
      icon = Icons.error;
    } else {
      color = Colors.blue;
      label = '处理中';
      icon = Icons.hourglass_empty;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.r,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ReportExport export) {
    if (export.isCompleted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => controller.downloadReport(export.downloadUrl!),
            icon: const Icon(Icons.download),
            label: const Text('下载'),
          ),
        ],
      );
    }

    if (export.isFailed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showRetryDialog(export),
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      );
    }

    if (export.isProcessing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showCancelDialog(export),
            icon: const Icon(Icons.cancel),
            label: const Text('取消'),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Future<void> _showCancelDialog(ReportExport export) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('取消导出'),
        content: Text('确定要取消导出"${export.name}"吗？'),
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
      controller.cancelExport(export.id);
    }
  }

  Future<void> _showRetryDialog(ReportExport export) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('重试导出'),
        content: Text('确定要重新导出"${export.name}"吗？'),
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
      // TODO: 实现重试功能
      Get.snackbar('提示', '重试功能开发中');
    }
  }
} 