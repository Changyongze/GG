import 'package:get/get.dart';
import '../../../models/report_template.dart';
import '../../../api/report_api.dart';

class TemplateListController extends GetxController {
  final ReportApi _reportApi = ReportApi();
  
  final templates = <ReportTemplate>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final response = await _reportApi.getTemplates();
      templates.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _reportApi.deleteTemplate(id);
      templates.removeWhere((t) => t.id == id);
      Get.snackbar('提示', '模板删除成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void editTemplate(ReportTemplate template) {
    Get.toNamed(
      Routes.TEMPLATE_EDIT,
      arguments: template,
    );
  }

  void createTemplate() {
    Get.toNamed(Routes.TEMPLATE_EDIT);
  }
} 