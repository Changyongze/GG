import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'help_center_controller.dart';

class HelpCenterView extends GetView<HelpCenterController> {
  const HelpCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助中心'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildQuickActions(),
            _buildFAQList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: '搜索常见问题',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
        ),
        onChanged: controller.searchFAQs,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速通道',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.headset_mic,
                title: '在线客服',
                onTap: controller.contactCustomerService,
              ),
              _buildQuickActionItem(
                icon: Icons.feedback,
                title: '意见反馈',
                onTap: controller.submitFeedback,
              ),
              _buildQuickActionItem(
                icon: Icons.phone,
                title: '联系我们',
                onTap: controller.contactUs,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 24.r,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ExpansionPanelList(
          elevation: 0,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (index, isExpanded) {
            controller.toggleFAQ(index);
          },
          children: controller.filteredFAQs.map((faq) {
            final index = controller.filteredFAQs.indexOf(faq);
            return ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(
                    faq.question,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              body: Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              isExpanded: controller.expandedIndexes.contains(index),
            );
          }).toList(),
        );
      }),
    );
  }
} 