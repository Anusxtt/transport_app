import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:transport_app/router/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final box = GetStorage();

  var isLoading = false.obs;
  var currentUser = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> register(
      String username, String email, String password, String phone) async {
    isLoading(true);
    try {
      final response =
          await _authService.register(username, email, password, phone);
      Get.snackbar('Success', 'User registered successfully');
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar('Error', 'Failed to register');
    } finally {
      isLoading(false);
    }
  }

  Future<void> login(String identifier, String password) async {
    isLoading(true);
    try {
      final response = await _authService.login(identifier, password);

      if (response['success']) {
        currentUser.value = response['user'];
        box.write('username', response['user']['username']);
        box.write('token', response['token']);

        print("📌 Log: บันทึก Token -> ${box.read('token')}");

        Get.snackbar('Success', 'Login successful');
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', response['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid credentials');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    isLoading(true);
    try {
      final response = await _authService.getProfile();
      print("📌 Log: Response จาก API -> $response");

      if (response['success']) {
        currentUser.value = response['user'];
        print("✅ ข้อมูลผู้ใช้: ${currentUser.value}");
      } else {
        Get.snackbar('Error', response['message']);
      }
    } catch (e) {
      print("❌ ERROR: ดึงข้อมูลผู้ใช้ล้มเหลว -> $e");
      Get.snackbar('Error', 'Failed to fetch profile');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProfile(
      String username, String email, String phone) async {
    isLoading(true);
    try {
      print(
          "📌 Log: กำลังอัปเดตข้อมูล -> username: $username, email: $email, phone: $phone");

      final response = await _authService.updateProfile(username, email, phone);
      print("📌 Log: Response จาก API หลังอัปเดต -> $response");

      if (response['success']) {
        currentUser.value = response['user'];
        print("✅ ข้อมูลผู้ใช้ที่ถูกอัปเดต -> ${currentUser.value}");
        Get.snackbar('Success', 'ข้อมูลถูกอัปเดตแล้ว');
        Get.back();
      } else {
        print("❌ ERROR: อัปเดตข้อมูลล้มเหลว -> ${response['message']}");
        Get.snackbar('Error', response['message']);
      }
    } catch (e) {
      print("❌ ERROR: อัปเดตข้อมูลล้มเหลว -> $e");
      Get.snackbar('Error', 'อัปเดตล้มเหลว');
    } finally {
      isLoading(false);
    }
  }

  void logout() {
    print("📌 Log: กำลังออกจากระบบ...");
    box.erase();
    currentUser.value = {};
    Get.offAllNamed('/login');
  }
}
