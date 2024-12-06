import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/pc_routes.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        children: [
          // Logo
          Container(
            height: 64,
            padding: const EdgeInsets.all(16),
            child: Image.asset('assets/images/logo.png'),
          ),
          
          // 菜单项
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: '仪表盘',
                  route: PCRoutes.DASHBOARD,
                ),
                _buildMenuItem(
                  icon: Icons.campaign,
                  title: '广告管理',
                  route: PCRoutes.ADS,
                ),
                _buildMenuItem(
                  icon: Icons.analytics,
                  title: '数据分析',
                  route: PCRoutes.ANALYTICS, 
                ),
                _buildMenuItem(
                  icon: Icons.card_giftcard,
                  title: '优惠券管理',
                  route: PCRoutes.COUPONS,
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: '用户管理',
                  route: PCRoutes.USERS,
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: '系统设置',
                  route: PCRoutes.SETTINGS,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = Get.currentRoute == route;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => Get.toNamed(route),
    );
  }
} 