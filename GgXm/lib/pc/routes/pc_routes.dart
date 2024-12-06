abstract class PCRoutes {
  static const DASHBOARD = '/pc/dashboard';
  static const ADS = '/pc/ads';
  static const ANALYTICS = '/pc/analytics';
  static const COUPONS = '/pc/coupons';
  static const USERS = '/pc/users';
  static const SETTINGS = '/pc/settings';
  static const PROFILE = '/pc/profile';
  static const LOGIN = '/pc/login';
}

class PCPages {
  static final routes = [
    GetPage(
      name: PCRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: PCRoutes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: PCRoutes.ADS,
      page: () => const AdsView(),
      binding: AdsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: PCRoutes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: PCRoutes.COUPONS,
      page: () => const CouponsView(),
      binding: CouponsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: PCRoutes.USERS,
      page: () => const UsersView(),
      binding: UsersBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: PCRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: PCRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
} 