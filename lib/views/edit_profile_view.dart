import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var user = authController.currentUser;
    String baseUrl = 'http://10.0.2.2:3000'; // URL ของเซิร์ฟเวอร์
    String imageUrl = '$baseUrl/${user['profileImage']}';
    // กำหนดค่าเริ่มต้นของช่องกรอกข้อมูล
    usernameController.text = user['username'] ?? "";
    emailController.text = user['email'] ?? "";
    phoneController.text = user['phone'] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แก้ไขข้อมูลโปรไฟล์",
          style: GoogleFonts.notoSansThai(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "อัปเดตข้อมูลของคุณ",
                style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 20),
            // รูปโปรไฟล์
            Center(
              child: GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    authController.setProfileImage(
                        File(picked.path)); // ใช้ controller เก็บภาพ
                  }
                },
                child: Obx(() {
                  final image = authController.profileImage.value;
                  final profileImageUrl =
                      authController.currentUser['profileImageUrl'];
                  return CircleAvatar(
                    radius: 55,
                    backgroundImage: image != null
                        ? FileImage(image)
                        : (user['profileImageUrl'] != null
                            ? NetworkImage(
                                '${user['profileImageUrl']}?v=${DateTime.now().millisecondsSinceEpoch}')
                            : AssetImage(
                                'assets/profile.jpg')) as ImageProvider,
                    backgroundColor: Colors.grey[300],
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),

            // ช่องกรอกข้อมูล
            _buildTextField("ชื่อผู้ใช้", Icons.person, usernameController),
            SizedBox(height: 10),
            _buildTextField("อีเมล", Icons.email, emailController),
            SizedBox(height: 10),
            _buildTextField("เบอร์โทรศัพท์", Icons.phone, phoneController),

            SizedBox(height: 30),

            // ปุ่มบันทึก
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await authController.updateProfile(
                    usernameController.text,
                    emailController.text,
                    phoneController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้างช่องกรอกข้อมูล
  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSansThai(
            fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
