import 'package:get/get.dart';
import '../../../models/campaign_analysis.dart';
import '../../../api/ad_campaign_api.dart';

class CampaignAnalysisController extends GetxController {
  final AdCampaignApi _campaignApi = AdCampaignApi();
  
  final analysis = Rxn<CampaignAnalysis>();
  final isLoading = false.obs;
  final String campaignId;

  CampaignAnalysisController() : campaignId = Get.arguments as String;

  @override
  void onInit() {
    super.onInit();
    loadAnalysis();
  }

  Future<void> loadAnalysis() async {
    isLoading.value = true;
    try {
      final response = await _campaignApi.getCampaignAnalysis(campaignId);
      analysis.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
} 