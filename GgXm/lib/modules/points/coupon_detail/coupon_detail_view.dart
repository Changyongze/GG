import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'coupon_detail_controller.dart';

class CouponDetailView extends GetView<CouponDetailController> {
  const CouponDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('优惠券详情'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCouponImage(),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCouponInfo(),
                  SizedBox(height: 24.h),
                  _buildRules(),
                  SizedBox(height: 24.h),
                  _buildDescription(),
                  SizedBox(height: 32.h),
                  _buildExchangeButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        controller.coupon.imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCouponInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.coupon.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.monetization_on, size: 16.r, color: Colors.orange),
            SizedBox(width: 4.w),
            Text(
              '${controller.coupon.points}积分',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '库存: ${controller.coupon.stock}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          '有效期至: ${controller.formatDate(controller.coupon.validUntil)}',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '使用规则',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ...controller.formatRules().map((rule) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(fontSize: 14.sp)),
              Expanded(
                child: Text(
                  rule,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '详细说明',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          controller.coupon.description,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.canExchange.value 
        ? () => controller.exchangeCoupon()
        : null,
      child: Text(
        controller.exchangeButtonText.value,
        style: TextStyle(fontSize: 16.sp),
      ),
    ));
  }
} 