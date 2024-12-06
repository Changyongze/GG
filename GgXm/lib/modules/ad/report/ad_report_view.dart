import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/ad.dart';
import 'ad_report_controller.dart';

class AdReportView extends GetView<AdReportController> {
  const AdReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('举报广告'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '请选择举报原因',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...controller.reportReasons.map((reason) => _buildReasonItem(reason)),
            SizedBox(height: 24.h),
            Text(
              '补充说明（选填）',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请详细描述您遇到的问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.selectedReason.value.isEmpty
                    ? null
                    : controller.submitReport,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  controller.isSubmitting.value ? '提交中...' : '提交举报',
                  style: TextStyle(fontSize: 16.sp),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(String reason) {
    return Obx(() {
      final isSelected = controller.selectedReason.value == reason;
      return InkWell(
        onTap: () => controller.selectReason(reason),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Text(
                reason,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
} 