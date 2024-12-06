import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'points_mall_controller.dart';

class PointsMallView extends GetView<PointsMallController> {
  const PointsMallView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分商城'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildCouponList(),
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
                '我的积分',
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
          TextButton(
            onPressed: () => Get.toNamed(Routes.POINTS_HISTORY),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('积分明细'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.coupons.isEmpty) {
        return const Center(child: Text('暂无可兑换优惠券'));
      }

      return RefreshIndicator(
        onRefresh: controller.refreshCoupons,
        child: GridView.builder(
          padding: EdgeInsets.all(16.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.r,
            crossAxisSpacing: 16.r,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.coupons.length,
          itemBuilder: (context, index) {
            final coupon = controller.coupons[index];
            return _buildCouponCard(coupon);
          },
        ),
      );
    });
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Card(
      child: InkWell(
        onTap: () => controller.showCouponDetail(coupon),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                coupon.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, size: 16.r, color: Colors.orange),
                      SizedBox(width: 4.w),
                      Text(
                        '${coupon.points}积分',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () => controller.exchangeCoupon(coupon),
                    child: const Text('立即兑换'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 