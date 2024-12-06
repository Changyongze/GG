import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/auth/register/register_binding.dart';
import '../modules/auth/profile_setup/profile_setup_view.dart';
import '../modules/auth/profile_setup/profile_setup_binding.dart';
import '../modules/ad/ad_detail/ad_detail_view.dart';
import '../modules/ad/ad_detail/ad_detail_binding.dart';
import '../modules/points/points_mall/points_mall_view.dart';
import '../modules/points/points_mall/points_mall_binding.dart';
import '../modules/points/coupon_detail/coupon_detail_view.dart';
import '../modules/points/coupon_detail/coupon_detail_binding.dart';
import '../modules/points/points_history/points_history_view.dart';
import '../modules/points/points_history/points_history_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/settings/settings_view.dart';
import '../modules/profile/settings/settings_binding.dart';
import '../modules/profile/profile_edit/profile_edit_view.dart';
import '../modules/profile/profile_edit/profile_edit_binding.dart';
import '../modules/points/my_coupons/my_coupons_view.dart';
import '../modules/points/my_coupons/my_coupons_binding.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/notifications/notifications_binding.dart';
import '../modules/help/help_center_view.dart';
import '../modules/help/help_center_binding.dart';
import '../modules/about/about_view.dart';
import '../modules/about/about_binding.dart';
import '../modules/ad/ad_prediction/ad_prediction_view.dart';
import '../modules/ad/ad_prediction/ad_prediction_binding.dart';
import '../modules/ad/ad_suggestion/ad_suggestion_view.dart';
import '../modules/ad/ad_suggestion/ad_suggestion_binding.dart';
import '../modules/ad/ad_comparison/ad_comparison_view.dart';
import '../modules/ad/ad_comparison/ad_comparison_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_SETUP,
      page: () => const ProfileSetupView(),
      binding: ProfileSetupBinding(),
    ),
    GetPage(
      name: Routes.AD_DETAIL,
      page: () => const AdDetailView(),
      binding: AdDetailBinding(),
    ),
    GetPage(
      name: Routes.POINTS_MALL,
      page: () => const PointsMallView(),
      binding: PointsMallBinding(),
    ),
    GetPage(
      name: Routes.COUPON_DETAIL,
      page: () => const CouponDetailView(),
      binding: CouponDetailBinding(),
    ),
    GetPage(
      name: Routes.POINTS_HISTORY,
      page: () => const PointsHistoryView(),
      binding: PointsHistoryBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_EDIT,
      page: () => const ProfileEditView(),
      binding: ProfileEditBinding(),
    ),
    GetPage(
      name: Routes.MY_COUPONS,
      page: () => const MyCouponsView(),
      binding: MyCouponsBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: Routes.HELP_CENTER,
      page: () => const HelpCenterView(),
      binding: HelpCenterBinding(),
    ),
    GetPage(
      name: Routes.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: Routes.AD_PREDICTION,
      page: () => const AdPredictionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdPredictionController());
      }),
    ),
    GetPage(
      name: Routes.AD_SUGGESTION,
      page: () => const AdSuggestionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdSuggestionController());
      }),
    ),
    GetPage(
      name: Routes.AD_COMPARISON,
      page: () => const AdComparisonView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdComparisonController());
      }),
    ),
  ];
} 