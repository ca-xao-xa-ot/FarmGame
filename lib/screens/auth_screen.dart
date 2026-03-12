import 'package:flutter/material.dart';
import 'intro_screen.dart'; // Đã đổi sang import trang NPC
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  // Đã sửa hàm này để nhảy sang màn hình IntroScreen (NPC)
  void _navigateToIntro() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const IntroScreen()),
    );
  }

  void _submit() async {
    setState(() => isLoading = true);
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    try {
      var user = isLogin
          ? await _authService.signInWithEmail(email, pass)
          : await _authService.registerWithEmail(email, pass);

      if (user != null && mounted) {
        _navigateToIntro(); // Cập nhật gọi hàm mới
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Vui lòng kiểm tra lại thông tin!")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _googleSignIn() async {
    setState(() => isLoading = true);
    try {
      var user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        _navigateToIntro(); // Cập nhật gọi hàm mới
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng nhập Google thất bại!")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: Text(isLogin ? 'Đăng nhập' : 'Đăng ký'), backgroundColor: Colors.green),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
                  onPressed: _submit,
                  child: Text(isLogin ? 'Đăng nhập' : 'Đăng ký', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'Chưa có tài khoản? Đăng ký ngay' : 'Đã có tài khoản? Đăng nhập'),
                ),
                const Divider(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 40),
                  label: const Text('Đăng nhập bằng Google', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50)
                  ),
                  onPressed: _googleSignIn,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}