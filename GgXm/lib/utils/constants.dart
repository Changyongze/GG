class ApiConstants {
  static const String baseUrl = 'http://your-api-domain.com/api';
  static const String apiVersion = 'v1';
  
  // API路径
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendCode = '/auth/send-code';
  static const String updateProfile = '/user/profile';
  
  // 存储键
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  
  // 广告相关
  static const String ads = '/ads';
  static const String adDetail = '/ads/{id}';
  
  // 广告互动
  static const String earnPoints = '/ads/{id}/earn-points';
  static const String likeAd = '/ads/{id}/like';
  static const String shareAd = '/ads/{id}/share';
  
  // 积分相关
  static const String coupons = '/coupons';
  static const String userPoints = '/user/points';
  static const String pointRecords = '/user/point-records';
  static const String userCoupons = '/user/coupons';
  
  // 消息通知相关
  static const String notifications = '/notifications';
  static const String markAllNotificationsAsRead = '/notifications/mark-all-read';
  
  // 帮助中心相关
  static const String faqs = '/faqs';
  
  // 广告主相关
  static const String advertiserRegister = '/advertiser/register';
  static const String advertiserInfo = '/advertiser/info';
  static const String advertiserRecharge = '/advertiser/recharge';
  static const String advertiserBilling = '/advertiser/billing';
  static const String advertiserSettings = '/advertiser/settings';
  
  // 广告计划相关
  static const String adCampaigns = '/ad-campaigns';
  
  // 账单相关
  static const String billingRecords = '/billing/records';
  static const String advertiserBalance = '/advertiser/balance';
  static const String advertiserRecharge = '/advertiser/recharge';
  static const String billingStats = '/billing/stats';
  
  // 数据统计相关
  static const String advertiserStats = '/advertiser/stats';
} 