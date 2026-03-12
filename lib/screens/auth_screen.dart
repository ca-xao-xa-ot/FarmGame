






import 'package:flutter/material.dart';
import 'intro_screen.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final AuthService           _authService     = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController  = TextEditingController();
  bool isLogin   = true;
  bool isLoading = false;
  bool _obscure  = true;
  late AnimationController _fadeCtrl;
  late AnimationController _floatCtrl;
  late Animation<double>   _fade;
  late Animation<double>   _float;

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _fade  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _float = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _navigateToIntro() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const IntroScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Text('🌸 '), Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFFE57373),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final pass  = _passController.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showError('Vui lòng nhập email và mật khẩu! 💌');
      return;
    }
    setState(() => isLoading = true);
    try {
      final user = isLogin
          ? await _authService.signInWithEmail(email, pass)
          : await _authService.registerWithEmail(email, pass);
      if (user != null && mounted) {
        _navigateToIntro();
      } else if (mounted) {
        _showError(isLogin ? 'Email/mật khẩu không đúng! 🥺' : 'Đăng ký thất bại – email đã tồn tại?');
      }
    } catch (e) {
      if (mounted) _showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        _navigateToIntro();
      } else if (mounted) {
        _showError('Đăng nhập Google thất bại! 😢');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFCE4EC),  
                Color(0xFFE8F5E9),  
                Color(0xFFFFF9C4),  
                Color(0xFFE3F2FD),  
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),

        
        Positioned(top: 30,  left: 10,  child: _floatingEmoji('🌸', 44, 0.0)),
        Positioned(top: 20,  right: 15, child: _floatingEmoji('⭐', 36, 0.5)),
        Positioned(top: 80,  left: 55,  child: _floatingEmoji('🌿', 26, 0.2)),
        Positioned(top: 90,  right: 60, child: _floatingEmoji('🍓', 30, 0.8)),
        Positioned(top: 140, left: 20,  child: _floatingEmoji('🌻', 38, 0.3)),
        Positioned(top: 150, right: 20, child: _floatingEmoji('🎀', 28, 0.6)),
        Positioned(bottom: 50,  left: 15,  child: _floatingEmoji('🐔', 34, 0.4)),
        Positioned(bottom: 40,  right: 15, child: _floatingEmoji('🐄', 38, 0.7)),
        Positioned(bottom: 100, left: 60,  child: _floatingEmoji('🌾', 24, 0.1)),
        Positioned(bottom: 120, right: 55, child: _floatingEmoji('🍀', 22, 0.9)),
        Positioned(top: 200, left: 5,    child: _floatingEmoji('✨', 20, 0.15)),
        Positioned(top: 180, right: 10,  child: _floatingEmoji('💫', 22, 0.55)),

        
        SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(children: [
                  
                  AnimatedBuilder(
                    animation: _float,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _float.value * 0.4),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.4),
                                blurRadius: 24, spreadRadius: 4),
                            BoxShadow(color: const Color(0xFFF48FB1).withOpacity(0.3),
                                blurRadius: 16, spreadRadius: 2),
                          ],
                        ),
                        child: const Text('🌾', style: TextStyle(fontSize: 58)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  
                  const Text(
                    'NÔNG TRẠI XANH',
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Colors.white, blurRadius: 8, offset: Offset(1, 1)),
                        Shadow(color: Color(0xFFA5D6A7), blurRadius: 12, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFFCE93D8)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🌸 Phiêu lưu nông trại kỳ diệu! 🌸',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 28),

                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFF48FB1).withOpacity(0.2),
                            blurRadius: 24, offset: const Offset(-4, -4)),
                        BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.2),
                            blurRadius: 24, offset: const Offset(4, 8)),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6), width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(children: [
                      
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(children: [
                          _tabBtn('🌾 Đăng nhập', isLogin, () => setState(() => isLogin = true)),
                          _tabBtn('🌱 Đăng ký',  !isLogin, () => setState(() => isLogin = false)),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      
                      _buildField(
                        controller: _emailController,
                        hint: 'Địa chỉ email của bạn',
                        icon: '📧',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      
                      _buildPasswordField(),
                      const SizedBox(height: 22),

                      
                      if (isLoading)
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF43A047)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            ),
                          ),
                        )
                      else ...[
                        
                        _buildGradientButton(
                          label: isLogin ? '🌾  Vào Nông Trại!' : '🌱  Tạo Tài Khoản!',
                          colors: isLogin
                              ? [const Color(0xFF66BB6A), const Color(0xFF2E7D32)]
                              : [const Color(0xFFF48FB1), const Color(0xFFE91E63)],
                          onTap: _submit,
                        ),
                        const SizedBox(height: 16),

                        
                        Row(children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('✨ hoặc ✨',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ]),
                        const SizedBox(height: 16),

                        
                        GestureDetector(
                          onTap: _googleSignIn,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                              boxShadow: [BoxShadow(
                                color: Colors.grey.withOpacity(0.12),
                                blurRadius: 8, offset: const Offset(0, 3),
                              )],
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF4285F4), Color(0xFF34A853),
                                    Color(0xFFFBBC05), Color(0xFFEA4335),
                                  ]),
                                ),
                                child: const Center(
                                  child: Text('G',
                                    style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text('Tiếp tục với Google',
                                  style: TextStyle(
                                    color: Color(0xFF3C3C3C),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  )),
                            ]),
                          ),
                        ),
                      ],
                    ]),
                  ),

                  const SizedBox(height: 20),
                  
                  Text(
                    '🐔 🌱 🐄 🍓 🌻 🐑 🎣',
                    style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.8)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _floatingEmoji(String emoji, double size, double offset) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, __) => Transform.translate(
        offset: Offset(
          _float.value * 0.3 * (offset > 0.5 ? 1 : -1),
          _float.value * (0.5 + offset * 0.5),
        ),
        child: Text(emoji, style: TextStyle(fontSize: size)),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.06),
          blurRadius: 6, offset: const Offset(0, 2),
        )],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.06),
          blurRadius: 6, offset: const Offset(0, 2),
        )],
      ),
      child: TextField(
        controller: _passController,
        obscureText: _obscure,
        onSubmitted: (_) => _submit(),
        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        decoration: InputDecoration(
          hintText: 'Mật khẩu bí mật của bạn',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('🔐', style: TextStyle(fontSize: 20)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: IconButton(
            icon: Text(_obscure ? '👁️' : '🙈', style: const TextStyle(fontSize: 18)),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.4),
                blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF43A047)])
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}
