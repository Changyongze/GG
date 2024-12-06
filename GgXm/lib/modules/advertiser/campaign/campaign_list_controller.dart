import 'package:get/get.dart';
import '../../../models/ad_campaign.dart';
import '../../../api/ad_api.dart';

class CampaignListController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  
  final campaigns = <AdCampaign>[].obs;
  final isLoading = false.obs;
  final selectedStatus = Rxn<CampaignStatus>();
  final dateRange = Rxn<DateTimeRange>();

  @override
  void onInit() {
    super.onInit();
    loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    isLoading.value = true;
    try {
      final response = await _adApi.getCampaigns(
        status: selectedStatus.value?.name,
        startDate: dateRange.value?.start,
        endDate: dateRange.value?.end,
      );
      campaigns.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String id, CampaignStatus status) async {
    try {
      await _adApi.updateCampaignStatus(id, status);
      await loadCampaigns();
      Get.snackbar('提示', '状态更新成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void createCampaign() {
    Get.toNamed(Routes.CAMPAIGN_CREATE);
  }

  void editCampaign(AdCampaign campaign) {
    Get.toNamed(
      Routes.CAMPAIGN_EDIT,
      arguments: campaign,
    );
  }

  void viewStats(AdCampaign campaign) {
    Get.toNamed(
      Routes.CAMPAIGN_STATS,
      arguments: campaign.id,
    );
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: dateRange.value,
    );
    
    if (picked != null) {
      dateRange.value = picked;
      await loadCampaigns();
    }
  }
} 