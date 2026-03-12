import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  int  _step         = 0;
  bool _showInput    = false;
  bool _checking     = true;
  final _nameCtrl    = TextEditingController();

  static const _dialogs = [
    '👵  Cháu ơi, bà đã già không còn sức chăm mảnh đất này nữa...',
    '👵  Bà giao lại nó cho cháu. Hãy biến nơi đây thành một nông trại tươi đẹp nhé!',
    '👵  Nhưng trước tiên... tên cháu là gì để bà gọi cho thân mật nào? 🌸',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _checkSave();
  }

  Future<void> _checkSave() async {
    final gp = Provider.of<GameProvider>(context, listen: false);
    final ok = await gp.tryLoadSavedGame();

    if (mounted && ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen()));
    } else if (mounted) {
      setState(() => _checking = false);

      // 🎵 1. BẬT NHẠC NỀN KHI BẮT ĐẦU CÂU CHUYỆN
      gp.audio.startDayBgm();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  void _next() {
    // 🎵 2. PHÁT ÂM THANH "CLICK" KHI CHUYỂN THOẠI
    Provider.of<GameProvider>(context, listen: false).audio.playSleep();

    if (_step < _dialogs.length - 1) {
      setState(() => _step++);
    } else {
      setState(() => _showInput = true);
    }
  }

  Future<void> _start() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    // Phát âm thanh xác nhận khi bấm Bắt đầu
    Provider.of<GameProvider>(context, listen: false).audio.playCoins();

    await Provider.of<GameProvider>(context, listen: false).startNewGame(name);
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B5E20),
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌾', style: TextStyle(fontSize: 60)),
            SizedBox(height: 14),
            Text('Nông Trại Xanh', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.greenAccent),
          ],
        )),
      );
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF87CEEB), Color(0xFFA8E063), Color(0xFF7EC850)],
            ),
          ),
          child: Stack(children: [
            CustomPaint(painter: _BgPainter(), size: Size.infinite),
            // Title
            const Positioned(
              top: 56, left: 0, right: 0,
              child: Column(children: [
                Text('🌾', style: TextStyle(fontSize: 60)),
                SizedBox(height: 6),
                Text('NÔNG TRẠI XANH',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20),
                        shadows: [Shadow(color: Colors.white, blurRadius: 4, offset: Offset(1,1))])),
              ]),
            ),
            // Dialog / Name input
            Align(
              alignment: Alignment.bottomCenter,
              child: _showInput ? _nameCard() : _dialogCard(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _dialogCard() => Container(
    margin: const EdgeInsets.all(14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.96),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 10, offset: const Offset(0,4))],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF8D6E63), width: 2)),
            child: const Center(child: Text('👵', style: TextStyle(fontSize: 34)))),
        const SizedBox(width: 12),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Text(_dialogs[_step], key: ValueKey(_step),
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.45)),
        )),
      ]),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${_step+1}/${_dialogs.length}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10)),
          child: Text(_step < _dialogs.length - 1 ? 'Tiếp ▶' : 'Nhập tên ✏️',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]),
    ]),
  );

  Widget _nameCard() => Container(
    margin: const EdgeInsets.all(14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.97),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF8D6E63), width: 2)),
            child: const Center(child: Text('👵', style: TextStyle(fontSize: 34)))),
        const SizedBox(width: 12),
        const Expanded(child: Text('Hãy nhập tên của cháu nhé! 💖',
            style: TextStyle(fontSize: 14, color: Color(0xFF333333)))),
      ]),
      const SizedBox(height: 14),
      TextField(
        controller: _nameCtrl,
        maxLength: 16,
        autofocus: true,
        onSubmitted: (_) => _start(),
        decoration: InputDecoration(
          hintText: 'Tên của bạn...',
          prefixIcon: const Text('🧑‍🌾', style: TextStyle(fontSize: 20)),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
          filled: true, fillColor: const Color(0xFFF1F8E9),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('🌾 Bắt đầu hành trình!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          )),
    ]),
  );
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()..color = const Color(0xFF7EC850);
    canvas.drawRect(Rect.fromLTWH(0, size.height*0.62, size.width, size.height*0.38), g);
    final t = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(size.width*0.1, size.height*0.58), 32, t);
    canvas.drawCircle(Offset(size.width*0.85, size.height*0.54), 42, t);
    final tr = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTWH(size.width*0.1-5, size.height*0.58, 10, 26), tr);
    canvas.drawRect(Rect.fromLTWH(size.width*0.85-6, size.height*0.54, 12, 32), tr);
    final h = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawRect(Rect.fromLTWH(size.width*0.38, size.height*0.52, 82, 72), h);
    final roof = Path()
      ..moveTo(size.width*0.36, size.height*0.52)
      ..lineTo(size.width*0.38+41, size.height*0.36)
      ..lineTo(size.width*0.38+82+16, size.height*0.52)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFC62828));
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}