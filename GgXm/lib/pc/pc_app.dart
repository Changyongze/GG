import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/pc_routes.dart';
import 'controllers/auth_controller.dart';

class PCApp extends StatelessWidget {
  const PCApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '广告积分管理系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: PCRoutes.LOGIN,
      getPages: PCPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
} 