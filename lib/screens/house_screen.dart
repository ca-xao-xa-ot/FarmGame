import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/diary_dialog.dart';

class HouseScreen extends StatelessWidget {
  const HouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (_, gp, __) {
      return Scaffold(
        body: Stack(children: [
          // Floor
          Container(decoration: const BoxDecoration(color: Color(0xFFD7CCC8)),
              child: CustomPaint(painter: _FloorPainter(), size: Size.infinite)),

          // Top bar
          SafeArea(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => gp.exitHouse(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.brown.shade500, borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Ra ngoài', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Text('🏠 Ngôi Nhà  –  Ngày ${gp.player?.currentDay ?? 1}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
              const Spacer(),
              // Keyboard hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.brown.shade200, borderRadius: BorderRadius.circular(10)),
                child: const Text('H = Ra ngoài', style: TextStyle(fontSize: 11, color: Color(0xFF4E342E))),
              ),
            ]),
          )),

          // Furniture
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 60),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _FurnitureBtn(
                emoji: '🛏️', label: 'Giường', desc: 'Ngủ → sang ngày mới  [F]',
                color: const Color(0xFF1565C0),
                onTap: () => _confirmSleep(context, gp),
              ),
              _FurnitureBtn(
                emoji: '📖', label: 'Nhật Ký', desc: 'Ghi chú hàng ngày',
                color: const Color(0xFF2E7D32),
                onTap: () => _openDiary(context, gp),
              ),
            ]),
            const SizedBox(height: 36),
            // Window
            Container(
              width: 200, height: 130,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade700, width: 8),
                  borderRadius: BorderRadius.circular(6)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Color(0xFF87CEEB), Color(0xFF98FB98), Color(0xFF7EC850)])),
                    child: const Center(child: Text('🌾🌿🌸', style: TextStyle(fontSize: 30)))),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Cửa sổ nhìn ra nông trại', style: TextStyle(color: Colors.brown, fontSize: 11)),
          ])),

          // Message
          if (gp.showMessage)
            Positioned(bottom: 100, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(22)),
                  child: Text(gp.message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                )),
        ]),
      );
    });
  }

  void _confirmSleep(BuildContext ctx, GameProvider gp) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Text('🌙 ', style: TextStyle(fontSize: 24)), Text('Đi ngủ?')]),
      content: Text('Sang ngày ${(gp.player?.currentDay ?? 1)+1}.\n🌱 Cây đã tưới sẽ lớn.\n🐔🐄 Vật nuôi cần ăn lại.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ở lại')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            gp.exitHouse();
            await gp.goToSleep();
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
          child: const Text('😴 Ngủ thôi!', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _openDiary(BuildContext ctx, GameProvider gp) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(value: gp, child: const DiaryDialog()),
    );
  }
}

class _FurnitureBtn extends StatelessWidget {
  final String emoji, label, desc;
  final Color color;
  final VoidCallback onTap;
  const _FurnitureBtn({required this.emoji, required this.label, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0,4))]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(emoji, style: const TextStyle(fontSize: 46)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ])),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(color: Color(0xFF5D4037), fontSize: 10)),
      ]),
    );
  }
}

class _FloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,size.height), Paint()..color = const Color(0xFFD7CCC8));
    final lp = Paint()..color = const Color(0xFFBCAAA4).withOpacity(0.5)..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0,y), Offset(size.width,y), lp);
    }
    final rug = Paint()..color = const Color(0xFFEF9A9A).withOpacity(0.35);
    canvas.drawRRect(RRect.fromRectXY(
        Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: 300, height: 190), 20, 20), rug);
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}
