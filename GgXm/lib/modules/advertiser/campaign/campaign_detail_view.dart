import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'campaign_detail_controller.dart';
import 'video_player_view.dart';
import 'widgets/campaign_stats_chart.dart';

class CampaignDetailView extends GetView<CampaignDetailController> {
  const CampaignDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('广告计划详情'),
        actions: [
          PopupMenuButton<String>(
            onSelected: controller.updateStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'active',
                child: Text('开始投放'),
              ),
              const PopupMenuItem(
                value: 'paused',
                child: Text('暂停投放'),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final campaign = controller.campaign.value!;
        return RefreshIndicator(
          onRefresh: controller.refreshStats,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildBasicInfo(campaign),
              SizedBox(height: 16.h),
              _buildStatsCard(campaign),
              SizedBox(height: 16.h),
              _buildTargetingInfo(campaign),
              SizedBox(height: 16.h),
              _buildBudgetInfo(campaign),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBasicInfo(AdCampaign campaign) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Image.network(
                  campaign.coverUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Center(
                  child: IconButton(
                    icon: Icon(Icons.play_circle_outline, size: 48.r),
                    onPressed: () {
                      Get.to(() => VideoPlayerView(
                        videoUrl: campaign.videoUrl,
                        title: campaign.title,
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(campaign.status),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  campaign.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    Chip(
                      label: Text(campaign.category),
                      backgroundColor: Colors.blue[50],
                    ),
                    Chip(
                      label: Text(
                        '${DateFormat('yyyy-MM-dd').format(campaign.startDate)} 开始',
                      ),
                      backgroundColor: Colors.green[50],
                    ),
                    if (campaign.endDate != null)
                      Chip(
                        label: Text(
                          '${DateFormat('yyyy-MM-dd').format(campaign.endDate!)} 结束',
                        ),
                        backgroundColor: Colors.orange[50],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AdCampaign campaign) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '数据统计',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.selectDateRange,
                  child: Obx(() => Text(
                    '${DateFormat('MM-dd').format(controller.dateRange.first)} 至 '
                    '${DateFormat('MM-dd').format(controller.dateRange.second)}',
                  )),
                ),
              ],
            ),
          ),
          if (campaign.stats != null && campaign.stats!['daily_stats'] != null) ...[
            const Divider(),
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: '展示量'),
                      Tab(text: '点击量'),
                      Tab(text: '点击率'),
                      Tab(text: '花费'),
                    ],
                  ),
                  SizedBox(
                    height: 200.h,
                    child: TabBarView(
                      children: [
                        CampaignStatsChart(
                          dailyStats: List<Map<String, dynamic>>.from(
                            campaign.stats!['daily_stats'],
                          ),
                          type: 'impressions',
                        ),
                        CampaignStatsChart(
                          dailyStats: List<Map<String, dynamic>>.from(
                            campaign.stats!['daily_stats'],
                          ),
                          type: 'clicks',
                        ),
                        CampaignStatsChart(
                          dailyStats: List<Map<String, dynamic>>.from(
                            campaign.stats!['daily_stats'],
                          ),
                          type: 'ctr',
                        ),
                        CampaignStatsChart(
                          dailyStats: List<Map<String, dynamic>>.from(
                            campaign.stats!['daily_stats'],
                          ),
                          type: 'cost',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetingInfo(AdCampaign campaign) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '投放规则',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTargetingItem(
              icon: Icons.person_outline,
              title: '年龄范围',
              content: '${campaign.targetingRules['age_range']['min']}岁 - '
                  '${campaign.targetingRules['age_range']['max']}岁',
            ),
            _buildTargetingItem(
              icon: Icons.wc,
              title: '性别',
              content: _formatGenders(campaign.targetingRules['genders'] as List),
            ),
            _buildTargetingItem(
              icon: Icons.location_on_outlined,
              title: '地区',
              content: (campaign.targetingRules['regions'] as List).join('、'),
            ),
            _buildTargetingItem(
              icon: Icons.interests,
              title: '兴趣爱好',
              content: (campaign.targetingRules['interests'] as List).join('、'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGenders(List genders) {
    final Map<String, String> genderMap = {
      'male': '男',
      'female': '女',
    };
    return genders.map((g) => genderMap[g] ?? g).join('、');
  }

  Widget _buildTargetingItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(
            '$title：',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(AdCampaign campaign) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预算设置',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildBudgetItem(
              icon: Icons.attach_money,
              title: '日预算',
              content: '¥${campaign.budgetSettings['daily_budget']}',
            ),
            _buildBudgetItem(
              icon: Icons.account_balance_wallet,
              title: '总预算',
              content: '¥${campaign.budgetSettings['total_budget']}',
            ),
            _buildBudgetItem(
              icon: Icons.monetization_on,
              title: '出价',
              content: '¥${campaign.budgetSettings['bid_amount']}/次展示',
            ),
            if (campaign.budgetSettings['schedule_enabled'] == true) ...[
              _buildBudgetItem(
                icon: Icons.access_time,
                title: '投放时段',
                content: '${campaign.budgetSettings['schedule_start_time']} - '
                    '${campaign.budgetSettings['schedule_end_time']}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(
            '$title：',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'draft':
        color = Colors.grey;
        label = '草稿';
        break;
      case 'pending':
        color = Colors.orange;
        label = '审核中';
        break;
      case 'active':
        color = Colors.green;
        label = '投放中';
        break;
      case 'paused':
        color = Colors.blue;
        label = '已暂停';
        break;
      case 'rejected':
        color = Colors.red;
        label = '已拒绝';
        break;
      default:
        color = Colors.grey;
        label = '未知';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
        ),
      ),
    );
  }
} 