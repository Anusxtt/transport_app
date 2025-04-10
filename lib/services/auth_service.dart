import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/users';
  // final String baseUrl = 'http://192.168.1.109:3000/users';
  // final String baseUrl = 'http://192.168.1.11:3000/users';
  final box = GetStorage();

  Future<Map<String, dynamic>> register(
      String username, String email, String password, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "phone": phone,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Please try again.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: jsonEncode({"identifier": identifier, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          box.write('token', data['token']);
          return {
            'success': true,
            'user': data['user'],
            'token': data['token']
          };
        } else {
          return {'success': false, 'message': 'Invalid credentials'};
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to login. Please try again.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    String? token = GetStorage().read('token');
    print("📌 Log: Token ที่ใช้ -> $token");

    if (token == null || token.isEmpty) {
      print("❌ ERROR: Token ไม่มีค่า");
      return {'success': false, 'message': 'Token not found'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("📌 Log: API Response -> ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            "❌ ERROR: ไม่สามารถดึงข้อมูลโปรไฟล์ (status: ${response.statusCode})");
        return {'success': false, 'message': 'Failed to fetch profile'};
      }
    } catch (e) {
      print("❌ ERROR: ดึงข้อมูลโปรไฟล์ล้มเหลว -> $e");
      return {'success': false, 'message': 'Failed to connect to server'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String username, String email, String phone) async {
    String? token = box.read('token');
    print("📌 Log: Token ที่ใช้สำหรับอัปเดต -> $token");

    if (token == null || token.isEmpty) {
      print("❌ ERROR: Token ไม่มีค่า");
      return {'success': false, 'message': 'Token not found'};
    }

    try {
      print(
          "📌 Log: ส่งข้อมูลอัปเดตไปที่ API -> username: $username, email: $email, phone: $phone");

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "username": username,
          "email": email,
          "phone": phone,
        }),
      );

      print("📌 Log: Response จาก API -> ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            "❌ ERROR: อัปเดตโปรไฟล์ไม่สำเร็จ (status: ${response.statusCode})");
        return {'success': false, 'message': 'Failed to update profile'};
      }
    } catch (e) {
      print("❌ ERROR: อัปเดตข้อมูลโปรไฟล์ล้มเหลว -> $e");
      return {'success': false, 'message': 'Failed to connect to server'};
    }
  }
}
