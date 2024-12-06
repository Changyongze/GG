import 'package:get/get.dart';
import '../../../models/ad_campaign.dart';
import '../../../api/ad_campaign_api.dart';

class CampaignDetailController extends GetxController {
  final AdCampaignApi _campaignApi = AdCampaignApi();
  
  final campaign = Rxn<AdCampaign>();
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final dateRange = RxPair<DateTime, DateTime>(
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now(),
  );

  @override
  void onInit() {
    super.onInit();
    campaign.value = Get.arguments as AdCampaign;
    loadCampaignStats();
  }

  Future<void> loadCampaignStats() async {
    isLoading.value = true;
    try {
      final stats = await _campaignApi.getCampaignStats(
        campaign.value!.id,
        startDate: dateRange.first,
        endDate: dateRange.second,
      );
      campaign.value = AdCampaign(
        id: campaign.value!.id,
        advertiserId: campaign.value!.advertiserId,
        title: campaign.value!.title,
        description: campaign.value!.description,
        videoUrl: campaign.value!.videoUrl,
        coverUrl: campaign.value!.coverUrl,
        status: campaign.value!.status,
        category: campaign.value!.category,
        targetingRules: campaign.value!.targetingRules,
        budgetSettings: campaign.value!.budgetSettings,
        startDate: campaign.value!.startDate,
        endDate: campaign.value!.endDate,
        createdAt: campaign.value!.createdAt,
        updatedAt: campaign.value!.updatedAt,
        stats: stats,
      );
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStats() async {
    isRefreshing.value = true;
    try {
      await loadCampaignStats();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> updateStatus(String status) async {
    try {
      await _campaignApi.updateCampaignStatus(campaign.value!.id, status);
      campaign.value = AdCampaign(
        id: campaign.value!.id,
        advertiserId: campaign.value!.advertiserId,
        title: campaign.value!.title,
        description: campaign.value!.description,
        videoUrl: campaign.value!.videoUrl,
        coverUrl: campaign.value!.coverUrl,
        status: status,
        category: campaign.value!.category,
        targetingRules: campaign.value!.targetingRules,
        budgetSettings: campaign.value!.budgetSettings,
        startDate: campaign.value!.startDate,
        endDate: campaign.value!.endDate,
        createdAt: campaign.value!.createdAt,
        updatedAt: DateTime.now(),
        stats: campaign.value!.stats,
      );
      Get.snackbar('提示', '状态更新成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: dateRange.first,
        end: dateRange.second,
      ),
    );
    
    if (picked != null) {
      dateRange.value = RxPair(picked.start, picked.end);
      await loadCampaignStats();
    }
  }
} 