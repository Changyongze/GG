import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/user_coupon.dart';
import 'my_coupons_controller.dart';

class MyCouponsView extends GetView<MyCouponsController> {
  const MyCouponsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的优惠券'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationSettings(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(child: _buildCouponList()),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 48.h,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterTab('未使用', 'available'),
          _buildFilterTab('已使用', 'used'),
          _buildFilterTab('已过期', 'expired'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String status) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      return GestureDetector(
        onTap: () => controller.filterByStatus(status),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2.h,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCouponList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.coupons.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 64.r,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16.h),
              Text(
                '暂无优惠券',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.POINTS_EXCHANGE),
                child: const Text('去兑换'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadCoupons,
        child: ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: controller.coupons.length,
          itemBuilder: (context, index) {
            return _buildCouponCard(controller.coupons[index]);
          },
        ),
      );
    });
  }

  Widget _buildCouponCard(UserCoupon coupon) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () => controller.viewCouponDetail(coupon),
        child: Container(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(coupon.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _getTypeLabel(coupon.type),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _getTypeColor(coupon.type),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(coupon).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      coupon.statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _getStatusColor(coupon),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                coupon.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                coupon.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Text(
                    coupon.valueText,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  if (coupon.isAvailable) ...[
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => controller.shareCoupon(coupon),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () => controller.useCoupon(coupon),
                      child: const Text('立即使用'),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14.r,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '有效期至${_formatDate(coupon.endDate)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(CouponType type) {
    switch (type) {
      case CouponType.discount:
        return '折扣券';
      case CouponType.cash:
        return '现金券';
      case CouponType.exchange:
        return '兑换券';
      case CouponType.gift:
        return '礼品券';
    }
  }

  Color _getTypeColor(CouponType type) {
    switch (type) {
      case CouponType.discount:
        return Colors.orange;
      case CouponType.cash:
        return Colors.red;
      case CouponType.exchange:
        return Colors.blue;
      case CouponType.gift:
        return Colors.purple;
    }
  }

  Color _getStatusColor(UserCoupon coupon) {
    if (coupon.isUsed) return Colors.grey;
    if (coupon.isExpired) return Colors.red;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showNotificationSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('提醒设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('优惠券过期提醒'),
              subtitle: const Text('优惠券即将过期时通知我'),
              trailing: Obx(() => Switch(
                value: controller.notificationEnabled.value,
                onChanged: (value) {
                  controller.toggleNotification(value);
                },
              )),
            ),
            ListTile(
              title: const Text('提前提醒时间'),
              subtitle: Obx(() => Text('${controller.notificationDays.value}天')),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showDaysSelector(),
              ),
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

  void _showDaysSelector() {
    Get.dialog(
      AlertDialog(
        title: const Text('选择提醒时间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 5, 7, 10, 15].map((days) {
            return RadioListTile<int>(
              title: Text('$days天'),
              value: days,
              groupValue: controller.notificationDays.value,
              onChanged: (value) {
                if (value != null) {
                  controller.updateNotificationDays(value);
                  Get.back();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
} 