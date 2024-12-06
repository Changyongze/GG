import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();
  
  final pushEnabled = true.obs;
  final soundEnabled = true.obs;
  final vibrationEnabled = true.obs;
  final locationEnabled = true.obs;
  final personalizationEnabled = true.obs;
  
  final cacheSize = '0.0MB'.obs;
  final version = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadCacheSize();
    loadVersion();
  }

  Future<void> loadSettings() async {
    pushEnabled.value = _storage.getBool('push_enabled') ?? true;
    soundEnabled.value = _storage.getBool('sound_enabled') ?? true;
    vibrationEnabled.value = _storage.getBool('vibration_enabled') ?? true;
    locationEnabled.value = _storage.getBool('location_enabled') ?? true;
    personalizationEnabled.value = _storage.getBool('personalization_enabled') ?? true;
  }

  void togglePush(bool value) {
    pushEnabled.value = value;
    _storage.setBool('push_enabled', value);
  }

  void toggleSound(bool value) {
    soundEnabled.value = value;
    _storage.setBool('sound_enabled', value);
  }

  void toggleVibration(bool value) {
    vibrationEnabled.value = value;
    _storage.setBool('vibration_enabled', value);
  }

  void toggleLocation(bool value) {
    locationEnabled.value = value;
    _storage.setBool('location_enabled', value);
  }

  void togglePersonalization(bool value) {
    personalizationEnabled.value = value;
    _storage.setBool('personalization_enabled', value);
  }

  Future<void> loadCacheSize() async {
    // TODO: 实现缓存大小计算
    cacheSize.value = '2.5MB';
  }

  Future<void> clearCache() async {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要清除缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // TODO: 实现缓存清理
              await Future.delayed(const Duration(seconds: 1));
              cacheSize.value = '0.0MB';
              Get.snackbar('提示', '缓存清理成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }

  Future<void> checkUpdate() async {
    // TODO: 实现版本检查
    Get.snackbar('提示', '当前已是最新版本');
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authService.logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 