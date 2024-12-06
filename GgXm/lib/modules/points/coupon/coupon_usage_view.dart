import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../models/coupon_usage.dart';
import '../../../models/user_coupon.dart';
import '../../../api/points_api.dart';

class CouponUsageView extends StatefulWidget {
  final UserCoupon coupon;

  const CouponUsageView({
    Key? key,
    required this.coupon,
  }) : super(key: key);

  @override
  State<CouponUsageView> createState() => _CouponUsageViewState();
}

class _CouponUsageViewState extends State<CouponUsageView> {
  final _pointsApi = Get.find<PointsApi>();
  List<CouponUsage> _usages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsages();
  }

  Future<void> _loadUsages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usages = await _pointsApi.getCouponUsages(widget.coupon.id);
      setState(() {
        _usages = usages;
      });
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用记录'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64.r,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '暂无使用记录',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: _usages.length,
                  itemBuilder: (context, index) {
                    return _buildUsageItem(_usages[index]);
                  },
                ),
    );
  }

  Widget _buildUsageItem(CouponUsage usage) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '订单号：${usage.orderNo}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(usage.usedAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountItem('订单金额', usage.orderAmount),
                _buildAmountItem('优惠金额', usage.discountAmount),
                _buildAmountItem(
                  '实付金额',
                  usage.orderAmount - usage.discountAmount,
                  highlight: true,
                ),
              ],
            ),
            if (usage.remark != null) ...[
              SizedBox(height: 12.h),
              Text(
                usage.remark!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountItem(String label, double amount, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: highlight ? FontWeight.bold : null,
            color: highlight ? Colors.red : null,
          ),
        ),
      ],
    );
  }
} 