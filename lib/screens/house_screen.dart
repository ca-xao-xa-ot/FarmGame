









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
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8F2), Color(0xFFFFF0D8), Color(0xFFE8D5C0)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          
          CustomPaint(painter: _CuteFloorPainter(), size: Size.infinite),

          
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFFFF8F2)],
                ),
              ),
            ),
          ),

          
          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              child: const _WallFlowers(),
            ),
          ),

          
          SafeArea(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => gp.exitHouse(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8D6E63), Color(0xFF5D4037)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.35),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Row(children: [
                    Icon(Icons.arrow_back_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Ra ngoài', style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 12)),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF66BB6A), width: 1),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.1),
                      blurRadius: 6)],
                ),
                child: Row(children: [
                  const Text('🏠 ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(
                    'Ngôi Nhà Ấm Áp  •  Ngày ${gp.player?.currentDay ?? 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32)),
                    overflow: TextOverflow.ellipsis,
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('🪙 ${gp.player?.gold ?? 0}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                          color: Color(0xFF4E342E))),
                  ),
                ]),
              )),
            ]),
          )),

          
          SafeArea(child: Padding(
            padding: const EdgeInsets.only(top: 54),
            child: _HouseContent(gp: gp),
          )),

          
          if (gp.showMessage)
            Positioned(bottom: 100, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Text(gp.message,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      textAlign: TextAlign.center),
                )),
        ]),
      );
    });
  }
}


class _WallFlowers extends StatelessWidget {
  const _WallFlowers();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      
      for (double x = 0; x < MediaQuery.of(context).size.width; x += 56)
        for (double y = 0; y < MediaQuery.of(context).size.height * 0.40; y += 52)
          Positioned(
            left: x + (y % 112 == 0 ? 28 : 0),
            top: y,
            child: Opacity(
              opacity: 0.12,
              child: Text('🌸', style: TextStyle(fontSize: 18 + (x % 3) * 2)),
            ),
          ),
    ]);
  }
}


class _HouseContent extends StatefulWidget {
  final GameProvider gp;
  const _HouseContent({required this.gp});
  @override
  State<_HouseContent> createState() => _HouseContentState();
}

class _HouseContentState extends State<_HouseContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _catCtrl;
  late Animation<double>   _catAnim;

  @override
  void initState() {
    super.initState();
    _catCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _catAnim = Tween<double>(begin: -4, end: 4)
        .animate(CurvedAnimation(parent: _catCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _catCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(children: [

        
        _grandmaCard(),
        const SizedBox(height: 10),

        
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _weatherWindow()),
          const SizedBox(width: 10),
          Expanded(child: _bookshelf()),
          const SizedBox(width: 10),
          Expanded(child: _tv()),
        ])),
        const SizedBox(height: 10),

        
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _sleepCard()),
          const SizedBox(width: 10),
          Expanded(child: _diaryCard()),
          const SizedBox(width: 10),
          Expanded(child: _kitchenCard()),
        ])),
        const SizedBox(height: 10),

        
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 2, child: _aquarium()),
          const SizedBox(width: 10),
          Expanded(child: _catPet()),
          const SizedBox(width: 10),
          Expanded(child: _flowerPots()),
        ])),
        const SizedBox(height: 10),

        
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _musicPlayer()),
          const SizedBox(width: 10),
          Expanded(child: _dailyGift()),
          const SizedBox(width: 10),
          Expanded(child: _wardrobe()),
        ])),
        const SizedBox(height: 10),

        
        _statsBoard(),
        const SizedBox(height: 12),
      ]),
    );
  }

  
  Widget _grandmaCard() {
    final day = widget.gp.player?.currentDay ?? 1;
    final level = widget.gp.player?.level ?? 1;
    final msgs = [
      'Cháu ơi, nhớ tưới cây mỗi ngày để cây lớn nhanh nhé! 🌱',
      'Vật nuôi cần được cho ăn đều đặn, cháu đừng quên nha! 🐔',
      'Bà thấy nông trại của cháu đẹp lên từng ngày rồi đó! 🌾',
      'Câu cá ở hồ góc trái cũng vui lắm đấy cháu! 🎣',
      'Mua thêm giống mới từ shop để tăng thu nhập nha cháu! 💰',
      'Hoàn thành nhiệm vụ hàng ngày để lên cấp nhanh hơn nhé! ⭐',
      'Bà tự hào về cháu lắm! Nông trại cháu ngày càng phát triển! 💖',
    ];
    final msg = msgs[(day + level) % msgs.length];

    return GestureDetector(
      onTap: () => _showGrandmaDialog(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.4), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFFFF8F00).withOpacity(0.12),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFF9C4), Color(0xFFFFECB3)]),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF8F00), width: 2.5),
              boxShadow: [BoxShadow(color: const Color(0xFFFF8F00).withOpacity(0.3),
                  blurRadius: 10, spreadRadius: 2)],
            ),
            child: const Center(child: Text('👵', style: TextStyle(fontSize: 34))),
          ),
          const SizedBox(width: 12),

          
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Bà Nội', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D4037))),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('NPC', style: TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.3)),
              ),
              child: Text(msg,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4E342E), height: 1.4)),
            ),
          ])),
          const SizedBox(width: 8),

          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFF8F00)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💬', style: TextStyle(fontSize: 18)),
          ),
        ]),
      ),
    );
  }

  
  Widget _weatherWindow() {
    final isNight = widget.gp.isNight;
    return _HouseCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🪟', style: TextStyle(fontSize: 10, color: Colors.grey)),
        const Text('Cửa Sổ', style: TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: isNight
                  ? [const Color(0xFF1A237E), const Color(0xFF283593)]
                  : [const Color(0xFF87CEEB), const Color(0xFFE0F7FA)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF8D6E63), width: 3),
          ),
          child: Stack(children: [
            if (!isNight) ...[
              const Positioned(top: 4, left: 8,
                  child: Text('☁️', style: TextStyle(fontSize: 14))),
              const Positioned(top: 10, right: 6,
                  child: Text('⛅', style: TextStyle(fontSize: 11))),
              const Positioned(bottom: 2, left: 0, right: 0,
                  child: Text('🌿🌾🌻', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11))),
              const Positioned(top: 2, right: 14,
                  child: Text('🐦', style: TextStyle(fontSize: 9))),
            ] else ...[
              const Positioned(top: 4, left: 8,
                  child: Text('🌙', style: TextStyle(fontSize: 18))),
              const Positioned(top: 4, right: 6,
                  child: Text('⭐', style: TextStyle(fontSize: 10))),
              const Positioned(top: 14, right: 16,
                  child: Text('✨', style: TextStyle(fontSize: 8))),
              const Positioned(bottom: 2, left: 0, right: 0,
                  child: Text('🌟', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11))),
            ],
          ]),
        ),
        const SizedBox(height: 4),
        Text(isNight ? '🌙 Đêm khuya' : '☀️ Trời đẹp',
            style: TextStyle(fontSize: 9,
                color: isNight ? Colors.indigo : Colors.orange,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  
  Widget _bookshelf() => _HouseCard(
    onTap: () => _showBookshelf(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      const Text('📚', style: TextStyle(fontSize: 32)),
      const SizedBox(height: 4),
      const Text('Kệ Sách', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(8)),
        child: const Text('Mẹo hay', style: TextStyle(fontSize: 8, color: Color(0xFF8D6E63))),
      ),
    ]),
  );

  
  Widget _tv() => _HouseCard(
    onTap: () => _showTV(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      const Text('📺', style: TextStyle(fontSize: 32)),
      const SizedBox(height: 4),
      const Text('Tivi', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.bold, color: Color(0xFF424242))),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8)),
        child: const Text('Tin tức', style: TextStyle(fontSize: 8, color: Color(0xFF1565C0))),
      ),
    ]),
  );

  
  Widget _sleepCard() => _HouseCard(
    onTap: () => _confirmSleep(context, widget.gp),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1565C0)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.35),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Center(child: Text('🛏️', style: TextStyle(fontSize: 26))),
      ),
      const SizedBox(height: 5),
      const Text('Đi Ngủ', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
      const Text('Sang ngày mới', style: TextStyle(fontSize: 8, color: Colors.grey)),
    ]),
  );

  
  Widget _diaryCard() => _HouseCard(
    onTap: () => _openDiary(context, widget.gp),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.35),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Center(child: Text('📖', style: TextStyle(fontSize: 26))),
      ),
      const SizedBox(height: 5),
      const Text('Nhật Ký', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
      const Text('Kỷ niệm đẹp', style: TextStyle(fontSize: 8, color: Colors.grey)),
    ]),
  );

  
  Widget _kitchenCard() => _HouseCard(
    onTap: () => _showKitchen(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFBF360C)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Center(child: Text('🍳', style: TextStyle(fontSize: 26))),
      ),
      const SizedBox(height: 5),
      const Text('Bếp Nấu', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.bold, color: Color(0xFFBF360C))),
      const Text('🍽️ Nấu ăn', style: TextStyle(fontSize: 8, color: Colors.grey)),
    ]),
  );

  
  Widget _aquarium() {
    return _HouseCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🐠', style: TextStyle(fontSize: 10, color: Color(0xFF0277BD))),
          const Text('Bể Cá', style: TextStyle(fontSize: 9,
              color: Color(0xFF0277BD), fontWeight: FontWeight.bold)),
          const Text('🐡', style: TextStyle(fontSize: 10, color: Color(0xFF0277BD))),
        ]),
        const SizedBox(height: 4),
        Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0277BD), width: 2),
          ),
          child: const Stack(children: [
            Positioned(top: 5, left: 8, child: Text('🐟', style: TextStyle(fontSize: 14))),
            Positioned(top: 16, right: 12, child: Text('🐠', style: TextStyle(fontSize: 12))),
            Positioned(top: 4, right: 30, child: Text('🐡', style: TextStyle(fontSize: 10))),
            Positioned(bottom: 0, left: 0, right: 0,
                child: Text('🌊🪸🌿', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10))),
          ]),
        ),
        const SizedBox(height: 4),
        const Text('🫧 Bể cá dễ thương', style: TextStyle(fontSize: 8, color: Color(0xFF0277BD))),
      ]),
    );
  }

  
  Widget _catPet() => _HouseCard(
    onTap: () => _petCat(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(
        animation: _catAnim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _catAnim.value * 0.3),
          child: const Text('🐱', style: TextStyle(fontSize: 36)),
        ),
      ),
      const SizedBox(height: 4),
      const Text('Mèo Kitty', style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
      const SizedBox(height: 2),
      const Text('💕 Vuốt ve', style: TextStyle(fontSize: 8, color: Colors.pink),
          textAlign: TextAlign.center),
    ]),
  );

  
  Widget _flowerPots() => _HouseCard(
    onTap: () => _showFlowerPots(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      const Text('🌺 Chậu Hoa', style: TextStyle(
          fontSize: 9, color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _pot('🌹', 'Hồng'),
        _pot('🌸', 'Anh Đào'),
      ]),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _pot('🌻', 'Hướng Dương'),
        _pot('🪴', 'Cây Cảnh'),
      ]),
    ]),
  );

  
  Widget _pot(String emoji, String name) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      Container(
        width: 22, height: 14,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFA1887F), Color(0xFF6D4C41)]),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
          border: Border.all(color: const Color(0xFF4E342E), width: 0.5),
        ),
      ),
    ]);
  }

  
  Widget _musicPlayer() {
    final gp = widget.gp;
    return _HouseCard(
      onTap: () {
        try { gp.audio.setEnabled(!gp.audio.enabled); } catch (_) {}
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gp.audio.enabled
                  ? [const Color(0xFFCE93D8), const Color(0xFF7B1FA2)]
                  : [Colors.grey.shade300, Colors.grey.shade500],
            ),
            shape: BoxShape.circle,
            boxShadow: gp.audio.enabled ? [BoxShadow(
              color: const Color(0xFFBA68C8).withOpacity(0.5),
              blurRadius: 12, spreadRadius: 2,
            )] : null,
          ),
          child: Center(child: Text(gp.audio.enabled ? '🎵' : '🔇',
              style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 5),
        const Text('Nhạc Nền', style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
        Text(gp.audio.enabled ? '♪ Đang phát' : 'Tắt nhạc',
            style: TextStyle(fontSize: 8,
                color: gp.audio.enabled ? const Color(0xFFBA68C8) : Colors.grey)),
      ]),
    );
  }

  
  Widget _dailyGift() {
    final gp = widget.gp;
    final day = gp.player?.currentDay ?? 1;
    final lastGift = gp.player?.lastGiftDay ?? 0;
    final canClaim = day > lastGift;
    return _HouseCard(
      onTap: canClaim ? () => _claimGift(context, gp) : null,
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, children: [
        Stack(alignment: Alignment.center, children: [
          if (canClaim)
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.6),
                  blurRadius: 14, spreadRadius: 4,
                )],
              ),
            ),
          Text(canClaim ? '🎁' : '📦',
              style: TextStyle(fontSize: canClaim ? 32 : 28)),
        ]),
        const SizedBox(height: 4),
        Text(canClaim ? 'Phần Thưởng!' : 'Đã Nhận',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                color: canClaim ? const Color(0xFFFF8F00) : Colors.grey)),
        Text(canClaim ? '✨ Nhận ngay!' : '⏳ Ngày mai',
            style: TextStyle(fontSize: 8,
                color: canClaim ? Colors.orange : Colors.grey)),
      ]),
    );
  }

  
  Widget _wardrobe() => _HouseCard(
    onTap: () => _showWardrobe(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFEC407A), Color(0xFF880E4F)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFEC407A).withOpacity(0.4),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Center(child: Text('👗', style: TextStyle(fontSize: 24))),
      ),
      const SizedBox(height: 5),
      const Text('Tủ Đồ', style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
      const Text('Thay trang phục', style: TextStyle(fontSize: 7, color: Colors.grey),
          textAlign: TextAlign.center),
    ]),
  );

  
  Widget _statsBoard() {
    final gp = widget.gp;
    final p = gp.player;
    final expPercent = gp.expToNextLevel > 0
        ? ((p?.exp ?? 0) / gp.expToNextLevel).clamp(0.0, 1.0)
        : 1.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF66BB6A).withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.08),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('📊', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Text('Thống Kê Nông Trại', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        ]),
        const Divider(color: Color(0xFFA5D6A7), height: 14),

        
        Row(children: [
          const Text('⭐', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text('Level ${p?.level ?? 1}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20))),
          const Spacer(),
          Text('${p?.exp ?? 0} / ${gp.expToNextLevel} EXP',
              style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: expPercent,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),

        
        Row(children: [
          Expanded(child: _statCard('📅', 'Ngày', '${p?.currentDay ?? 1}', const Color(0xFF1565C0))),
          const SizedBox(width: 8),
          Expanded(child: _statCard('🪙', 'Vàng', '${p?.gold ?? 0}', const Color(0xFFFF8F00))),
          const SizedBox(width: 8),
          Expanded(child: _statCard('🌾', 'Thu hoạch', '${p?.totalCropsHarvested ?? 0}', const Color(0xFF2E7D32))),
          const SizedBox(width: 8),
          Expanded(child: _statCard('🎣', 'Câu cá', '${p?.totalFishCaught ?? 0}', const Color(0xFF0277BD))),
        ]),
      ]),
    );
  }

  Widget _statCard(String icon, String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey),
          textAlign: TextAlign.center),
    ]),
  );

  

  void _showGrandmaDialog(BuildContext ctx) {
    final gp = widget.gp;
    final level = gp.player?.level ?? 1;
    final allTips = [
      '🌱 Cày đất rồi mới trồng cây nhé! Tưới nước mỗi ngày để cây lớn nhanh.',
      '🐾 Cho vật nuôi ăn đủ để chúng cho sản phẩm. Nhớ thu hoạch đúng lúc!',
      '🎣 Hồ cá ở góc trái bản đồ. Câu cá rồi bán lấy vàng thêm nhé!',
      '💰 Level cao hơn mở khóa cây trồng và vật nuôi quý hiếm hơn.',
      '⭐ Hoàn thành nhiệm vụ hàng ngày để có thêm EXP và vàng!',
      '🏆 Xem bảng xếp hạng để biết mình đứng top mấy trong làng!',
    ];
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('👵', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            const Text('Bà Nội Nói...', style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w900, color: Color(0xFF5D4037))),
            const SizedBox(height: 14),
            ...allTips.map((tip) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.3)),
              ),
              child: Text(tip, style: const TextStyle(fontSize: 12, color: Color(0xFF4E342E),
                  height: 1.4)),
            )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFB74D), Color(0xFFFF8F00)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('💖 Cảm ơn Bà!', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmSleep(BuildContext ctx, GameProvider gp) {
    showDialog(context: ctx, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF0D47A1)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🌙', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          const Text('Đi Ngủ?', style: TextStyle(color: Colors.white,
              fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Sang ngày ${(gp.player?.currentDay ?? 1) + 1}\n'
              '🌱 Cây đã tưới sẽ phát triển\n'
              '🐔🐄 Vật nuôi cần cho ăn lại\n'
              '🎁 Phần thưởng ngày mới!\n'
              '✨ Nhiệm vụ mới chờ đón!',
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text('Ở lại', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                gp.exitHouse();
                await gp.goToSleep();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFF48FB1), Color(0xFFE91E63)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 3),
                  )],
                ),
                child: const Text('😴 Ngủ ngon!', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )),
          ]),
        ]),
      ),
    ));
  }

  void _openDiary(BuildContext ctx, GameProvider gp) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(value: gp, child: const DiaryDialog()),
    );
  }

  void _petCat(BuildContext ctx) {
    const msgs = ['😺 Meo~ cảm ơn bạn! 💕', '😻 Purr purr... 🐱', '🐱 Mèo thích bạn lắm!'];
    final msg = msgs[DateTime.now().millisecond % msgs.length];
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.pink.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  void _showFlowerPots(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 280,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const Text('🌺 Vườn Hoa Mini', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _bigPot('🌹', 'Hoa Hồng', 'Đẹp & lãng mạn'),
            _bigPot('🌸', 'Anh Đào', 'Mùa xuân tươi'),
            _bigPot('🌻', 'Hướng Dương', 'Rực rỡ mặt trời'),
            _bigPot('🌷', 'Hoa Tulip', 'Quý phái'),
            _bigPot('🪴', 'Cây Cảnh', 'Xanh mát'),
          ]),
          const SizedBox(height: 16),
          const Text('🌱 Vườn hoa nhỏ làm ngôi nhà thêm xinh đẹp! 💕',
              style: TextStyle(fontSize: 11, color: Color(0xFF388E3C))),
        ]),
      ),
    );
  }

  Widget _bigPot(String emoji, String name, String desc) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      Container(
        width: 30, height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFA1887F), Color(0xFF6D4C41)]),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32))),
      Text(desc, style: const TextStyle(fontSize: 7, color: Colors.grey)),
    ],
  );

  void _showBookshelf(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFF8D6E63).withOpacity(0.2)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.brown.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const Text('📚 Kệ Sách Nông Trại', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
          const SizedBox(height: 12),
          Expanded(child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _tipCard('🌱 Trồng Trọt', 'Cày đất trước khi trồng. Tưới cây mỗi ngày để thu hoạch nhanh hơn!'),
              _tipCard('🐾 Vật Nuôi', 'Cho ăn vật nuôi mỗi ngày. Vật nuôi trưởng thành mới cho sản phẩm.'),
              _tipCard('🎣 Câu Cá', 'Câu cá ở hồ góc dưới trái bản đồ. Bán cá lấy vàng và EXP.'),
              _tipCard('💰 Kiếm Vàng', 'Thu hoạch và bán hàng nhanh bằng tay. Vật nuôi cho giá trị cao hơn.'),
              _tipCard('⭐ Lên Cấp', 'Thu hoạch nhiều để tăng EXP. Level cao mở khóa giống mới!'),
              _tipCard('🏆 Thành Tích', 'Hoàn thành nhiệm vụ hàng ngày để nhận thưởng đặc biệt!'),
              _tipCard('🌟 Bí Quyết', 'Trồng xen kẽ nhiều loại cây để tối đa hóa thu nhập mỗi ngày!'),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _tipCard(String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.75),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.brown.shade200),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
          color: Color(0xFF4E342E))),
      const SizedBox(height: 4),
      Text(body, style: const TextStyle(fontSize: 11, color: Color(0xFF6D4C41), height: 1.4)),
    ]),
  );

  void _showTV(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF16213E), width: 4),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF533483), width: 2),
            ),
            child: const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📡 TIN TỨC NÔNG TRẠI 📡',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 12,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('🌾 Giá lúa mì tăng 20%', style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text('🐄 Sữa bò khan hiếm mùa này', style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text('🌸 Festival hoa cuối tuần!', style: TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                Text('⭐ Top farmer tuần này đạt Lv.50!', style: TextStyle(color: Colors.yellowAccent, fontSize: 11)),
              ],
            )),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF533483),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('📺 Tắt Tivi', style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    ));
  }

  void _showKitchen(BuildContext ctx) {
    final recipes = [
      {'name': '🍲 Canh Rau', 'ingredients': '🥬×2 + 💧', 'effect': '+20 EXP', 'cost': 50},
      {'name': '🥘 Cơm Trứng', 'ingredients': '🥚×3 + 🌾×2', 'effect': '+2 tốc độ đi', 'cost': 80},
      {'name': '🧀 Phô Mai', 'ingredients': '🥛×5', 'effect': '+50 vàng bonus', 'cost': 120},
      {'name': '🍯 Bánh Mật', 'ingredients': '🍯×2 + 🌾×3', 'effect': '+30 EXP', 'cost': 100},
    ];
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.orange.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const Text('🍳 Bếp Nấu Ăn', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: Color(0xFFBF360C))),
          const SizedBox(height: 4),
          const Text('Nấu ăn để nhận buff đặc biệt!',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 10),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: recipes.length,
            itemBuilder: (_, i) {
              final r = recipes[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.4)),
                ),
                child: Row(children: [
                  Text(r['name'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                          color: Color(0xFF4E342E))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r['ingredients'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.grey))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF66BB6A).withOpacity(0.4)),
                    ),
                    child: Text(r['effect'] as String,
                        style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.gp.showToast('🍳 Đang nấu ${r['name']}... +buff!');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFF7043), Color(0xFFBF360C)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${r['cost']}🪙', style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              );
            },
          )),
        ]),
      ),
    );
  }

  void _claimGift(BuildContext ctx, GameProvider gp) {
    gp.claimDailyGift();
  }

  void _showWardrobe(BuildContext ctx) {
    final outfits = [
      {'emoji': '👩‍🌾', 'name': 'Nông dân', 'desc': 'Trang phục mặc định', 'locked': false},
      {'emoji': '👷', 'name': 'Thợ xây', 'desc': 'Cần Level 5', 'locked': true},
      {'emoji': '👨‍🍳', 'name': 'Đầu bếp', 'desc': 'Cần Level 10', 'locked': true},
      {'emoji': '🧑‍🔬', 'name': 'Nhà khoa học', 'desc': 'Cần Level 20', 'locked': true},
      {'emoji': '🧜‍♀️', 'name': 'Thần nông', 'desc': 'Cần Level 50', 'locked': true},
    ];
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 340,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFCE4EC), Color(0xFFFFE0F0)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.pink.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const Text('👗 Tủ Quần Áo', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: outfits.length,
            itemBuilder: (_, i) {
              final o = outfits[i];
              final locked = o['locked'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: locked
                      ? Colors.grey.shade100
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: locked
                          ? Colors.grey.shade200
                          : const Color(0xFFEC407A).withOpacity(0.4)),
                ),
                child: Row(children: [
                  Text(o['emoji'] as String,
                      style: TextStyle(fontSize: locked ? 26 : 30,
                          color: locked ? Colors.grey : null)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(o['name'] as String,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                            color: locked ? Colors.grey : const Color(0xFF880E4F))),
                    Text(o['desc'] as String,
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ])),
                  locked
                      ? const Text('🔒', style: TextStyle(fontSize: 20))
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFEC407A), Color(0xFF880E4F)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Mặc', style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                ]),
              );
            },
          )),
        ]),
      ),
    );
  }
}




class _HouseCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _HouseCard({required this.child, this.onTap});
  @override
  State<_HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<_HouseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? () {
        _ctrl.forward().then((_) => _ctrl.reverse());
        widget.onTap!();
      } : null,
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0CFC4), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.brown.withOpacity(0.08),
                  blurRadius: 10, offset: const Offset(0, 4)),
              const BoxShadow(color: Colors.white, blurRadius: 2, offset: Offset(0, -1)),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}




class _CuteFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final floorTop = size.height * 0.40;
    final plankH   = 44.0;
    final darkP    = Paint()..color = const Color(0xFFC8A882).withOpacity(0.9);
    final lightP   = Paint()..color = const Color(0xFFD4B896).withOpacity(0.9);
    final lineP    = Paint()
      ..color = const Color(0xFF8D6E63).withOpacity(0.25)
      ..strokeWidth = 1.0;

    int row = 0;
    for (double y = floorTop; y < size.height; y += plankH) {
      final p = row % 2 == 0 ? darkP : lightP;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, plankH), p);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lineP);

      
      final offset = (row % 2) * 80.0;
      for (double x = offset; x < size.width; x += 160) {
        canvas.drawLine(Offset(x, y), Offset(x, y + plankH), lineP);
      }

      
      final grainP = Paint()
        ..color = const Color(0xFF8D6E63).withOpacity(0.07)
        ..strokeWidth = 0.8;
      for (double gx = 12 + offset; gx < size.width; gx += 160) {
        canvas.drawLine(Offset(gx, y + 8), Offset(gx + 40, y + 8), grainP);
        canvas.drawLine(Offset(gx + 8, y + 22), Offset(gx + 55, y + 22), grainP);
      }
      row++;
    }

    
    final rugLeft  = size.width * 0.15;
    final rugTop   = size.height * 0.56;
    final rugW     = size.width * 0.70;
    const rugH     = 120.0;
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(rugLeft, rugTop, rugW, rugH), 14, 14),
      Paint()..color = const Color(0xFFF8BBD0).withOpacity(0.55),
    );
    canvas.drawRRect(
      RRect.fromRectXY(
        Rect.fromLTWH(rugLeft + 8, rugTop + 8, rugW - 16, rugH - 16), 10, 10),
      Paint()
        ..color = const Color(0xFFF48FB1).withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    final flowerP = Paint()..color = const Color(0xFFE91E63).withOpacity(0.15);
    for (double fx = rugLeft + 30; fx < rugLeft + rugW - 20; fx += 60) {
      canvas.drawCircle(Offset(fx, rugTop + rugH / 2), 14, flowerP);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
