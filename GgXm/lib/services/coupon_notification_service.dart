import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/points_api.dart';
import '../models/user_coupon.dart';

class CouponNotificationService extends GetxService {
  final PointsApi _pointsApi = Get.find<PointsApi>();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<CouponNotificationService> init() async {
    // 初始化通知设置
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 启动定时检查
    _startPeriodicCheck();
    
    return this;
  }

  void _startPeriodicCheck() {
    // 每天检查一次
    Future.delayed(const Duration(minutes: 1), () async {
      await checkExpiringCoupons();
      _startPeriodicCheck();
    });
  }

  Future<void> checkExpiringCoupons() async {
    try {
      final coupons = await _pointsApi.getExpiringCoupons();
      for (var coupon in coupons) {
        await _showExpiringNotification(coupon);
      }
    } catch (e) {
      print('检查优惠券过期失败: $e');
    }
  }

  Future<void> _showExpiringNotification(UserCoupon coupon) async {
    final daysLeft = coupon.endDate.difference(DateTime.now()).inDays;
    
    const androidDetails = AndroidNotificationDetails(
      'coupon_expiring',
      '优惠券过期提醒',
      channelDescription: '提醒优惠券即将过期',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      coupon.hashCode,
      '优惠券即将过期',
      '您的${coupon.name}将在${daysLeft}天后过期，请及时使用',
      details,
      payload: 'coupon:${coupon.id}',
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload?.startsWith('coupon:') == true) {
      final couponId = response.payload!.split(':')[1];
      Get.toNamed(
        Routes.COUPON_DETAIL,
        arguments: couponId,
      );
    }
  }
} 