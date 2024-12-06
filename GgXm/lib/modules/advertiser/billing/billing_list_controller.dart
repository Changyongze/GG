import 'package:get/get.dart';
import '../../../models/billing_record.dart';
import '../../../api/billing_api.dart';

class BillingListController extends GetxController {
  final BillingApi _billingApi = BillingApi();
  
  final records = <BillingRecord>[].obs;
  final balance = 0.0.obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final selectedType = 'all'.obs;
  static const pageSize = 20;

  final typeOptions = [
    {'value': 'all', 'label': '全部'},
    {'value': 'recharge', 'label': '充值'},
    {'value': 'consume', 'label': '消费'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadBalance();
    loadRecords(refresh: true);
  }

  Future<void> loadBalance() async {
    try {
      final response = await _billingApi.getBalance();
      balance.value = response['balance']?.toDouble() ?? 0.0;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> loadRecords({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final response = await _billingApi.getBillingRecords(
        type: selectedType.value == 'all' ? null : selectedType.value,
        page: currentPage.value,
        pageSize: pageSize,
      );
      
      if (refresh) {
        records.clear();
      }
      
      if (response.length < pageSize) {
        hasMore.value = false;
      }
      
      records.addAll(response);
      currentPage.value++;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRecords() async {
    await loadRecords(refresh: true);
  }

  void filterByType(String type) {
    if (type == selectedType.value) return;
    selectedType.value = type;
    loadRecords(refresh: true);
  }

  void recharge() {
    Get.toNamed(Routes.RECHARGE);
  }
} 