import 'package:get/get.dart';
import '../../models/advertiser.dart';
import '../../api/advertiser_api.dart';

class AdvertiserController extends GetxController {
  final AdvertiserApi _advertiserApi = AdvertiserApi();
  
  final advertiser = Rxn<Advertiser>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdvertiserInfo();
  }

  Future<void> loadAdvertiserInfo() async {
    isLoading.value = true;
    try {
      final response = await _advertiserApi.getInfo();
      advertiser.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recharge(double amount, String paymentMethod) async {
    try {
      final balance = await _advertiserApi.recharge(amount, paymentMethod);
      if (advertiser.value != null) {
        advertiser.value = Advertiser(
          id: advertiser.value!.id,
          name: advertiser.value!.name,
          type: advertiser.value!.type,
          contactPhone: advertiser.value!.contactPhone,
          status: advertiser.value!.status,
          createdAt: advertiser.value!.createdAt,
          balance: balance,
        );
      }
      Get.snackbar('提示', '充值成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _advertiserApi.updateSettings(settings);
      await loadAdvertiserInfo(); // 重新加载广告主信息
      Get.snackbar('提示', '设置更新成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 