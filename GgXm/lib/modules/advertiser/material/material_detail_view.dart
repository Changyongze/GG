import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'material_detail_controller.dart';

class MaterialDetailView extends GetView<MaterialDetailController> {
  const MaterialDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('素材详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmDialog,
          ),
        ],
      ),
      body: Obx(() {
        final material = controller.material.value;
        if (material == null) return const SizedBox();

        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            _buildPreview(material),
            SizedBox(height: 24.h),
            _buildInfo(material),
          ],
        );
      }),
    );
  }

  Widget _buildPreview(AdMaterial material) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          image: DecorationImage(
            image: NetworkImage(material.coverUrl ?? material.url),
            fit: BoxFit.cover,
          ),
        ),
        child: material.type == 'video'
            ? Center(
                child: IconButton(
                  icon: Icon(
                    Icons.play_circle_outline,
                    size: 64.r,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // TODO: 实现视频播放
                    Get.snackbar('提示', '视频播放功能开发中');
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildInfo(AdMaterial material) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoItem('素材标题', material.title),
            _buildInfoItem('素材描述', material.description),
            _buildInfoItem('素材类型', material.type == 'video' ? '视频' : '图片'),
            if (material.metadata != null) ...[
              if (material.metadata!['duration'] != null)
                _buildInfoItem('视频时长', '${material.metadata!['duration']}秒'),
              if (material.metadata!['resolution'] != null)
                _buildInfoItem('分辨率', material.metadata!['resolution']),
              if (material.metadata!['size'] != null)
                _buildInfoItem('文件大小', _formatFileSize(material.metadata!['size'])),
            ],
            _buildInfoItem('创建时间', DateFormat('yyyy-MM-dd HH:mm').format(material.createdAt)),
            _buildInfoItem('更新时间', DateFormat('yyyy-MM-dd HH:mm').format(material.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除素材'),
        content: const Text('确定要删除该素材吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteMaterial();
    }
  }
} 