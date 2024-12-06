import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routes/routes.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化核心服务
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AuthService().init());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      builder: (context, child) => GetMaterialApp(
        title: '广告积分管理系统',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: Routes.LOGIN,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
      ),
    );
  }
} 