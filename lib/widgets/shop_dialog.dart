







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
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (_, gp, __) {
      final lv = gp.player?.level ?? 1;
      return Container(
        height: MediaQuery.of(context).size.height * 0.86,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 44, height: 5,
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('🏪', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cửa Hàng Nông Trại', style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                Text('Mua hạt giống & vật nuôi yêu thích!',
                    style: TextStyle(fontSize: 10, color: Colors.white70)),
              ])),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Column(children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  Text('Lv $lv', style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 6)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('${gp.player?.gold ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 14, color: Color(0xFF4E342E))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),

          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBE9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF43A047)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF8D6E63),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '🌱 Hạt Giống'),
                Tab(text: '🐾 Vật Nuôi'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(child: TabBarView(
            controller: _tab,
            children: [
              _SeedsTab(gp: gp),
              _AnimalsTab(gp: gp),
            ],
          )),

          
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBE9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD7CCC8)),
                ),
                child: const Text('✕  Đóng Cửa Hàng',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: Color(0xFF8D6E63), fontSize: 14)),
              ),
            ),
          ),
        ]),
      );
    });
  }
}


class _SeedsTab extends StatelessWidget {
  final GameProvider gp;
  const _SeedsTab({required this.gp});

  @override
  Widget build(BuildContext context) {
    
    final sorted = CropType.values.toList()
      ..sort((a, b) {
        final lvCmp = a.unlockLevel.compareTo(b.unlockLevel);
        return lvCmp != 0 ? lvCmp : a.index.compareTo(b.index);
      });
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.12,
      children: sorted.map((crop) {
        final owned    = gp.player?.inventory.seeds[crop] ?? 0;
        final canBuy   = (gp.player?.gold ?? 0) >= crop.seedCost;
        final unlocked = gp.isCropUnlocked(crop);
        return _SeedCard(
          crop: crop, owned: owned,
          canBuy: canBuy, unlocked: unlocked,
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
  final Function(int) onBuy;

  const _SeedCard({
    required this.crop, required this.owned,
    required this.canBuy, required this.unlocked,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !unlocked;
    final cardColors = [
      const Color(0xFFF1F8E9), const Color(0xFFFCE4EC), const Color(0xFFFCE4EC),
      const Color(0xFFFFF3E0), const Color(0xFFF3E5F5), const Color(0xFFFFF8E1),
      const Color(0xFFE8F5E9), const Color(0xFFFFF3E0), const Color(0xFFFFF9C4),
      const Color(0xFFE8F5E9), const Color(0xFFFFF0E6), const Color(0xFFF3E5F5),
      const Color(0xFFFFEBEE), const Color(0xFFE8F5E9),
    ];
    final cardColor = locked
        ? Colors.grey.shade100
        : (crop.index < cardColors.length ? cardColors[crop.index] : const Color(0xFFF1F8E9));

    return Opacity(
      opacity: locked ? 0.58 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: locked ? Colors.grey.shade200 : Colors.white.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: [BoxShadow(
            color: locked
                ? Colors.grey.withOpacity(0.08)
                : Colors.brown.withOpacity(0.08),
            blurRadius: 8, offset: const Offset(0, 3),
          )],
        ),
        child: Stack(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(crop.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 2),
            Text(crop.label,
                style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 12, color: Color(0xFF4E342E))),
            Text(
              owned > 0 ? '🌿 Có: $owned hạt' : 'Chưa có hạt',
              style: TextStyle(fontSize: 9,
                  color: owned > 0 ? const Color(0xFF2E7D32) : Colors.grey),
            ),
            const SizedBox(height: 5),
            if (!locked) Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _BuyBtn(label: '×5', subLabel: '${crop.seedCost * 5}🪙',
                enabled: canBuy,
                colors: [const Color(0xFF66BB6A), const Color(0xFF43A047)],
                onTap: () => onBuy(5)),
              _BuyBtn(label: '×1', subLabel: '${crop.seedCost}🪙',
                enabled: canBuy,
                colors: [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
                onTap: () => onBuy(1)),
            ]),
          ]),

          
          if (crop.tag == '🆕')
            Positioned(top: 0, left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFE64A19)]),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text('MỚI', style: TextStyle(color: Colors.white,
                    fontSize: 7, fontWeight: FontWeight.bold)),
              ),
            ),

          
          if (crop.tag == '💎')
            Positioned(top: 0, left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)]),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text('HIẾM', style: TextStyle(color: Colors.white,
                    fontSize: 7, fontWeight: FontWeight.bold)),
              ),
            ),

          
          if (locked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🔒', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.62),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Lv ${crop.unlockLevel}',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class _BuyBtn extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool enabled;
  final List<Color> colors;
  final VoidCallback onTap;

  const _BuyBtn({
    required this.label, required this.subLabel,
    required this.enabled, required this.colors, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: enabled ? LinearGradient(colors: colors) : null,
        color: enabled ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        boxShadow: enabled ? [BoxShadow(
          color: colors[1].withOpacity(0.35),
          blurRadius: 4, offset: const Offset(0, 2),
        )] : null,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(
          color: enabled ? Colors.white : Colors.grey,
          fontSize: 10, fontWeight: FontWeight.bold,
        )),
        Text(subLabel, style: TextStyle(
          color: enabled ? Colors.white70 : Colors.grey.shade400,
          fontSize: 8,
        )),
      ]),
    ),
  );
}


class _AnimalsTab extends StatelessWidget {
  final GameProvider gp;
  const _AnimalsTab({required this.gp});

  @override
  Widget build(BuildContext context) {
    
    final sortedAnimals = AnimalType.values.toList()
      ..sort((a, b) {
        final lvCmp = a.unlockLevel.compareTo(b.unlockLevel);
        return lvCmp != 0 ? lvCmp : a.index.compareTo(b.index);
      });

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: sortedAnimals.map((type) {
        final count    = gp.animals.where((a) => a.type == type).length;
        final max      = type.maxCount;
        final unlocked = gp.isAnimalUnlocked(type);
        final canBuy   = unlocked &&
            (gp.player?.gold ?? 0) >= type.buyCost && count < max;
        final cardColor = _animalCardColor(type);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: unlocked
                ? cardColor.withOpacity(0.06)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unlocked
                  ? cardColor.withOpacity(0.28)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [BoxShadow(
              color: unlocked
                  ? cardColor.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3),
            )],
          ),
          child: Opacity(
            opacity: unlocked ? 1.0 : 0.62,
            child: Padding(
              padding: const EdgeInsets.all(12),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardColor.withOpacity(0.35)),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(type.babyEmoji, style: const TextStyle(fontSize: 16)),
                              const Text('↓', style: TextStyle(fontSize: 7, color: Colors.grey)),
                              Text(type.emoji, style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: Text(type.label,
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 15, color: cardColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (type.isNew) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFFFF7043), Color(0xFFE64A19)]),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text('MỚI', style: TextStyle(color: Colors.white,
                                  fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ]),
                        if (!unlocked)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('🔒 Cần Lv${type.unlockLevel}',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    )),

                    
                    const SizedBox(width: 8),
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
                      child: Container(
                        width: 58,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: canBuy ? LinearGradient(colors: [
                            cardColor,
                            Color.lerp(cardColor, Colors.black, 0.18)!,
                          ]) : null,
                          color: canBuy ? null : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: canBuy ? [BoxShadow(
                            color: cardColor.withOpacity(0.38),
                            blurRadius: 8, offset: const Offset(0, 3),
                          )] : null,
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Mua', style: TextStyle(
                            color: canBuy ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold, fontSize: 12,
                          )),
                          Text('${type.buyCost}🪙', style: TextStyle(
                            color: canBuy ? Colors.white70 : Colors.grey,
                            fontSize: 9,
                          )),
                        ]),
                      ),
                    ),
                  ]),

                  
                  const SizedBox(height: 8),
                  
                  Wrap(spacing: 10, runSpacing: 4, children: [
                    _infoBadge(
                      '🎁 ${type.produce}',
                      const Color(0xFFF3E5F5),
                      const Color(0xFF7B1FA2),
                    ),
                    _infoBadge(
                      '📅 ${type.daysToAdult}ngày',
                      const Color(0xFFE3F2FD),
                      const Color(0xFF1565C0),
                    ),
                    _infoBadge(
                      '🌿 ${type.feedCost}🪙/ngày',
                      const Color(0xFFE8F5E9),
                      const Color(0xFF2E7D32),
                    ),
                  ]),

                  
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : (count / max).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          count >= max ? Colors.red : cardColor),
                        minHeight: 7,
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text('$count/$max',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold,
                          color: count >= max ? Colors.red : cardColor,
                        )),
                  ]),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoBadge(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500)),
  );

  Color _animalCardColor(AnimalType type) {
    const colors = [
      Color(0xFFFF8F00), 
      Color(0xFF0277BD), 
      Color(0xFF388E3C), 
      Color(0xFFAD1457), 
      Color(0xFF6A1B9A), 
      Color(0xFFE65100), 
      Color(0xFFF9A825), 
      Color(0xFF4527A0), 
      Color(0xFF00695C), 
      Color(0xFFBF360C), 
    ];
    return type.index < colors.length ? colors[type.index] : const Color(0xFF455A64);
  }
}
