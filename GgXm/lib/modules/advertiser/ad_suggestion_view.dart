import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/ad.dart';
import 'ad_suggestion_controller.dart';

class AdSuggestionView extends GetView<AdSuggestionController> {
  const AdSuggestionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投放建议'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              _buildAdInfo(),
              SizedBox(height: 24.h),
              _buildBudgetSuggestion(),
              SizedBox(height: 24.h),
              _buildAudienceSuggestion(),
              SizedBox(height: 24.h),
              _buildPlacementSuggestion(),
              SizedBox(height: 24.h),
              _buildTimingSuggestion(),
              SizedBox(height: 24.h),
              _buildOptimizationTips(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAdInfo() {
    final ad = controller.ad;
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.network(
            ad.coverUrl,
            width: 60.w,
            height: 60.w,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(ad.title),
        subtitle: Text(ad.description),
      ),
    );
  }

  Widget _buildBudgetSuggestion() {
    return _buildSuggestionCard(
      '预算建议',
      Icons.account_balance_wallet,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSuggestionItem(
            '建议日预算',
            '¥${controller.suggestions.value.recommendedBudget}',
            '基于历史数据和竞品分析',
          ),
          SizedBox(height: 12.h),
          _buildSuggestionItem(
            '预计ROI',
            '${(controller.suggestions.value.estimatedRoi * 100).toStringAsFixed(1)}%',
            '投资回报率预估',
          ),
          if (controller.suggestions.value.budgetTips.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...controller.suggestions.value.budgetTips.map((tip) => _buildTipItem(tip)),
          ],
        ],
      ),
    );
  }

  Widget _buildAudienceSuggestion() {
    return _buildSuggestionCard(
      '受众建议',
      Icons.people,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最佳目标受众',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.suggestions.value.recommendedAudiences.map((audience) {
              return Chip(
                label: Text(audience),
                backgroundColor: Colors.blue.withOpacity(0.1),
              );
            }).toList(),
          ),
          if (controller.suggestions.value.audienceTips.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...controller.suggestions.value.audienceTips.map((tip) => _buildTipItem(tip)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlacementSuggestion() {
    return _buildSuggestionCard(
      '投放位置建议',
      Icons.place,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐投放位置',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          ...controller.suggestions.value.recommendedPlacements.map((placement) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle, color: Colors.green, size: 20.r),
              title: Text(placement.name),
              subtitle: Text(
                placement.reason,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Text(
                '${(placement.score * 100).toStringAsFixed(0)}分',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimingSuggestion() {
    return _buildSuggestionCard(
      '投放时间建议',
      Icons.access_time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSuggestionItem(
            '最佳投放时段',
            controller.suggestions.value.bestTimeRange,
            '用户活跃度最高的时间段',
          ),
          SizedBox(height: 12.h),
          _buildSuggestionItem(
            '建议投放周期',
            '${controller.suggestions.value.recommendedDuration}天',
            '基于广告目标和预算',
          ),
          if (controller.suggestions.value.timingTips.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...controller.suggestions.value.timingTips.map((tip) => _buildTipItem(tip)),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizationTips() {
    return _buildSuggestionCard(
      '优化建议',
      Icons.trending_up,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.suggestions.value.optimizationTips.map((tip) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16.r,
                  color: Colors.orange,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestionCard(String title, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String label, String value, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16.r,
            color: Colors.blue,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 