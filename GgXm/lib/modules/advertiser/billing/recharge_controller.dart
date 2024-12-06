import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/billing_api.dart';

class RechargeController extends GetxController {
  final BillingApi _billingApi = BillingApi();
  
  final amountController = TextEditingController();
  final selectedAmount = 0.0.obs;
  final selectedPayment = 'alipay'.obs;
  final isLoading = false.obs;

  final amountOptions = [
    100.0,
    500.0,
    1000.0,
    2000.0,
    5000.0,
    10000.0,
  ];

  final paymentOptions = [
    {
      'value': 'alipay',
      'label': '支付宝支付',
      'icon': 'assets/images/alipay.png',
    },
    {
      'value': 'wechat',
      'label': '微信支付',
      'icon': 'assets/images/wechat.png',
    },
    {
      'value': 'bank',
      'label': '银行卡支付',
      'icon': 'assets/images/bank.png',
    },
  ];

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void selectAmount(double amount) {
    selectedAmount.value = amount;
    amountController.text = amount.toString();
  }

  void selectPayment(String payment) {
    selectedPayment.value = payment;
  }

  Future<void> recharge() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('错误', '请输入有效的充值金额');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _billingApi.recharge(
        amount,
        selectedPayment.value,
      );
      
      // TODO: 处理支付结果，跳转到支付页面或显示支付二维码
      Get.back(result: response);
      Get.snackbar('提示', '充值成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
} 