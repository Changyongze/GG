import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'recharge_controller.dart';

class RechargeView extends GetView<RechargeController> {
  const RechargeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户充值'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            _buildAmountInput(),
            SizedBox(height: 24.h),
            _buildAmountOptions(),
            SizedBox(height: 24.h),
            _buildPaymentOptions(),
            SizedBox(height: 32.h),
            _buildSubmitButton(),
          ],
        );
      }),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '充值金额',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: controller.amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '请输入充值金额',
            prefixText: '¥',
            prefixStyle: TextStyle(
              fontSize: 16.sp,
              color: Colors.black,
            ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            final amount = double.tryParse(value);
            if (amount != null) {
              controller.selectedAmount.value = amount;
            }
          },
        ),
      ],
    );
  }

  Widget _buildAmountOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷金额',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 2.5,
          ),
          itemCount: controller.amountOptions.length,
          itemBuilder: (context, index) {
            final amount = controller.amountOptions[index];
            return Obx(() => OutlinedButton(
              onPressed: () => controller.selectAmount(amount),
              style: OutlinedButton.styleFrom(
                backgroundColor: controller.selectedAmount.value == amount
                    ? Colors.blue[50]
                    : null,
                side: BorderSide(
                  color: controller.selectedAmount.value == amount
                      ? Colors.blue
                      : Colors.grey[300]!,
                ),
              ),
              child: Text(
                '¥${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: controller.selectedAmount.value == amount
                      ? Colors.blue
                      : Colors.black,
                ),
              ),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付方式',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ...controller.paymentOptions.map((option) => Obx(() => RadioListTile(
          value: option['value'],
          groupValue: controller.selectedPayment.value,
          onChanged: (value) {
            if (value != null) controller.selectPayment(value);
          },
          title: Row(
            children: [
              Image.asset(
                option['icon'] as String,
                width: 24.r,
                height: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(option['label'] as String),
            ],
          ),
        ))),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: controller.recharge,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
      ),
      child: const Text('确认充值'),
    );
  }
} 