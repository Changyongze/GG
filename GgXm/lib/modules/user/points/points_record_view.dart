import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../controllers/points_controller.dart';
import '../../../models/points_record.dart';
import '../../../routes/app_routes.dart';

class PointsRecordView extends GetView<PointsController> {
  const PointsRecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分明细'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showPointsRuleDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPointsCard(),
          _buildDailyLimits(),
          Expanded(child: _buildRecordList()),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前积分',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() => Text(
                    controller.balance.value.toString(),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
                ],
              ),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.POINTS_EXCHANGE),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: const Text('去兑换'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLimits() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日获取情况',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildLimitItem(
                  '观看广告',
                  controller.todayWatchPoints,
                  controller.watchLimit,
                  Icons.play_circle_outline,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildLimitItem(
                  '互动奖励',
                  controller.todayInteractionPoints,
                  controller.interactionLimit,
                  Icons.favorite_border,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitItem(
    String label,
    RxInt current,
    RxInt limit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
            '${current.value}/${limit.value}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          )),
          SizedBox(height: 4.h),
          Obx(() => LinearProgressIndicator(
            value: current.value / limit.value,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          )),
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    return Obx(() {
      if (controller.isLoading.value && controller.records.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadRecords(refresh: true),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.records.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.records.length) {
              if (controller.hasMore.value) {
                controller.loadRecords();
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox();
            }
            return _buildRecordItem(controller.records[index]);
          },
        ),
      );
    });
  }

  Widget _buildRecordItem(PointsRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getTypeColor(record.type).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(record.type),
              color: _getTypeColor(record.type),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTypeLabel(record.type),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (record.adTitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    record.adTitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  DateFormat('MM-dd HH:mm').format(record.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            record.points > 0 ? '+${record.points}' : record.points.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: record.points > 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showPointsRuleDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('积分规则'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRuleItem('观看广告', '完整观看广告可获得100积分'),
              _buildRuleItem('点赞广告', '点赞可获得10积分'),
              _buildRuleItem('评论广告', '评论可获得30积分'),
              _buildRuleItem('分享广告', '分享可获得50积分'),
              _buildRuleItem('分享奖励', '被分享用户观看后额外获得30积分'),
              const Divider(),
              _buildRuleItem('每日上限', '观看广告上限1000积分\n互动奖励上限500积分'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(PointsType type) {
    switch (type) {
      case PointsType.watchAd:
        return Colors.blue;
      case PointsType.like:
        return Colors.pink;
      case PointsType.comment:
        return Colors.orange;
      case PointsType.share:
      case PointsType.shareBonus:
        return Colors.green;
      case PointsType.exchange:
        return Colors.purple;
      case PointsType.system:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(PointsType type) {
    switch (type) {
      case PointsType.watchAd:
        return Icons.play_circle_outline;
      case PointsType.like:
        return Icons.favorite_border;
      case PointsType.comment:
        return Icons.chat_bubble_outline;
      case PointsType.share:
      case PointsType.shareBonus:
        return Icons.share;
      case PointsType.exchange:
        return Icons.card_giftcard;
      case PointsType.system:
        return Icons.settings;
    }
  }

  String _getTypeLabel(PointsType type) {
    switch (type) {
      case PointsType.watchAd:
        return '观看广告';
      case PointsType.like:
        return '点赞广告';
      case PointsType.comment:
        return '评论广告';
      case PointsType.share:
        return '分享广告';
      case PointsType.shareBonus:
        return '分享奖励';
      case PointsType.exchange:
        return '积分兑换';
      case PointsType.system:
        return '系统调整';
    }
  }
} 