import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/user_coupon.dart';

class CouponShareView extends StatefulWidget {
  final UserCoupon coupon;

  const CouponShareView({
    Key? key,
    required this.coupon,
  }) : super(key: key);

  @override
  State<CouponShareView> createState() => _CouponShareViewState();
}

class _CouponShareViewState extends State<CouponShareView> {
  final screenshotController = ScreenshotController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分享优惠券'),
        actions: [
          TextButton(
            onPressed: _saveToGallery,
            child: Text(
              isSaving ? '保存中...' : '保存',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildPoster(),
                    _buildQrCode(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveToGallery,
                    icon: const Icon(Icons.save_alt),
                    label: Text(isSaving ? '保存中...' : '保存到相册'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToWechat,
                    icon: const Icon(Icons.wechat),
                    label: const Text('分享到微信'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07C160),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor(widget.coupon.type),
            _getTypeColor(widget.coupon.type).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _getTypeLabel(widget.coupon.type),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            widget.coupon.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.coupon.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Text(
            widget.coupon.valueText,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '有效期至${_formatDate(widget.coupon.endDate)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    return Container(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          QrImageView(
            data: 'https://example.com/coupon/${widget.coupon.id}',
            version: QrVersions.auto,
            size: 200.r,
          ),
          SizedBox(height: 16.h),
          Text(
            '扫码领取优惠券',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToGallery() async {
    if (isSaving) return;
    
    setState(() {
      isSaving = true;
    });

    try {
      final image = await screenshotController.capture();
      if (image == null) {
        throw '生成图片失败';
      }

      final result = await ImageGallerySaver.saveImage(
        image,
        quality: 100,
        name: 'coupon_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess']) {
        Get.snackbar('成功', '海报已保存到相册');
      } else {
        throw '保存失败';
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> _shareToWechat() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) {
        throw '生成图片失败';
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/coupon_share.png');
      await file.writeAsBytes(image);

      // TODO: 调用微信分享SDK
      Get.snackbar('提示', '微信分享功能开发中');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  String _getTypeLabel(CouponType type) {
    switch (type) {
      case CouponType.discount:
        return '折扣券';
      case CouponType.cash:
        return '现金券';
      case CouponType.exchange:
        return '兑换券';
      case CouponType.gift:
        return '礼品券';
    }
  }

  Color _getTypeColor(CouponType type) {
    switch (type) {
      case CouponType.discount:
        return Colors.orange;
      case CouponType.cash:
        return Colors.red;
      case CouponType.exchange:
        return Colors.blue;
      case CouponType.gift:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 