import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'material_list_controller.dart';

class MaterialListView extends GetView<MaterialListController> {
  const MaterialListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('素材管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.uploadMaterial,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.materials.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 64.r,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无广告素材',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.uploadMaterial,
                  child: const Text('上传素材'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshMaterials,
          child: GridView.builder(
            padding: EdgeInsets.all(16.r),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1,
            ),
            itemCount: controller.materials.length,
            itemBuilder: (context, index) {
              final material = controller.materials[index];
              return _buildMaterialItem(material);
            },
          ),
        );
      }),
    );
  }

  Widget _buildMaterialItem(AdMaterial material) {
    return InkWell(
      onTap: () => controller.showMaterialDetail(material),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: NetworkImage(material.coverUrl ?? material.url),
                fit: BoxFit.cover,
              ),
            ),
            child: material.type == 'video'
                ? Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 48.r,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          Positioned(
            right: 8.r,
            top: 8.r,
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.white,
              onPressed: () => _showDeleteConfirmDialog(material),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r),
                  bottomRight: Radius.circular(8.r),
                ),
              ),
              child: Text(
                material.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(AdMaterial material) async {
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
      controller.deleteMaterial(material.id);
    }
  }
} 