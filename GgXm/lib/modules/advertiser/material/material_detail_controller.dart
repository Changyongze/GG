import 'package:get/get.dart';
import '../../../models/ad_material.dart';
import '../../../api/ad_material_api.dart';

class MaterialDetailController extends GetxController {
  final AdMaterialApi _materialApi = AdMaterialApi();
  
  final material = Rxn<AdMaterial>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    material.value = Get.arguments as AdMaterial;
  }

  Future<void> deleteMaterial() async {
    try {
      await _materialApi.deleteMaterial(
        material.value!.campaignId,
        material.value!.id,
      );
      Get.back(result: true);
      Get.snackbar('提示', '素材删除成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 