import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'ad_search_controller.dart';

class AdSearchView extends GetView<AdSearchController> {
  const AdSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            hintText: '搜索广告...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: controller.clearSearch,
            ),
          ),
          onSubmitted: controller.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Text(
              '暂无搜索结果',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final ad = controller.searchResults[index];
            return _buildAdCard(ad);
          },
        );
      }),
    );
  }

  Widget _buildAdCard(Ad ad) {
    return Card(
      // ... 广告卡片UI
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... 筛选选项
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
              controller.applyFilters();
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }
} 