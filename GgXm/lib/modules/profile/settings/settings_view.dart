import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSettingGroup(
              title: '通知设置',
              children: [
                _buildSwitchItem(
                  title: '推送通知',
                  value: controller.pushEnabled,
                  onChanged: controller.togglePush,
                ),
                _buildSwitchItem(
                  title: '声音提醒',
                  value: controller.soundEnabled,
                  onChanged: controller.toggleSound,
                ),
                _buildSwitchItem(
                  title: '震动提醒',
                  value: controller.vibrationEnabled,
                  onChanged: controller.toggleVibration,
                ),
              ],
            ),
            _buildSettingGroup(
              title: '隐私设置',
              children: [
                _buildSwitchItem(
                  title: '位置信息',
                  value: controller.locationEnabled,
                  onChanged: controller.toggleLocation,
                ),
                _buildSwitchItem(
                  title: '个性化推荐',
                  value: controller.personalizationEnabled,
                  onChanged: controller.togglePersonalization,
                ),
              ],
            ),
            _buildSettingGroup(
              title: '其他设置',
              children: [
                _buildMenuItem(
                  title: '清除缓存',
                  trailing: Obx(() => Text(
                    controller.cacheSize.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  )),
                  onTap: controller.clearCache,
                ),
                _buildMenuItem(
                  title: '检查更新',
                  trailing: Obx(() => Text(
                    'v${controller.version}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  )),
                  onTap: controller.checkUpdate,
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Obx(() => Switch(
        value: value.value,
        onChanged: onChanged,
      )),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
} 