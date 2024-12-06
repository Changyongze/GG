import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'ad_detail_controller.dart';

class AdDetailView extends GetView<AdDetailController> {
  const AdDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoPlayer(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 16.h),
                    _buildDescription(),
                    SizedBox(height: 24.h),
                    _buildInteractionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Obx(() {
            if (controller.isInitialized.value) {
              return VideoPlayer(controller.videoController);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
          Positioned(
            top: 16.h,
            left: 16.w,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          Obx(() => controller.isInitialized.value
            ? GestureDetector(
                onTap: controller.togglePlay,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: controller.isPlaying.value ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.isPlaying.value 
                            ? Icons.pause 
                            : Icons.play_arrow,
                          color: Colors.white,
                          size: 32.r,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.ad.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.monetization_on, size: 16.r, color: Colors.orange),
            SizedBox(width: 4.w),
            Text(
              '${controller.ad.points}积分',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 16.w),
            Icon(Icons.remove_red_eye_outlined, size: 16.r, color: Colors.grey),
            SizedBox(width: 4.w),
            Text(
              '${controller.ad.views}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      controller.ad.description,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  Widget _buildInteractionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInteractionButton(
          icon: Icons.thumb_up_outlined,
          label: '点赞',
          onTap: controller.likeAd,
        ),
        _buildInteractionButton(
          icon: Icons.comment_outlined,
          label: '评论',
          onTap: controller.showComments,
        ),
        _buildInteractionButton(
          icon: Icons.share_outlined,
          label: '分享',
          onTap: controller.shareAd,
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            Icon(icon, size: 24.r),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
} 