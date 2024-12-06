import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../api/ad_material_api.dart';

class MaterialUploadController extends GetxController {
  final AdMaterialApi _materialApi = AdMaterialApi();
  
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final mediaFile = Rxn<File>();
  final coverFile = Rxn<File>();
  final mediaType = 'video'.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file;
    
    if (mediaType.value == 'video') {
      file = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1),
      );
    } else {
      file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
    }
    
    if (file != null) {
      mediaFile.value = File(file.path);
    }
  }

  Future<void> pickCover() async {
    if (mediaType.value != 'video') return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    
    if (image != null) {
      coverFile.value = File(image.path);
    }
  }

  void setMediaType(String type) {
    mediaType.value = type;
    mediaFile.value = null;
    coverFile.value = null;
  }

  Future<void> uploadMaterial() async {
    if (!formKey.currentState!.validate()) return;
    if (mediaFile.value == null) {
      Get.snackbar('错误', '请选择要上传的素材');
      return;
    }
    if (mediaType.value == 'video' && coverFile.value == null) {
      Get.snackbar('错误', '请上传视频封面');
      return;
    }

    isLoading.value = true;
    try {
      await _materialApi.uploadMaterial(
        'current_campaign_id', // TODO: 替换为实际广告计划ID
        title: titleController.text,
        description: descriptionController.text,
        file: mediaFile.value!,
        type: mediaType.value,
        coverFile: coverFile.value,
      );
      Get.back(result: true);
      Get.snackbar('提示', '素材上传成功');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
} 