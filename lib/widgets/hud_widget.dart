import 'package:flutter/material.dart';
import '../providers/game_provider.dart';

class HudWidget extends StatelessWidget {
  final GameProvider gp;
  const HudWidget({super.key, required this.gp});

  @override
  Widget build(BuildContext context) {
    final p = gp.player;
    if (p == null) return const SizedBox();

    final expNeed = gp.expToNextLevel;
    final expCur = p.exp;
    final expProg = expNeed <= 0 ? 0.0 : (expCur / expNeed).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (context, c) {
      final narrow = c.maxWidth < 390;

      final goldFont = narrow ? 15.0 : 18.0;
      final nameFont = narrow ? 11.0 : 12.0;
      final subFont = narrow ? 8.5 : 9.5;
      final chipEmoji = narrow ? 12.0 : 13.0;
      final chipFont = narrow ? 10.0 : 11.0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.62),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: Avatar + Name + Level + Gold ─────────────
            Row(children: [
              GestureDetector(
                onTap: () => _showTutorial(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5DEB3),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  ),
                  child: const Center(
                    child: Text('🧑‍🌾', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Row(children: [
                  Expanded(
                    child: Text(
                      p.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: nameFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Lv ${p.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(width: 8),
              Row(children: [
                const Text('🪙', style: TextStyle(fontSize: 17)),
                const SizedBox(width: 3),
                Text(
                  '${p.gold}',
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: goldFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ]),

            const SizedBox(height: 6),

            // ── Row 2: Day + XP + inventory (Wrap) ─────────────
            Row(children: [
              Text(
                '☀️ Ngày ${p.currentDay}',
                style: TextStyle(color: Colors.yellow, fontSize: subFont + 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: expProg,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$expCur/$expNeed',
                style: TextStyle(color: Colors.white70, fontSize: subFont),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 2,
                  children: [
                    _chip('🐟', p.inventory.fishCount, chipEmoji, chipFont),
                    _chip('🥚', p.inventory.eggCount, chipEmoji, chipFont),
                    _chip('🥛', p.inventory.milkCount, chipEmoji, chipFont),
                  ],
                ),
              ),
            ]),
          ],
        ),
      );
    });
  }

  Widget _chip(String e, int n, double emojiSize, double fontSize) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(e, style: TextStyle(fontSize: emojiSize)),
          const SizedBox(width: 2),
          Text('$n', style: TextStyle(color: Colors.white, fontSize: fontSize)),
        ]),
      );

  void _showTutorial(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Text('📖 ', style: TextStyle(fontSize: 22)),
          Text('Hướng Dẫn', style: TextStyle(color: Color(0xFF2E7D32))),
        ]),
        content: const SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _TItem('🕹️', 'Di chuyển', 'WASD / D-pad / ↑↓←→'),
            _TItem('🖱️', 'Click nhanh', 'Click chuột = tương tác như Space/E'),
            _TItem('⌨️', 'Tương tác', 'E hoặc Space'),
            _TItem('🌙', 'Đi ngủ', 'Phím F hoặc bấm 🌙'),
            _TItem('🏪', 'Shop', 'Mua hạt + vật nuôi (mở khóa theo Level)'),
            _TItem('🎒', 'Túi hạt giống', 'Xem tất cả hạt đã mua & chọn nhanh'),
            _TItem('📋', 'Nhiệm vụ', 'Bấm nút 📋 để xem nhiệm vụ mỗi ngày'),
          ]),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('👍 Hiểu rồi!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TItem extends StatelessWidget {
  final String icon, title, desc;
  const _TItem(this.icon, this.title, this.desc);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 26, child: Text(icon, style: const TextStyle(fontSize: 18))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF1B5E20))),
              Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF555555))),
            ]),
          ),
        ]),
      );
}
