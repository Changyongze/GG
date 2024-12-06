import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../models/ad.dart';
import '../../../services/auth_service.dart';
import '../../../api/ad_api.dart';

class AdDetailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AdApi _adApi = AdApi();
  
  late final Ad ad;
  late final VideoPlayerController videoController;
  
  final isInitialized = false.obs;
  final isPlaying = false.obs;
  final isWatched = false.obs;
  final watchProgress = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    ad = Get.arguments as Ad;
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    videoController = VideoPlayerController.network(ad.videoUrl);
    
    try {
      await videoController.initialize();
      isInitialized.value = true;
      
      // 监听播放状态
      videoController.addListener(_videoListener);
      
      // 自动播放
      togglePlay();
    } catch (e) {
      Get.snackbar('错误', '视频加载失败');
    }
  }

  void _videoListener() {
    isPlaying.value = videoController.value.isPlaying;
    
    // 计算观看进度
    if (videoController.value.duration.inSeconds > 0) {
      watchProgress.value = videoController.value.position.inSeconds / 
                          videoController.value.duration.inSeconds;
                          
      // 当观看进度超过80%时，标记为已观看并获取积分
      if (watchProgress.value >= 0.8 && !isWatched.value) {
        isWatched.value = true;
        _earnPoints();
      }
    }
  }

  void togglePlay() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }
  }

  Future<void> _earnPoints() async {
    try {
      // TODO: 实现获取积分的API调用
      Get.snackbar('提示', '获得${ad.points}积分');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  void likeAd() {
    // TODO: 实现点赞功能
    Get.snackbar('提示', '点赞功能开发中');
  }

  void showComments() {
    // TODO: 实现评论功能
    Get.snackbar('提示', '评论功能开发中');
  }

  void shareAd() {
    // TODO: 实现分享功能
    Get.snackbar('提示', '分享功能开发中');
  }

  @override
  void onClose() {
    videoController.removeListener(_videoListener);
    videoController.dispose();
    super.onClose();
  }
} 