import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(() {
        var user = authController.currentUser;
        return Column(
          children: [
            _buildDrawerHeader(user),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.dashboard, "แดชบอร์ด", '/dashboard'),
                  _drawerItem(Icons.work, "งาน", '/jobs'),
                  _drawerItem(Icons.local_shipping, "การขนส่ง", '/shipping'),
                  _drawerItem(Icons.people, "คนขับประจำ", '/drivers'),
                  _drawerItem(Icons.assignment, "รายงาน", '/reports'),
                  Divider(),
                  _drawerItem(Icons.help, "ช่วยเหลือ", '/help'),
                  _drawerItem(Icons.settings, "ตั้งค่า", '/settings'),
                  Divider(),
                  _drawerItem(Icons.logout, "ออกจากระบบ", '/',
                      color: Colors.red, onTap: () {
                    authController.logout();
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDrawerHeader(Map user) {
    return DrawerHeader(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.orange])),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.red),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user['username'] ?? "ผู้ใช้ไม่มีชื่อ",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(user['email'] ?? "example@email.com",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 14, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String route,
      {Color color = Colors.black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: GoogleFonts.notoSansThai(fontSize: 16, color: color)),
      onTap: onTap ?? () => Get.toNamed(route),
    );
  }
}
