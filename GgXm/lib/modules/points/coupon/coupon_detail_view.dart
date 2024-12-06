import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../models/coupon.dart';
import 'coupon_detail_controller.dart';

class CouponDetailView extends GetView<CouponDetailController> {
  const CouponDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('优惠券详情'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.coupon.value == null) {
          return const Center(child: Text('加载失败'));
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCouponCard(controller.coupon.value!),
                  SizedBox(height: 24.h),
                  _buildDetailSection('优惠券说明', controller.coupon.value!.description),
                  if (controller.coupon.value!.useGuide != null) ...[
                    SizedBox(height: 16.h),
                    _buildDetailSection(
                      '使用说明',
                      controller.coupon.value!.useGuide!,
                      showMore: true,
                      onTap: controller.showUseGuide,
                    ),
                  ],
                  SizedBox(height: 16.h),
                  _buildDetailSection(
                    '使用期限',
                    '${_formatDate(controller.coupon.value!.startDate)} 至 '
                    '${_formatDate(controller.coupon.value!.endDate)}',
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailSection(
                    '兑换限制',
                    '每人限兑${controller.coupon.value!.limit}张\n'
                    '剩余库存${controller.coupon.value!.stock}张',
                  ),
                  SizedBox(height: 80.h), // 为底部按钮留出空间
                ],
              ),
            ),
            _buildBottomBar(controller.coupon.value!),
          ],
        );
      }),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor(coupon.type),
            _getTypeColor(coupon.type).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _getTypeLabel(coupon.type),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${coupon.points}积分',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            coupon.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            coupon.valueText,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content, {
    bool showMore = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: showMore ? 3 : null,
            overflow: showMore ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Coupon coupon) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: coupon.isAvailable
                      ? () => controller.showExchangeConfirm()
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Obx(() => Text(
                    controller.isExchanging.value
                        ? '兑换中...'
                        : '立即兑换',
                  )),
                ),
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
        return '���金券';
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
    return DateFormat('yyyy-MM-dd').format(date);
  }
} 