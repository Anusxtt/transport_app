import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../router/app_routes.dart';
import 'registerView.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // ใช้ Center เพื่อจัดให้อยู่กึ่งกลางแนวตั้ง
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ลดขนาดให้ตรงกลางพอดี
              crossAxisAlignment:
                  CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางแนวนอน
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Login to your account",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildTextField(emailController, "Email"),
                const SizedBox(height: 20),
                _buildTextField(passwordController, "Password",
                    obscureText: true),
                const SizedBox(height: 30),
                Obx(() => authController.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : _buildLoginButton()),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.toNamed(Routes.register);
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () {
        if (_validateInputs()) {
          authController.login(
              emailController.text.trim(), passwordController.text.trim());
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.red, Colors.orange],
          ),
        ),
        child: Center(
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter both email and password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar("Error", "Invalid email format",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    return true;
  }
}
