import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'points_history_controller.dart';

class PointsHistoryView extends GetView<PointsHistoryController> {
  const PointsHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分明细'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildRecordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前积分',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Obx(() => Text(
                '${controller.points}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(() => Text(
                '本月获得: +${controller.monthEarned}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              )),
              SizedBox(height: 4.h),
              Obx(() => Text(
                '本月消费: -${controller.monthSpent}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.records.isEmpty) {
        return const Center(child: Text('暂无积分记录'));
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRecords,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: controller.records.length,
          itemBuilder: (context, index) {
            final record = controller.records[index];
            return _buildRecordItem(record);
          },
        ),
      );
    });
  }

  Widget _buildRecordItem(PointRecord record) {
    final isEarn = record.type == 'earn';
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      title: Text(
        record.description,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt),
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
        ),
      ),
      trailing: Text(
        '${isEarn ? '+' : '-'}${record.points}',
        style: TextStyle(
          fontSize: 16.sp,
          color: isEarn ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterSection(
              '类型',
              ['全部', '获得', '消费'],
              controller.selectedType,
              (value) {
                controller.selectedType.value = value;
                controller.loadRecords();
              },
            ),
            SizedBox(height: 16.h),
            _buildFilterSection(
              '来源',
              ['全部', '广告', '兑换'],
              controller.selectedSource,
              (value) {
                controller.selectedSource.value = value;
                controller.loadRecords();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    RxString selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: options.map((option) {
            return Obx(() => FilterChip(
              label: Text(option),
              selected: selected.value == option,
              onSelected: (isSelected) {
                if (isSelected) {
                  onChanged(option);
                }
              },
            ));
          }).toList(),
        ),
      ],
    );
  }
} 