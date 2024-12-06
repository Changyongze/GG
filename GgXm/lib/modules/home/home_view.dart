import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../models/ad.dart';
import 'home_controller.dart';
import '../widgets/video_player_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        itemCount: controller.ads.length,
        itemBuilder: (context, index) {
          return _buildAdPage(controller.ads[index]);
        },
      ),
    );
  }

  Widget _buildAdPage(Ad ad) {
    return Stack(
      children: [
        // 视频播放器
        Positioned.fill(
          child: VideoPlayerWidget(
            videoUrl: ad.videoUrl,
            autoPlay: true,
          ),
        ),
        // 右侧操作栏
        Positioned(
          right: 16.w,
          bottom: 100.h,
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.favorite,
                label: ad.likes.toString(),
                isActive: ad.isLiked,
                onTap: () => controller.likeAd(ad),
              ),
              SizedBox(height: 16.h),
              _buildActionButton(
                icon: Icons.comment,
                label: ad.comments.toString(),
                onTap: () => controller.showComments(ad),
              ),
              SizedBox(height: 16.h),
              _buildActionButton(
                icon: Icons.share,
                label: ad.shares.toString(),
                onTap: () => controller.shareAd(ad),
              ),
            ],
          ),
        ),
        // 底部信息栏
        Positioned(
          left: 16.w,
          right: 72.w,
          bottom: 48.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                ad.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  _buildTag(ad.category),
                  ...ad.tags.map((tag) => _buildTag(tag)),
                ],
              ),
            ],
          ),
        ),
        // 积分奖励提示
        Obx(() {
          if (controller.showPointsReward.value) {
            return Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      color: Colors.yellow,
                      size: 24.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '+100积分',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.red : Colors.white,
            size: 32.r,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
        ),
      ),
    );
  }
} 