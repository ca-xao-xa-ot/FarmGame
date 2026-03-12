// ================================================================
//  SHOP DIALOG  v6  –  Buy seeds & animals (locked by level)
//  ✅ Locked item shows grey + 🔒 + required level
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class ShopDialog extends StatefulWidget {
  const ShopDialog({super.key});
  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (_, gp, __) {
      final lv = gp.player?.level ?? 1;
      return Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Row(children: [
              const Text('🏪', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Cửa Hàng Nông Trại',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E))),
              ),
              // Level chip
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Lv $lv',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              // Gold
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('${gp.player?.gold ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ),
            ]),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFD7CCC8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF5D4037),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '🌱 Hạt Giống'),
                Tab(text: '🐾 Vật Nuôi'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _SeedsTab(gp: gp),
                _AnimalsTab(gp: gp),
              ],
            ),
          ),

          // Close
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

// ── Seeds tab ───────────────────────────────────────────────────
class _SeedsTab extends StatelessWidget {
  final GameProvider gp;
  const _SeedsTab({required this.gp});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.28,
      children: CropType.values.map((crop) {
        final owned   = gp.player?.inventory.seeds[crop] ?? 0;
        final canBuy  = (gp.player?.gold ?? 0) >= crop.seedCost;
        final unlocked = gp.isCropUnlocked(crop);
        return _SeedCard(
          crop: crop,
          owned: owned,
          canBuy: canBuy,
          unlocked: unlocked,
          playerLevel: gp.player?.level ?? 1,
          onBuy: (qty) => gp.buySeed(crop, qty),
        );
      }).toList(),
    );
  }
}

class _SeedCard extends StatelessWidget {
  final CropType crop;
  final int owned;
  final bool canBuy;
  final bool unlocked;
  final int playerLevel;
  final Function(int) onBuy;

  const _SeedCard({
    required this.crop,
    required this.owned,
    required this.canBuy,
    required this.unlocked,
    required this.playerLevel,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !unlocked;
    final enabledBuy = canBuy && unlocked;

    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD7CCC8)),
          boxShadow: [BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 6, offset: const Offset(0, 2),
          )],
        ),
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(crop.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 2),
              Text(crop.label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4E342E))),
              Text('Có: $owned hạt',
                style: TextStyle(fontSize: 10,
                  color: owned > 0 ? const Color(0xFF2E7D32) : Colors.grey)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _BuyBtn(
                  label: '×5\n${crop.seedCost * 5}🪙',
                  enabled: enabledBuy,
                  color: const Color(0xFF66BB6A),
                  onTap: () => onBuy(5),
                ),
                _BuyBtn(
                  label: '×1\n${crop.seedCost}🪙',
                  enabled: enabledBuy,
                  color: const Color(0xFF4CAF50),
                  onTap: () => onBuy(1),
                ),
              ]),
            ],
          ),

          if (locked)
            Positioned(
              top: 6, right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('🔒 Lv${crop.unlockLevel}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
      ),
    );
  }
}

class _BuyBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _BuyBtn({
    required this.label,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.grey,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    ),
  );
}

// ── Animals tab ────────────────────────────────────────────────
class _AnimalsTab extends StatelessWidget {
  final GameProvider gp;
  const _AnimalsTab({required this.gp});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      children: AnimalType.values.map((type) {
        final count  = gp.animals.where((a) => a.type == type).length;
        final max    = type.maxCount;
        final unlocked = gp.isAnimalUnlocked(type);
        final canBuy = unlocked && (gp.player?.gold ?? 0) >= type.buyCost && count < max;

        return Opacity(
          opacity: unlocked ? 1.0 : 0.55,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD7CCC8)),
              boxShadow: [BoxShadow(
                color: Colors.brown.withOpacity(0.08),
                blurRadius: 6, offset: const Offset(0, 2),
              )],
            ),
            child: Stack(children: [
              Row(children: [
                // Emoji
                Column(children: [
                  Text(type.babyEmoji, style: const TextStyle(fontSize: 28)),
                  Text('→', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                  Text(type.emoji, style: const TextStyle(fontSize: 28)),
                ]),
                const SizedBox(width: 14),

                // Info
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4E342E))),
                    Text('Sản phẩm: ${type.produce}',
                      style: const TextStyle(fontSize: 11, color: Colors.brown)),
                    Text('Lớn sau ${type.daysToAdult} ngày  •  Thức ăn ${type.feedCost}🪙/ngày',
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: max == 0 ? 0 : (count / max).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              count >= max ? Colors.red : const Color(0xFF4CAF50)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$count/$max',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: count >= max ? Colors.red : const Color(0xFF2E7D32),
                        ),
                      ),
                    ]),
                  ],
                )),

                const SizedBox(width: 10),
                // Buy button
                GestureDetector(
                  onTap: canBuy ? () => gp.buyAnimal(type) : () {
                    if (!unlocked) {
                      gp.showToast('🔒 Cần Lv${type.unlockLevel} để mua ${type.label}!');
                    } else if (count >= max) {
                      gp.showToast('Đã đủ $max con ${type.label}!');
                    } else {
                      gp.showToast('Không đủ 🪙!');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: canBuy ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Mua', style: TextStyle(
                        color: canBuy ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold, fontSize: 12,
                      )),
                      Text('${type.buyCost}🪙', style: TextStyle(
                        color: canBuy ? Colors.white70 : Colors.grey,
                        fontSize: 10,
                      )),
                    ]),
                  ),
                ),
              ]),

              if (!unlocked)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('🔒 Lv${type.unlockLevel}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
