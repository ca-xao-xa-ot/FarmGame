








import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeCtrl;
  late AnimationController _bounceCtrl;
  late AnimationController _sparkleCtrl;
  late AnimationController _cloudCtrl;
  late AnimationController _heartCtrl;
  late Animation<double>   _fade;
  late Animation<double>   _bounce;
  late Animation<double>   _sparkle;
  late Animation<double>   _cloud;
  late Animation<double>   _heart;

  int  _step      = 0;
  bool _showInput = false;
  bool _checking  = true;
  bool _hasSave   = false;
  final _nameCtrl = TextEditingController();

  static const _dialogs = [
    '🌸 Ồ, cháu đã đến rồi! Bà đã chờ cháu lâu lắm rồi đó...',
    '🌾 Bà đã già yếu, không còn sức chăm lo mảnh đất xinh đẹp này nữa...',
    '🏡 Bà giao lại cho cháu! Hãy biến nơi đây thành nông trại tươi đẹp nhất làng nhé! 💖',
    '✨ Bà tin cháu làm được! Trước tiên... tên cháu là gì để bà gọi thân mật nào? 🥰',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bounceCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
    _cloudCtrl   = AnimationController(vsync: this, duration: const Duration(seconds: 22))
      ..repeat();
    _heartCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _fade    = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _bounce  = Tween<double>(begin: 0, end: -14)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _sparkle = _sparkleCtrl;
    _cloud   = _cloudCtrl;
    _heart   = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));
    _fadeCtrl.forward();
    _checkSave();
  }

  Future<void> _checkSave() async {
    
    bool ok = false;
    try {
      final gp = Provider.of<GameProvider>(context, listen: false);
      ok = await gp.tryLoadSavedGame().timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;
    setState(() {
      _checking = false;
      _hasSave  = ok;
    });

    try {
      final gp = Provider.of<GameProvider>(context, listen: false);
      gp.audio.startDayBgm();
    } catch (_) {}
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _bounceCtrl.dispose();
    _sparkleCtrl.dispose();
    _cloudCtrl.dispose();
    _heartCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    try {
      Provider.of<GameProvider>(context, listen: false).audio.playFeed();
    } catch (_) {}
    if (_step < _dialogs.length - 1) {
      setState(() => _step++);
      return;
    }
    if (_hasSave) {
      _goToGame();
    } else {
      setState(() => _showInput = true);
    }
  }

  void _goToGame() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  Future<void> _start() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    try {
      final gp = Provider.of<GameProvider>(context, listen: false);
      gp.audio.playCoins();
      await gp.startNewGame(name);
    } catch (_) {}
    if (mounted) _goToGame();
  }

  @override
  Widget build(BuildContext context) {
    
    if (_checking) return _loadingScreen();

    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(children: [
          
          _BackgroundScene(sparkle: _sparkle, cloud: _cloud, heart: _heart),

          
          Positioned(
            top: 44, left: 0, right: 0,
            child: SafeArea(child: _buildTitle()),
          ),

          
          if (_hasSave && !_showInput)
            Positioned(
              top: 0, right: 12,
              child: SafeArea(
                child: GestureDetector(
                  onTap: _goToGame,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('⏩', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 5),
                      Text('Bỏ qua', style: TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ),
            ),

          
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildNpcPanel(),
          ),
        ]),
      ),
    );
  }

  Widget _loadingScreen() => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
        ),
      ),
      child: Stack(children: [
        
        const Positioned(top: 80, left: 30, child: Text('🌸', style: TextStyle(fontSize: 28))),
        const Positioned(top: 120, right: 40, child: Text('🌻', style: TextStyle(fontSize: 24))),
        const Positioned(bottom: 140, left: 50, child: Text('🌺', style: TextStyle(fontSize: 26))),
        const Positioned(bottom: 180, right: 30, child: Text('🌷', style: TextStyle(fontSize: 22))),

        Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceCtrl,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _bounce.value * 0.5),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.4),
                          blurRadius: 30, spreadRadius: 8),
                    ],
                  ),
                  child: const Text('🌾', style: TextStyle(fontSize: 68)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('NÔNG TRẠI XANH',
                style: TextStyle(color: Color(0xFF1B5E20), fontSize: 28,
                    fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('Đang khởi động nông trại...', style: TextStyle(
                color: Colors.green.shade700, fontSize: 14)),
            const SizedBox(height: 8),
            Text('🌱 Bà Nội đang chờ bạn 👵', style: TextStyle(
                color: Colors.green.shade600, fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.green.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        )),
      ]),
    ),
  );

  Widget _buildTitle() {
    return Column(children: [
      AnimatedBuilder(
        animation: _bounce,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _bounce.value * 0.35),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.55),
                    blurRadius: 28, spreadRadius: 6),
                BoxShadow(color: const Color(0xFFF48FB1).withOpacity(0.3),
                    blurRadius: 16, spreadRadius: 2),
              ],
            ),
            child: const Text('🌾', style: TextStyle(fontSize: 52)),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text('NÔNG TRẠI XANH',
        style: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w900,
          color: Color(0xFF1B5E20), letterSpacing: 2,
          shadows: [
            Shadow(color: Colors.white, blurRadius: 12, offset: Offset(0, 2)),
            Shadow(color: Color(0xFFA5D6A7), blurRadius: 18, offset: Offset(0, 4)),
          ],
        ),
      ),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFFBA68C8)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFF48FB1).withOpacity(0.4),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: const Text('🌸 Hành trình nông trại kỳ diệu! 🌸',
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _buildNpcPanel() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 0, right: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          AnimatedBuilder(
            animation: _bounce,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _bounce.value),
              child: _buildNpcAvatar(),
            ),
          ),
          const SizedBox(height: 4),

          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8D6E63), Color(0xFF4E342E)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.4),
                  blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('👵', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Bà Nội',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(width: 4),
              Text('💬', style: TextStyle(fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 8),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15), end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: _showInput ? _nameCard() : _dialogCard(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNpcAvatar() {
    return Stack(alignment: Alignment.center, children: [
      
      AnimatedBuilder(
        animation: _heart,
        builder: (_, __) => Container(
          width: 106, height: 106,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF48FB1).withOpacity(_heart.value * 0.6),
                blurRadius: 28, spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
      
      Container(
        width: 94, height: 94,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF48FB1).withOpacity(0.5), width: 3),
          gradient: const RadialGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFFFE4EE)],
          ),
        ),
      ),
      
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF48FB1), width: 3),
          boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.25),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Center(child: Text('👵', style: TextStyle(fontSize: 44))),
      ),
      
      Positioned(right: 6, bottom: 6,
        child: Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF66BB6A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 6)],
          ),
          child: const Center(child: Text('💬', style: TextStyle(fontSize: 10))),
        ),
      ),
      
      AnimatedBuilder(
        animation: _heart,
        builder: (_, __) => Positioned(
          top: 0, left: 4,
          child: Opacity(
            opacity: _heart.value,
            child: Text('💕', style: TextStyle(fontSize: 14 + _heart.value * 4)),
          ),
        ),
      ),
    ]);
  }

  Widget _dialogCard() => Container(
    key: const ValueKey('dialog'),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.97),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: const Color(0xFFF48FB1), width: 2.5),
      boxShadow: [
        BoxShadow(color: const Color(0xFFF48FB1).withOpacity(0.28),
            blurRadius: 22, offset: const Offset(0, 8)),
        BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.10),
            blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF48FB1).withOpacity(0.3)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          child: Text(
            _dialogs[_step],
            key: ValueKey(_step),
            style: const TextStyle(
              fontSize: 15, color: Color(0xFF333333),
              height: 1.6, fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      const SizedBox(height: 14),

      Row(children: [
        
        Expanded(child: Row(children: List.generate(_dialogs.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == _step ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            gradient: i == _step
                ? const LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFFBA68C8)])
                : null,
            color: i == _step ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        )))),

        
        Row(children: [
          
          if (_hasSave) ...[
            GestureDetector(
              onTap: _goToGame,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text('⏩ Bỏ qua',
                  style: TextStyle(fontSize: 11, color: Color(0xFF5D4037),
                      fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
          ],

          
          GestureDetector(
            onTap: _next,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF66BB6A).withOpacity(0.45),
                  blurRadius: 10, offset: const Offset(0, 4),
                )],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  _step < _dialogs.length - 1
                      ? 'Tiếp'
                      : (_hasSave ? '🎮 Chơi ngay' : '✏️ Nhập tên'),
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (_step < _dialogs.length - 1) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ]),
            ),
          ),
        ]),
      ]),
    ]),
  );

  Widget _nameCard() => Container(
    key: const ValueKey('name'),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.97),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
      boxShadow: [
        BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.28),
            blurRadius: 22, offset: const Offset(0, 8)),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF43A047)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('🌱 Đặt tên cho mình nhé!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF66BB6A), width: 1.8),
        ),
        child: TextField(
          controller: _nameCtrl,
          maxLength: 16,
          autofocus: true,
          onSubmitted: (_) => _start(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32)),
          decoration: InputDecoration(
            hintText: 'Tên của bạn...',
            hintStyle: TextStyle(color: Colors.green.shade300, fontSize: 14),
            border: InputBorder.none,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 4),
              child: Text('🌸', style: TextStyle(fontSize: 20)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _start,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
              color: const Color(0xFF66BB6A).withOpacity(0.5),
              blurRadius: 14, offset: const Offset(0, 5),
            )],
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('🚀', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Text('Bắt đầu phiêu lưu!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
        ),
      ),
    ]),
  );
}




class _BackgroundScene extends StatelessWidget {
  final Animation<double> sparkle;
  final Animation<double> cloud;
  final Animation<double> heart;
  const _BackgroundScene({required this.sparkle, required this.cloud, required this.heart});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(children: [
      
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC), 
              Color(0xFFFCE4EC), 
              Color(0xFFFFF9C4), 
              Color(0xFFDCEDC8), 
            ],
            stops: [0.0, 0.28, 0.58, 1.0],
          ),
        ),
      ),

      
      Positioned(
        top: h * 0.05, right: w * 0.08,
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.6),
                  blurRadius: 24, spreadRadius: 8),
            ],
          ),
          child: const Center(child: Text('☀️', style: TextStyle(fontSize: 32))),
        ),
      ),

      
      AnimatedBuilder(
        animation: cloud,
        builder: (_, __) {
          final off = cloud.value * w * 0.5;
          return Stack(children: [
            Positioned(top: h * 0.10, left: off - 80,
                child: _cloudWidget(90, 0.75)),
            Positioned(top: h * 0.16, left: w * 0.28 + off * 0.35,
                child: _cloudWidget(65, 0.55)),
            Positioned(top: h * 0.07, right: w * 0.05 - off * 0.2,
                child: _cloudWidget(55, 0.45)),
            Positioned(top: h * 0.20, left: w * 0.55 + off * 0.2,
                child: _cloudWidget(50, 0.35)),
          ]);
        },
      ),

      
      Positioned(
        top: h * 0.06, left: w * 0.1, right: w * 0.1,
        child: const _RainbowArc(),
      ),

      
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: Container(height: h * 0.30,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF8BC34A), Color(0xFF558B2F), Color(0xFF33691E)],
            ),
          ),
        ),
      ),

      
      Positioned(bottom: h * 0.23, left: w * 0.06,
        child: const _CuteHouse()),

      
      Positioned(bottom: h * 0.24, left: w * 0.48,
          child: const Text('🌳', style: TextStyle(fontSize: 54))),
      Positioned(bottom: h * 0.24, left: w * 0.63,
          child: const Text('🌲', style: TextStyle(fontSize: 46))),
      Positioned(bottom: h * 0.24, right: w * 0.05,
          child: const Text('🌴', style: TextStyle(fontSize: 48))),
      Positioned(bottom: h * 0.22, left: w * 0.38,
          child: const Text('🌿', style: TextStyle(fontSize: 22))),
      Positioned(bottom: h * 0.22, right: w * 0.18,
          child: const Text('🌿', style: TextStyle(fontSize: 20))),

      
      Positioned(bottom: h * 0.20, left: 0, right: 0,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text('🌸', style: TextStyle(fontSize: 20)),
            Text('🌻', style: TextStyle(fontSize: 22)),
            Text('🌺', style: TextStyle(fontSize: 18)),
            Text('🌼', style: TextStyle(fontSize: 20)),
            Text('🌷', style: TextStyle(fontSize: 18)),
            Text('🌹', style: TextStyle(fontSize: 20)),
            Text('💐', style: TextStyle(fontSize: 22)),
          ]),
        ),
      ),

      
      Positioned(bottom: h * 0.21, left: w * 0.27, right: w * 0.27,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => Container(
            width: 18, height: 12,
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
          )),
        ),
      ),

      
      Positioned(bottom: h * 0.22, left: w * 0.40,
          child: const Text('🐔', style: TextStyle(fontSize: 28))),
      Positioned(bottom: h * 0.22, right: w * 0.20,
          child: const Text('🐄', style: TextStyle(fontSize: 32))),
      Positioned(bottom: h * 0.22, left: w * 0.32,
          child: const Text('🐑', style: TextStyle(fontSize: 24))),
      Positioned(bottom: h * 0.23, right: w * 0.32,
          child: const Text('🐰', style: TextStyle(fontSize: 22))),

      
      AnimatedBuilder(
        animation: sparkle,
        builder: (_, __) {
          final t = sparkle.value;
          return Stack(children: [
            Positioned(
              left: w * 0.15 + (t * w * 0.12),
              top: h * 0.28 + (_sin(t * 3.14 * 2) * 20),
              child: Opacity(opacity: 0.9, child: const Text('🦋', style: TextStyle(fontSize: 18))),
            ),
            Positioned(
              right: w * 0.12 + (t * w * 0.08),
              top: h * 0.32 + (_sin(t * 3.14 * 2 + 1) * 18),
              child: Opacity(opacity: 0.7, child: const Text('🦋', style: TextStyle(fontSize: 14))),
            ),
          ]);
        },
      ),

      
      AnimatedBuilder(
        animation: sparkle,
        builder: (_, __) {
          final List<_SparklePoint> pts = [
            _SparklePoint(0.10, 0.04, '✨', 14),
            _SparklePoint(0.88, 0.08, '⭐', 11),
            _SparklePoint(0.52, 0.03, '💫', 16),
            _SparklePoint(0.22, 0.13, '🌟', 10),
            _SparklePoint(0.76, 0.15, '✨', 13),
            _SparklePoint(0.38, 0.09, '⭐', 11),
            _SparklePoint(0.65, 0.06, '💫', 12),
          ];
          return Stack(children: pts.map((p) {
            final opacity = ((sparkle.value + p.phase) % 1.0) < 0.5 ? 0.95 : 0.25;
            return Positioned(
              left: w * p.x, top: h * p.y,
              child: Opacity(opacity: opacity,
                child: Text(p.emoji, style: TextStyle(fontSize: p.size))),
            );
          }).toList());
        },
      ),
    ]);
  }

  double _sin(double a) {
    final t = a % 6.2832;
    if (t < 1.5708) return t / 1.5708;
    if (t < 3.1416) return (3.1416 - t) / 1.5708;
    if (t < 4.7124) return -((t - 3.1416) / 1.5708);
    return -((6.2832 - t) / 1.5708);
  }

  Widget _cloudWidget(double width, double opacity) => Opacity(
    opacity: opacity,
    child: Container(
      width: width, height: width * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.25),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 10)],
      ),
    ),
  );
}

class _RainbowArc extends StatelessWidget {
  const _RainbowArc();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(painter: _RainbowPainter()),
    );
  }
}

class _RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFF5252).withOpacity(0.6),
      const Color(0xFFFF9800).withOpacity(0.55),
      const Color(0xFFFFEB3B).withOpacity(0.55),
      const Color(0xFF4CAF50).withOpacity(0.5),
      const Color(0xFF29B6F6).withOpacity(0.5),
      const Color(0xFF7E57C2).withOpacity(0.45),
    ];
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    for (int i = 0; i < colors.length; i++) {
      final strokeW = 5.0;
      final inset = i * strokeW + i * 1.5;
      canvas.drawArc(
        rect.deflate(inset),
        3.1416, 3.1416, false,
        Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = strokeW,
      );
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _SparklePoint {
  final double x, y, phase, size;
  final String emoji;
  const _SparklePoint(this.x, this.y, this.emoji, this.size) : phase = x;
}

class _CuteHouse extends StatelessWidget {
  const _CuteHouse();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96, height: 96,
      child: CustomPaint(painter: _HousePainter()),
    );
  }
}

class _HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(w * 0.08, h * 0.48, w * 0.88, h * 0.55), 6, 6),
      Paint()..color = Colors.black.withOpacity(0.12),
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(w * 0.05, h * 0.44, w * 0.9, h * 0.56), 7, 7),
      Paint()..color = const Color(0xFFFFCCBC),
    );
    
    final texP = Paint()..color = const Color(0xFF8D6E63).withOpacity(0.06)..strokeWidth = 1;
    for (double y = h * 0.52; y < h; y += h * 0.10) {
      canvas.drawLine(Offset(w * 0.05, y), Offset(w * 0.95, y), texP);
    }
    
    canvas.drawRect(
      Rect.fromLTWH(w * 0.72, h * 0.08, w * 0.14, h * 0.38),
      Paint()..color = const Color(0xFF8D6E63),
    );
    
    canvas.drawRect(
      Rect.fromLTWH(w * 0.68, h * 0.06, w * 0.22, h * 0.06),
      Paint()..color = const Color(0xFF5D4037),
    );
    
    final roof = Path()
      ..moveTo(0, h * 0.44)
      ..lineTo(w / 2, h * 0.04)
      ..lineTo(w, h * 0.44)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFB71C1C));
    
    final roofHL = Path()
      ..moveTo(w * 0.1, h * 0.42)
      ..lineTo(w / 2, h * 0.08)
      ..lineTo(w * 0.5, h * 0.14)
      ..lineTo(w * 0.14, h * 0.46)
      ..close();
    canvas.drawPath(roofHL, Paint()..color = Colors.white.withOpacity(0.15));
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(w * 0.12, h * 0.54, w * 0.28, h * 0.22), 3, 3),
      Paint()..color = const Color(0xFF90CAF9),
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(w * 0.14, h * 0.56, w * 0.07, h * 0.06), 2, 2),
      Paint()..color = Colors.white.withOpacity(0.7),
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(w * 0.56, h * 0.60, w * 0.28, h * 0.40), 4, 4),
      Paint()..color = const Color(0xFF795548),
    );
    
    canvas.drawCircle(
      Offset(w * 0.74, h * 0.80),
      2.5, Paint()..color = const Color(0xFFFFD700),
    );
    
    final tp = TextPainter(
      text: const TextSpan(text: '💨', style: TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.70, 0));
  }
  @override
  bool shouldRepaint(_) => false;
}
