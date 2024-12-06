import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/data_table.dart';
import 'ads_controller.dart';

class AdsView extends GetView<AdsController> {
  const AdsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部操作栏
          Container(
            padding: EdgeInsets.all(24.r),
            child: Row(
              children: [
                // 搜索框
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: '搜索广告...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: controller.search,
                  ),
                ),
                SizedBox(width: 16.w),
                
                // 筛选按钮
                OutlinedButton.icon(
                  onPressed: () => controller.showFilterDialog(),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('筛选'),
                ),
                SizedBox(width: 16.w),
                
                // 创建按钮
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(PCRoutes.AD_CREATE),
                  icon: const Icon(Icons.add),
                  label: const Text('创建广告'),
                ),
              ],
            ),
          ),

          // 数据表格
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return CommonDataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('标题')),
                  DataColumn(label: Text('类型')),
                  DataColumn(label: Text('状态')),
                  DataColumn(label: Text('展示量')),
                  DataColumn(label: Text('点击量')),
                  DataColumn(label: Text('点击率')),
                  DataColumn(label: Text('创建时间')),
                  DataColumn(label: Text('操作')),
                ],
                rows: controller.ads.map((ad) {
                  return DataRow(
                    cells: [
                      DataCell(Text(ad.id)),
                      DataCell(Text(ad.title)),
                      DataCell(Text(ad.type.name)),
                      DataCell(_buildStatusTag(ad.status)),
                      DataCell(Text(ad.views.toString())),
                      DataCell(Text(ad.clicks.toString())),
                      DataCell(Text('${(ad.ctr * 100).toStringAsFixed(2)}%')),
                      DataCell(Text(controller.formatDate(ad.createdAt))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => controller.editAd(ad),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bar_chart),
                            onPressed: () => controller.viewStats(ad),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => controller.deleteAd(ad),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
                onSort: controller.sortData,
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                onPageChanged: controller.changePage,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = '投放中';
        break;
      case 'paused':
        color = Colors.orange;
        label = '已暂停';
        break;
      case 'draft':
        color = Colors.grey;
        label = '草稿';
        break;
      case 'rejected':
        color = Colors.red;
        label = '已拒绝';
        break;
      default:
        color = Colors.grey;
        label = '未知';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
        ),
      ),
    );
  }
} 