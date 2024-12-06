import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/ad.dart';
import 'ad_prediction_controller.dart';

class AdPredictionView extends GetView<AdPredictionController> {
  const AdPredictionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('效果预测'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              _buildAdInfo(),
              SizedBox(height: 24.h),
              _buildPredictionForm(),
              SizedBox(height: 24.h),
              if (controller.predictionResult.isNotEmpty)
                _buildPredictionResult(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAdInfo() {
    final ad = controller.ad;
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.network(
            ad.coverUrl,
            width: 60.w,
            height: 60.w,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(ad.title),
        subtitle: Text(ad.description),
      ),
    );
  }

  Widget _buildPredictionForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预测参数',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildBudgetInput(),
            SizedBox(height: 16.h),
            _buildDurationInput(),
            SizedBox(height: 16.h),
            _buildTargetAudienceSelector(),
            SizedBox(height: 16.h),
            _buildPlacementSelector(),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.predict,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    '开始预测',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInput() {
    return TextFormField(
      controller: controller.budgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '预算金额',
        suffixText: '元',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildDurationInput() {
    return TextFormField(
      controller: controller.durationController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '投放天数',
        suffixText: '天',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildTargetAudienceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '目标受众',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.audienceOptions.map((option) {
            return Obx(() {
              final isSelected = controller.selectedAudiences.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  controller.toggleAudience(option);
                },
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlacementSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投放位置',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.placementOptions.map((option) {
            return Obx(() {
              final isSelected = controller.selectedPlacements.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  controller.togglePlacement(option);
                },
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPredictionResult() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预测结果',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildMetricPrediction(
              '预计展示',
              controller.predictionResult['impressions'],
              '次',
            ),
            SizedBox(height: 12.h),
            _buildMetricPrediction(
              '预计点击',
              controller.predictionResult['clicks'],
              '次',
            ),
            SizedBox(height: 12.h),
            _buildMetricPrediction(
              '预计点击率',
              controller.predictionResult['ctr'],
              '%',
              isPercentage: true,
            ),
            SizedBox(height: 12.h),
            _buildMetricPrediction(
              '预计转化',
              controller.predictionResult['conversions'],
              '次',
            ),
            SizedBox(height: 12.h),
            _buildMetricPrediction(
              '预计ROI',
              controller.predictionResult['roi'],
              '',
              isPercentage: true,
              prefix: '¥',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPrediction(
    String label,
    dynamic value,
    String suffix, {
    bool isPercentage = false,
    String prefix = '',
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          '$prefix${isPercentage ? (value * 100).toStringAsFixed(2) : value.toString()}$suffix',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 