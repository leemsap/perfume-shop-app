import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_page.dart';    
import 'main.dart'; // يحتوي على PerfumeShop

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> login() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        if (user.email == 'owner@example.com') {
          // فتح صفحة الأدمن
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminPage()),
          );
        } else {
          // فتح صفحة المستخدم العادي
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PerfumeShop()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'حدث خطأ أثناء تسجيل الدخول';
      });
    }
  }

  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() {
        error = 'تم إنشاء الحساب بنجاح. قم بتسجيل الدخول.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'حدث خطأ أثناء إنشاء الحساب';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: register,
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
