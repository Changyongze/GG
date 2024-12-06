import 'package:get/get.dart';
import '../../../models/ad_material.dart';
import '../../../api/ad_material_api.dart';

class MaterialListController extends GetxController {
  final AdMaterialApi _materialApi = AdMaterialApi();
  
  final materials = <AdMaterial>[].obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  static const pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadMaterials(refresh: true);
  }

  Future<void> loadMaterials({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final response = await _materialApi.getMaterials(
        'current_campaign_id', // TODO: 替换为实际广告计划ID
        page: currentPage.value,
        pageSize: pageSize,
      );
      
      if (refresh) {
        materials.clear();
      }
      
      if (response.length < pageSize) {
        hasMore.value = false;
      }
      
      materials.addAll(response);
      currentPage.value++;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMaterials() async {
    await loadMaterials(refresh: true);
  }

  Future<void> deleteMaterial(String id) async {
    try {
      await _materialApi.deleteMaterial('current_campaign_id', id);
      materials.removeWhere((m) => m.id == id);
      Get.snackbar('提示', '素材删除成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void uploadMaterial() {
    Get.toNamed(Routes.MATERIAL_UPLOAD);
  }

  void showMaterialDetail(AdMaterial material) {
    Get.toNamed(
      Routes.MATERIAL_DETAIL,
      arguments: material,
    );
  }
} 