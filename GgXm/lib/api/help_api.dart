import 'package:get/get.dart';
import '../models/faq.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class HelpApi {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<FAQ>> getFAQs() async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.faqs,
    );
    
    return response.map((json) => FAQ.fromJson(json)).toList();
  }
} 