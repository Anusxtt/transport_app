import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsolidationController extends GetxController {
  var isLoading = false.obs;
  var consolidations = [].obs;

  @override
  void onInit() {
    fetchConsolidations();
    super.onInit();
  }

  Future<void> fetchConsolidations() async {
    isLoading(true);
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/consolidations'));

      if (response.statusCode == 200) {
        consolidations.assignAll(jsonDecode(response.body));
      } else {
        consolidations.assignAll([]);
      }
    } catch (e) {
      print('Error fetching consolidations: $e');
      consolidations.assignAll([]);
    } finally {
      isLoading(false);
    }
  }
}
