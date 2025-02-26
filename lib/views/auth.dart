import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isPasswordVisible = true;
  String selectedRole = 'Admin';

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget roleButton(String role, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
          _idController.clear(); // Clear ID field when role changes
        });
      },
      child: Container(
        height: 70.h,
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selectedRole == role ? Colors.blue.shade900 : Color(0xFF408CFD),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30.sp),
            SizedBox(height: 5.h),
            Text(
              role,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputFields() {
    String idHint = selectedRole == "Admin" ? "Email ID" : "Email ID";
    String idLabel = selectedRole == "Admin" ? "Email ID" : "Email ID";

    return Column(
      children: [
        SizedBox(height: 30.h),
        // ID Field based on role
        TextFormField(
          controller: _idController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: idHint,
            hintStyle: TextStyle(color: Colors.grey),
            labelText: idLabel,
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: const Icon(LucideIcons.userCircle, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black87),
            ),
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your ID";
            }
            return null;
          },
        ),
        SizedBox(height: 10.h),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: isPasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter your password",
            hintStyle: TextStyle(color: Colors.grey),
            labelText: "Password",
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.black),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black87),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Password must not be empty";
            } else if (value.length < 6) {
              return "Password is too short";
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D6DFB),
      body: Column(
        children: [
          SizedBox(height: 70.h),
          Text(
            "Welcome Back!",
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 5.h),
          Text(
            "Sign in to continue",
            style: TextStyle(fontSize: 16.sp, color: Colors.white70),
          ),
          SizedBox(height: 30.h),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Color(0xFFA5C9FE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Choose your role",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        roleButton("Admin", Icons.admin_panel_settings),
                        roleButton("Caretaker", Icons.person),
                      ],
                    ),
                    buildInputFields(),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        minimumSize: Size(double.infinity, 50.h),
                      ),
                      onPressed: () {},
                      child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
