import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/auth_controller.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  ProfileView({Key? key}) : super(key: key);
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "โปรไฟล์",
          style: GoogleFonts.notoSansThai(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () => Get.to(() => EditProfileView()),
          ),
        ],
      ),
      body: Obx(() {
        if (authController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        var user = authController.currentUser;
        String baseUrl = 'http://10.0.2.2:3000'; // URL ของเซิร์ฟเวอร์
        String imageUrl = '$baseUrl/${user['profileImage']}';

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user['profileImage'] != null
                      ? NetworkImage(imageUrl)
                      : AssetImage('assets/profile.jpg') as ImageProvider,
                ),
              ),
              SizedBox(height: 10),
              Text(
                user['username'] ?? "ไม่พบชื่อผู้ใช้",
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              _buildCardSection("แต้มสะสม"),
              SizedBox(height: 16),
              _buildAboutMeSection(user),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => authController.logout(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  "ออกจากระบบ",
                  style: GoogleFonts.notoSansThai(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 4,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Get.toNamed('/home');
            break;
          case 1:
            Get.toNamed('/consolidation');
            break;
          case 2:
            Get.toNamed('/map');
            break;
          case 3:
            Get.toNamed('/notification');
            break;
          case 4:
            Get.toNamed('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
        BottomNavigationBarItem(
            icon: Icon(Icons.group), label: "Consolidation"),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "แผนที่"),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: "แจ้งเตือน"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "บัญชี"),
      ],
    );
  }

  Widget _buildCardSection(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.notoSansThai(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAboutMeSection(Map user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(Icons.person, user['username'] ?? "N/A"),
          _buildInfoItem(Icons.email, user['email'] ?? "N/A"),
          _buildInfoItem(Icons.phone, user['phone'] ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style:
                  GoogleFonts.notoSansThai(fontSize: 16, color: Colors.white)),
        ),
        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      ],
    );
  }
}
