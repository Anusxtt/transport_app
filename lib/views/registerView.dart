import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../router/app_routes.dart';
import 'loginView.dart';

class RegisterView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign up to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildTextField(usernameController, "Username"),
              const SizedBox(height: 20),
              _buildTextField(emailController, "Email"),
              const SizedBox(height: 20),
              _buildTextField(phoneController, "Phone Number"),
              const SizedBox(height: 20),
              _buildTextField(passwordController, "Password",
                  obscureText: true),
              const SizedBox(height: 30),
              Obx(() => authController.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : _buildRegisterButton()),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.login);
                },
                child: Text("Already have an account? Login"),
              ),
            ],
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: () {
        authController.register(
          usernameController.text,
          emailController.text,
          passwordController.text,
          phoneController.text,
        );
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
            "Register",
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
}
