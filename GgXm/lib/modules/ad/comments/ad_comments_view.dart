import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/ad.dart';
import '../../../models/comment.dart';
import 'ad_comments_controller.dart';

class AdCommentsView extends GetView<AdCommentsController> {
  const AdCommentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('评论 ${controller.comments.length}')),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentItem(controller.comments[index]);
                },
              );
            }),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: NetworkImage(comment.userAvatar),
              ),
              SizedBox(width: 8.w),
              Text(
                comment.userName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(comment.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.likeComment(comment),
                child: Row(
                  children: [
                    Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16.r,
                      color: comment.isLiked ? Colors.red : Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      comment.likes.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              GestureDetector(
                onTap: () => controller.replyComment(comment),
                child: Text(
                  '回复',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              margin: EdgeInsets.only(left: 32.w),
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: comment.replies
                    .map((reply) => _buildReplyItem(reply))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyItem(Comment reply) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reply.userName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(reply.createdAt),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            reply.content,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(16.r).copyWith(
        bottom: MediaQuery.of(Get.context!).padding.bottom + 16.r,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentController,
              decoration: InputDecoration(
                hintText: controller.replyTo.value == null
                    ? '说点什么...'
                    : '回复 ${controller.replyTo.value!.userName}',
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
            ),
          ),
          SizedBox(width: 16.w),
          ElevatedButton(
            onPressed: controller.submitComment,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(12.r),
            ),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 