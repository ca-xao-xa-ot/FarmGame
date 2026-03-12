





import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class AnimalPanelWidget extends StatelessWidget {
  final GameProvider gp;
  final VoidCallback onClose;
  const AnimalPanelWidget({super.key, required this.gp, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Header(gp: gp, onClose: onClose),
          const SizedBox(height: 5),

          
          _FishCard(gp: gp),
          const SizedBox(height: 5),

          
          ...gp.animals.map((a) => _AnimalCard(
            animal   : a,
            onFeed   : () => gp.feedAnimal(a.id),
            onCollect: () => gp.collectProduce(a.id),
          )),
        ],
      ),
    );
  }
}


class _Header extends StatelessWidget {
  final GameProvider gp;
  final VoidCallback onClose;
  const _Header({required this.gp, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.60),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🐾', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        const Text('Vật nuôi',
            style: TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),

        
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => gp.feedAllAnimals(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF795548).withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('🌽', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text('Cho ăn',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),

        const SizedBox(width: 8),
        
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text('✖',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }
}


class _FishCard extends StatelessWidget {
  final GameProvider gp;
  const _FishCard({required this.gp});

  @override
  Widget build(BuildContext context) {
    final fish = gp.player?.inventory.fishCount ?? 0;
    final gold = fish * GameConstants.fishGoldValue;
    final hasFish = fish > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hasFish
            ? const Color(0xFFE3F2FD)   
            : Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFish ? const Color(0xFF1565C0) : Colors.grey.shade200,
          width: hasFish ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: hasFish
                  ? const Color(0xFF1565C0).withOpacity(0.18)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        
        Stack(clipBehavior: Clip.none, children: [
          Text('🐟', style: TextStyle(fontSize: hasFish ? 26 : 22)),
          if (hasFish)
            Positioned(
              top: -5, right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$fish',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
        const SizedBox(width: 10),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              hasFish ? 'Cá: $fish con' : 'Chưa có cá',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: hasFish ? const Color(0xFF1565C0) : Colors.grey),
            ),
            if (hasFish)
              Text('+$gold🪙',
                  style: const TextStyle(
                      fontSize: 9,
                      color: Colors.green,
                      fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(width: 8),
        
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: hasFish ? () => gp.sellFish() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: hasFish ? const Color(0xFF1565C0) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
              boxShadow: hasFish
                  ? [BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.35),
                      blurRadius: 4, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Text(
              'Bán 🪙',
              style: TextStyle(
                color: hasFish ? Colors.white : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}


class _AnimalCard extends StatelessWidget {
  final AnimalModel  animal;
  final VoidCallback onFeed;
  final VoidCallback onCollect;

  const _AnimalCard({
    required this.animal,
    required this.onFeed,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final isAdult = animal.state == AnimalState.adult;
    final canProd = animal.canProduce();
    final emoji   = isAdult ? animal.type.emoji : animal.type.babyEmoji;

    
    String produceIcon;
    switch (animal.type) {
      case AnimalType.cow:    produceIcon = '🥛'; break;
      case AnimalType.pig:    produceIcon = '🥩'; break;
      case AnimalType.sheep:  produceIcon = '🧶'; break;
      case AnimalType.rabbit: produceIcon = '🪶'; break;
      case AnimalType.bee:    produceIcon = '🍯'; break;
      default:                produceIcon = '🥚'; 
    }

    return Container(
      margin : const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: canProd ? const Color(0xFF4CAF50) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 5, offset: const Offset(0, 2),
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(clipBehavior: Clip.none, children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          if (!isAdult)
            const Positioned(bottom: -4, right: -4,
                child: Text('🐣', style: TextStyle(fontSize: 10))),
          if (canProd)
            Positioned(top: -4, right: -4,
                child: Text(produceIcon,
                    style: const TextStyle(fontSize: 14))),
        ]),
        const SizedBox(height: 2),
        
        Text(
          isAdult ? (animal.isFed ? '✅ No' : '🌽 Đói') : '🌱 Nhỏ',
          style: TextStyle(
            fontSize: 8,
            color: isAdult
                ? (animal.isFed ? const Color(0xFF2E7D32) : Colors.orange)
                : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        
        _SmallBtn(
          label   : '🌽',
          sublabel: '-${animal.type.feedCost}🪙',
          color   : const Color(0xFF795548),
          enabled : isAdult && !animal.isFed,
          onTap   : onFeed,
        ),
        const SizedBox(height: 3),
        
        _SmallBtn(
          label   : produceIcon,
          sublabel: '+${animal.type.produceVal}🪙',
          color   : const Color(0xFF4CAF50),
          enabled : canProd,
          onTap   : onCollect,
        ),
      ]),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String label, sublabel;
  final Color  color;
  final bool   enabled;
  final VoidCallback onTap;

  const _SmallBtn({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: enabled ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(sublabel,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.grey,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              )),
        ]),
      ),
    );
  }
}
