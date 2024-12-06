import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'billing_list_controller.dart';

class BillingListView extends GetView<BillingListController> {
  const BillingListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单明细'),
        actions: [
          TextButton(
            onPressed: controller.recharge,
            child: Text(
              '充值',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          _buildTypeFilter(),
          Expanded(
            child: _buildRecordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: EdgeInsets.all(16.r),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '账户余额',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => Text(
                  '¥${controller.balance.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: controller.recharge,
              child: const Text('立即充值'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      height: 44.h,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: controller.typeOptions.length,
        itemBuilder: (context, index) {
          final option = controller.typeOptions[index];
          return Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ChoiceChip(
              label: Text(option['label'] as String),
              selected: controller.selectedType.value == option['value'],
              onSelected: (selected) {
                if (selected) {
                  controller.filterByType(option['value'] as String);
                }
              },
            ),
          ));
        },
      ),
    );
  }

  Widget _buildRecordList() {
    return Obx(() {
      if (controller.isLoading.value && controller.records.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.records.isEmpty) {
        return Center(
          child: Text(
            '暂无账单记录',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRecords,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: controller.records.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final record = controller.records[index];
            return _buildRecordItem(record);
          },
        ),
      );
    });
  }

  Widget _buildRecordItem(BillingRecord record) {
    final isRecharge = record.type == 'recharge';
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: isRecharge ? Colors.green[50] : Colors.red[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRecharge ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: isRecharge ? Colors.green : Colors.red,
        ),
      ),
      title: Text(record.description),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt),
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
        ),
      ),
      trailing: Text(
        '${isRecharge ? '+' : '-'}¥${record.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16.sp,
          color: isRecharge ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 