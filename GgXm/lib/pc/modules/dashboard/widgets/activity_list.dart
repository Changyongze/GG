import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../models/activity.dart';

class ActivityList extends StatelessWidget {
  final List<Activity> activities;

  const ActivityList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('暂无活动'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: _buildIcon(activity.type),
          title: Text(activity.title),
          subtitle: Text(activity.description),
          trailing: Text(
            _formatTime(activity.createdAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'ad_view':
        iconData = Icons.visibility;
        color = Colors.blue;
        break;
      case 'ad_click':
        iconData = Icons.touch_app;
        color = Colors.green;
        break;
      case 'coupon_exchange':
        iconData = Icons.card_giftcard;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: color,
        size: 20.r,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return DateFormat('MM-dd HH:mm').format(time);
    }
  }
} 