import 'package:get/get.dart';
import '../../../api/billing_api.dart';
import '../../../routes/app_pages.dart';

class PaymentResultController extends GetxController {
  final BillingApi _billingApi = BillingApi();
  
  final orderId = ''.obs;
  final amount = 0.0.obs;
  final paymentMethod = ''.obs;
  final isSuccess = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    orderId.value = args['order_id'] as String;
    amount.value = args['amount'] as double;
    paymentMethod.value = args['payment_method'] as String;
    _startCheckingPaymentStatus();
  }

  void _startCheckingPaymentStatus() {
    // 每3秒检查一次支付状态，最多检查20次（1分钟）
    int checkCount = 0;
    Future.doWhile(() async {
      await checkPaymentStatus();
      checkCount++;
      
      // 如果支付成功或者检查次数超过20次，停止检查
      if (isSuccess.value || checkCount >= 20) {
        return false;
      }
      
      // 等待3秒后继续检查
      await Future.delayed(const Duration(seconds: 3));
      return true;
    });
  }

  Future<void> checkPaymentStatus() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final response = await _billingApi.checkPaymentStatus(orderId.value);
      final status = response['status'] as String;
      
      switch (status) {
        case 'success':
          isSuccess.value = true;
          await _billingApi.getBalance(); // 刷新余额
          break;
        case 'failed':
          isSuccess.value = false;
          errorMessage.value = response['message'] ?? '支付失败';
          break;
        case 'pending':
          // 继续等待
          break;
        default:
          errorMessage.value = '未知状态';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    // 返回到账单列表页面
    Get.until((route) => route.settings.name == Routes.BILLING_LIST);
  }

  void retry() {
    // 返回到充值页面重新支付
    Get.back();
  }

  @override
  void onClose() {
    // 清理资源
    super.onClose();
  }
} 