import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../models/ad_campaign.dart';
import 'campaign_list_controller.dart';

class CampaignListView extends GetView<CampaignListController> {
  const CampaignListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('广告计划'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: controller.selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.createCampaign,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.campaigns.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 64.r,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '暂无广告计划',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: controller.createCampaign,
                        child: const Text('创建计划'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadCampaigns,
                child: ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: controller.campaigns.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final campaign = controller.campaigns[index];
                    return _buildCampaignCard(campaign);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 48.h,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          Obx(() => FilterChip(
            label: const Text('全部'),
            selected: controller.selectedStatus.value == null,
            onSelected: (selected) {
              if (selected) {
                controller.selectedStatus.value = null;
                controller.loadCampaigns();
              }
            },
          )),
          SizedBox(width: 8.w),
          ...CampaignStatus.values.map((status) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Obx(() => FilterChip(
                label: Text(_getStatusLabel(status)),
                selected: controller.selectedStatus.value == status,
                onSelected: (selected) {
                  controller.selectedStatus.value = selected ? status : null;
                  controller.loadCampaigns();
                },
              )),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(AdCampaign campaign) {
    return Card(
      child: InkWell(
        onTap: () => controller.editCampaign(campaign),
        child: Padding(
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
                        fontSize: 16.sp,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16.r,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    campaign.category,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.monetization_on,
                    size: 16.r,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '¥${campaign.budget}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(campaign.startDate),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  _buildActionButtons(campaign),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(CampaignStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Colors.grey;
      case CampaignStatus.pending:
        return Colors.orange;
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.paused:
        return Colors.blue;
      case CampaignStatus.completed:
        return Colors.purple;
      case CampaignStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusLabel(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return '草稿';
      case CampaignStatus.pending:
        return '审核中';
      case CampaignStatus.active:
        return '投放中';
      case CampaignStatus.paused:
        return '已暂停';
      case CampaignStatus.completed:
        return '已完成';
      case CampaignStatus.rejected:
        return '已拒绝';
    }
  }

  Widget _buildActionButtons(AdCampaign campaign) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.bar_chart),
          onPressed: () => controller.viewStats(campaign),
        ),
        PopupMenuButton<CampaignStatus>(
          onSelected: (status) => controller.updateStatus(campaign.id, status),
          itemBuilder: (context) => [
            if (campaign.status == CampaignStatus.draft)
              const PopupMenuItem(
                value: CampaignStatus.pending,
                child: Text('提交审核'),
              ),
            if (campaign.status == CampaignStatus.active)
              const PopupMenuItem(
                value: CampaignStatus.paused,
                child: Text('暂停投放'),
              ),
            if (campaign.status == CampaignStatus.paused)
              const PopupMenuItem(
                value: CampaignStatus.active,
                child: Text('恢复投放'),
              ),
          ],
        ),
      ],
    );
  }
} 