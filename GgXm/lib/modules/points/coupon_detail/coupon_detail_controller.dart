import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/coupon.dart';
import '../../../services/auth_service.dart';
import '../../../api/points_api.dart';

class CouponDetailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final PointsApi _pointsApi = PointsApi();
  
  late final Coupon coupon;
  final canExchange = true.obs;
  final exchangeButtonText = '立即兑换'.obs;
  
  @override
  void onInit() {
    super.onInit();
    coupon = Get.arguments as Coupon;
    checkExchangeStatus();
  }

  void checkExchangeStatus() {
    if (coupon.stock <= 0) {
      canExchange.value = false;
      exchangeButtonText.value = '已售罄';
      return;
    }

    if (_authService.currentUser.value?.points ?? 0 < coupon.points) {
      canExchange.value = false;
      exchangeButtonText.value = '积分不足';
      return;
    }

    if (coupon.validUntil.isBefore(DateTime.now())) {
      canExchange.value = false;
      exchangeButtonText.value = '已过期';
      return;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  List<String> formatRules() {
    final rules = <String>[];
    
    if (coupon.type == 'discount') {
      rules.add('${coupon.rules['discount']}折优惠');
    } else if (coupon.type == 'amount') {
      rules.add('满${coupon.rules['min_amount']}元减${coupon.rules['discount_amount']}元');
    }
    
    if (coupon.rules['use_limit'] != null) {
      rules.add('每人限兑${coupon.rules['use_limit']}张');
    }
    
    if (coupon.rules['use_time'] != null) {
      rules.add('使用时间: ${coupon.rules['use_time']}');
    }
    
    if (coupon.rules['use_scope'] != null) {
      rules.add('使用范围: ${coupon.rules['use_scope']}');
    }
    
    return rules;
  }

  void exchangeCoupon() async {
    try {
      await _pointsApi.exchangeCoupon(coupon.id);
      Get.back(result: true);
      Get.snackbar('提示', '兑换成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 