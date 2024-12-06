import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  final version = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppVersion();
  }

  Future<void> loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }

  void openUserAgreement() async {
    const url = 'https://example.com/user-agreement';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('错误', '无法打开用户协议');
    }
  }

  void openPrivacyPolicy() async {
    const url = 'https://example.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('错误', '无法打开隐私政策');
    }
  }

  void openDisclaimer() async {
    const url = 'https://example.com/disclaimer';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('错误', '无法打开免责声明');
    }
  }
} 