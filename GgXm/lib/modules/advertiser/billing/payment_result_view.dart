import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'payment_result_controller.dart';

class PaymentResultView extends GetView<PaymentResultController> {
  const PaymentResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.goBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('支付结果'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.goBack,
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isSuccess.value
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  size: 64.r,
                  color: controller.isSuccess.value ? Colors.green : Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.isSuccess.value ? '支付成功' : '支付失败',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '¥${controller.amount.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32.h),
                if (controller.isSuccess.value)
                  ElevatedButton(
                    onPressed: controller.goBack,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: const Text('完成'),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: controller.retry,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: const Text('重新支付'),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        onPressed: controller.goBack,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: const Text('返回'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
} 