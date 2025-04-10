import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeService {
  final String baseUrl = 'http://10.0.2.2:3000/transport-service';
  // final String baseUrl = 'http://192.168.1.109:3000/transport-service';
  // final String baseUrl = 'http://192.168.1.11:3000/transport-service';

  Future<List<dynamic>> getTransportServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTransportTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/types'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching transport types: $e');
      return [];
    }
  }

  Future<List<dynamic>> getLogisticsVehicles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/logistics'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching logistics vehicles: $e');
      return [];
    }
  }

  Future<List<dynamic>> getPassengerVehicles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/passenger'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching passenger vehicles: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        body: jsonEncode(orderData),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to create order'};
      }
    } catch (e) {
      print('Error creating order: $e');
      return {'success': false, 'message': 'Server error'};
    }
  }
}
