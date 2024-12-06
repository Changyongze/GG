import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/side_menu.dart';
import '../widgets/top_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    Key? key, 
    required this.child,
  }) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 侧边菜单
          const SideMenu(),
          
          // 主内容区
          Expanded(
            child: Column(
              children: [
                // 顶部栏
                const TopBar(),
                
                // 内容区
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 