



import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class AchievementDialog extends StatelessWidget {
  final GameProvider gp;
  const AchievementDialog({super.key, required this.gp});

  @override
  Widget build(BuildContext context) {
    final unlocked = gp.player?.unlockedAchievements ?? [];
    final total    = Achievements.all.length;
    final doneCount = unlocked.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(children: [
        
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Row(children: [
            const Text('🏅', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Thành Tích',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('$doneCount/$total',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ]),
        ),

        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? doneCount / total : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFD7CCC8),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            itemCount: Achievements.all.length,
            itemBuilder: (_, i) {
              final def  = Achievements.all[i];
              final done = unlocked.contains(def.id);
              return _AchItem(def: def, unlocked: done);
            },
          ),
        ),

        
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D6E63),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Đóng',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AchItem extends StatelessWidget {
  final AchievementDef def;
  final bool           unlocked;
  const _AchItem({required this.def, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? const Color(0xFF4CAF50)
              : const Color(0xFFD7CCC8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.brown.withOpacity(0.07),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: unlocked
                ? const Color(0xFF4CAF50).withOpacity(0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              unlocked ? def.icon : '🔒',
              style: TextStyle(fontSize: unlocked ? 26 : 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                def.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: unlocked
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF4E342E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                def.description,
                style: TextStyle(
                    fontSize: 10,
                    color: unlocked ? Colors.green : Colors.grey),
              ),
            ],
          ),
        ),
        
        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${def.expReward} EXP',
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.grey,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (unlocked) ...[
            const SizedBox(height: 4),
            const Text('✅',
                style: TextStyle(fontSize: 14)),
          ]
        ]),
      ]),
    );
  }
}
