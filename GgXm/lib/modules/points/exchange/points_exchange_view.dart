import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/coupon.dart';
import 'points_exchange_controller.dart';

class PointsExchangeView extends GetView<PointsExchangeController> {
  const PointsExchangeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分兑换'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed(Routes.MY_COUPONS),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTypeFilter(),
          _buildSortBar(),
          Expanded(child: _buildCouponList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索优惠券',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
        ),
        onChanged: controller.search,
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      height: 48.h,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Obx(() => FilterChip(
              label: const Text('全部'),
              selected: controller.selectedType.value == null,
              onSelected: (selected) {
                if (selected) {
                  controller.filterByType(null);
                }
              },
            )),
          ),
          ...CouponType.values.map((type) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Obx(() => FilterChip(
                label: Text(_getTypeLabel(type)),
                selected: controller.selectedType.value == type,
                onSelected: (selected) {
                  controller.filterByType(selected ? type : null);
                },
              )),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      height: 40.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildSortButton('积分', 'points'),
          SizedBox(width: 16.w),
          _buildSortButton('面值', 'value'),
          SizedBox(width: 16.w),
          _buildSortButton('有效期', 'endDate'),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value) {
    return Obx(() => TextButton(
      onPressed: () => controller.sort(value),
      style: TextButton.styleFrom(
        foregroundColor: controller.sortBy.value == value
            ? Colors.blue
            : Colors.grey[600],
      ),
      child: Text(label),
    ));
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
                '暂无可兑换优惠券',
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

  Widget _buildCouponCard(Coupon coupon) {
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
                  Text(
                    '${coupon.points}积分',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
                  if (coupon.isAvailable)
                    ElevatedButton(
                      onPressed: () => controller.exchangeCoupon(coupon),
                      child: const Text('立即兑换'),
                    )
                  else
                    OutlinedButton(
                      onPressed: null,
                      child: Text(
                        coupon.isExpired ? '已过期' : '已兑完',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
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
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.inventory_2,
                    size: 14.r,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '剩余${coupon.stock}张',
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 