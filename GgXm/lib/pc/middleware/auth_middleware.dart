import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/pc_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<PCAuthController>();
    
    // 如果用户未登录且不在登录页面,重定向到登录页面
    if (!authController.isLoggedIn && route != PCRoutes.LOGIN) {
      return const RouteSettings(name: PCRoutes.LOGIN);
    }
    
    // 如果用户已登录且在登录页面,重定向到仪表盘
    if (authController.isLoggedIn && route == PCRoutes.LOGIN) {
      return const RouteSettings(name: PCRoutes.DASHBOARD);
    }
    
    return null;
  }
} 