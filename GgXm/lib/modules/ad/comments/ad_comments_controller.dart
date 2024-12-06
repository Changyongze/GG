import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/ad.dart';
import '../../../models/comment.dart';
import '../../../api/ad_api.dart';
import '../../../api/points_api.dart';

class AdCommentsController extends GetxController {
  final AdApi _adApi = Get.find<AdApi>();
  final PointsApi _pointsApi = Get.find<PointsApi>();
  
  final comments = <Comment>[].obs;
  final isLoading = false.obs;
  final replyTo = Rxn<Comment>();
  
  late Ad ad;
  late TextEditingController commentController;

  @override
  void onInit() {
    super.onInit();
    ad = Get.arguments as Ad;
    commentController = TextEditingController();
    loadComments();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadComments() async {
    isLoading.value = true;
    try {
      final response = await _adApi.getAdComments(ad.id);
      comments.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitComment() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入评论内容');
      return;
    }

    try {
      final comment = await _adApi.addComment(
        ad.id,
        commentController.text,
      );
      
      // 如果是回复评论
      if (replyTo.value != null) {
        final index = comments.indexWhere((c) => c.id == replyTo.value!.id);
        if (index != -1) {
          final updatedComment = Comment(
            id: replyTo.value!.id,
            userId: replyTo.value!.userId,
            userName: replyTo.value!.userName,
            userAvatar: replyTo.value!.userAvatar,
            content: replyTo.value!.content,
            likes: replyTo.value!.likes,
            isLiked: replyTo.value!.isLiked,
            createdAt: replyTo.value!.createdAt,
            replies: [...replyTo.value!.replies, comment],
          );
          comments[index] = updatedComment;
        }
        replyTo.value = null;
      } else {
        comments.insert(0, comment);
      }

      commentController.clear();
      await _pointsApi.earnInteractionPoints(ad.id, PointsType.comment);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> likeComment(Comment comment) async {
    try {
      await _adApi.likeComment(ad.id, comment.id);
      final index = comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        final updatedComment = Comment(
          id: comment.id,
          userId: comment.userId,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: comment.content,
          likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
          isLiked: !comment.isLiked,
          createdAt: comment.createdAt,
          replies: comment.replies,
        );
        comments[index] = updatedComment;
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void replyComment(Comment comment) {
    replyTo.value = comment;
    commentController.clear();
    FocusScope.of(Get.context!).requestFocus();
  }
} 