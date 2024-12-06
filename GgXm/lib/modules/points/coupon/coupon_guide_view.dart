import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/user_coupon.dart';

class CouponGuideView extends StatelessWidget {
  final UserCoupon coupon;

  const CouponGuideView({
    Key? key,
    required this.coupon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用说明'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('优惠券信息', [
              _buildInfoItem('优惠券名称', coupon.name),
              _buildInfoItem('优惠券类型', _getTypeLabel(coupon.type)),
              _buildInfoItem('优惠券面值', coupon.valueText),
              _buildInfoItem('有效期', '${_formatDate(coupon.startDate)} 至 ${_formatDate(coupon.endDate)}'),
            ]),
            SizedBox(height: 24.h),
            if (coupon.useGuide != null)
              _buildSection('使用说明', [
                Text(
                  coupon.useGuide!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ]),
            SizedBox(height: 24.h),
            _buildSection('使用流程', [
              _buildStepItem(1, '打开相应平台或商家APP'),
              _buildStepItem(2, '选择商品加入购物车'),
              _buildStepItem(3, '进入结算页面'),
              _buildStepItem(4, '选择使用优惠券'),
              _buildStepItem(5, '输入优惠券码完成使用'),
            ]),
            SizedBox(height: 24.h),
            _buildSection('注意事项', [
              _buildNoticeItem('每张优惠券仅限使用一次'),
              _buildNoticeItem('请在有效期内使用'),
              _buildNoticeItem('部分商品可能不支持使用优惠券'),
              _buildNoticeItem('如有疑问请联系客服'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16.r,
            color: Colors.orange,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 