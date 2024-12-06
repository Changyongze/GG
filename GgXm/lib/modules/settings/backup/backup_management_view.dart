import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:filesize/filesize.dart';
import 'backup_management_controller.dart';

class BackupManagementView extends GetView<BackupManagementController> {
  const BackupManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备份管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBackupDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.backups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.backup_outlined,
                  size: 64.r,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无备份',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: controller.backups.length,
          itemBuilder: (context, index) {
            final backup = controller.backups[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  backup.encrypted ? Icons.lock : Icons.lock_open,
                  color: backup.encrypted ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  backup.timestamp.toString().substring(0, 16),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('大小: ${filesize(backup.size)}'),
                    Text('版本: ${backup.version}'),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'restore',
                      child: Text('恢复'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'restore':
                        _showRestoreConfirmDialog(context, backup);
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog(context, backup);
                        break;
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showCreateBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建备份'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => CheckboxListTile(
              title: const Text('加密备份'),
              value: controller.encryptBackup.value,
              onChanged: (value) => controller.encryptBackup.value = value!,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.createBackup();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmDialog(BuildContext context, BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复备份'),
        content: const Text('确定要恢复此备份吗？当前数据将被覆盖。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.restoreBackup(backup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除备份'),
        content: const Text('确定要删除此备份吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteBackup(backup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 