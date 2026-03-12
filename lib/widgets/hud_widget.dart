






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
    final expCur  = p.exp;
    final expProg = expNeed <= 0 ? 0.0 : (expCur / expNeed).clamp(0.0, 1.0);
    final isNight = gp.isNight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNight
              ? [
                  const Color(0xFF1A237E).withOpacity(0.88),
                  const Color(0xFF283593).withOpacity(0.85),
                ]
              : [
                  const Color(0xFF1B5E20).withOpacity(0.85),
                  const Color(0xFF2E7D32).withOpacity(0.82),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.15), width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isNight ? const Color(0xFF1A237E) : const Color(0xFF1B5E20))
                .withOpacity(0.4),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        
        GestureDetector(
          onTap: () => _showTutorial(context),
          child: Stack(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                boxShadow: [BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 6, spreadRadius: 1,
                )],
              ),
              child: const Center(child: Text('🧑‍🌾', style: TextStyle(fontSize: 19))),
            ),
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Center(
                  child: Text('?', style: TextStyle(
                      color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 8),

        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    p.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.bold, letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('⭐ Lv ${p.level}',
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 9, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(
                    isNight ? '🌙 Đ${p.currentDay}' : '☀️ Đ${p.currentDay}',
                    style: TextStyle(
                      color: isNight ? Colors.lightBlue.shade200 : Colors.yellow,
                      fontSize: 9, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 3),
              
              Row(children: [
                const Text('✨', style: TextStyle(fontSize: 8)),
                const SizedBox(width: 3),
                Expanded(
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: expProg,
                        minHeight: 7,
                        backgroundColor: Colors.white.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                      ),
                    ),
                    
                    if (expProg > 0.05)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: expProg,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.2),
                                  Colors.transparent,
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(width: 4),
                Text('$expCur/$expNeed',
                  style: const TextStyle(color: Colors.white60, fontSize: 8)),
              ]),
            ],
          ),
        ),

        const SizedBox(width: 8),

        
        Container(
          constraints: const BoxConstraints(minWidth: 44, maxWidth: 76),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🪙', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 2),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${p.gold}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 15, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]),
        ),

        const SizedBox(width: 5),

        
        Wrap(spacing: 3, runSpacing: 2, children: [
          _chip('🐟', p.inventory.fishCount),
          _chip('🥚', p.inventory.eggCount),
          _chip('🥛', p.inventory.milkCount),
          _chip('🧶', p.inventory.woolCount),
          _chip('🍯', p.inventory.honeyCount),
        ]),
      ]),
    );
  }

  Widget _chip(String e, int n) {
    if (n <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(e, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text('$n', style: const TextStyle(
          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold,
        )),
      ]),
    );
  }

  void _showTutorial(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8E1), Color(0xFFE8F5E9)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20, offset: const Offset(0, 8),
            )],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(children: [
                Text('📖', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Text('Hướng Dẫn Chơi', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
            ),
            const SizedBox(height: 14),
            
            const _TItem('🕹️', 'Di chuyển', 'WASD / D-pad / ↑↓←→'),
            const _TItem('⚡', 'Tương tác', 'E hoặc nút ⚡ trên D-pad'),
            const _TItem('🌙', 'Đi ngủ', 'Phím F hoặc bấm 🌙'),
            const _TItem('🏪', 'Shop', 'Mua hạt giống & vật nuôi'),
            const _TItem('🐾', 'Vật nuôi', 'Cho ăn hàng ngày để nhận sản phẩm'),
            const _TItem('🎣', 'Câu cá', 'Đứng cạnh ao → dùng cần câu'),
            const _TItem('🏠', 'Nhà', 'Vào nhà để ngủ & nấu ăn'),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('👍 Hiểu rồi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TItem extends StatelessWidget {
  final String icon, title, desc;
  const _TItem(this.icon, this.title, this.desc);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B5E20))),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037))),
      ])),
    ]),
  );
}
