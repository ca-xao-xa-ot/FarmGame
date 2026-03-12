// ================================================================
//  QUEST PANEL WIDGET  v8
//  Hiển thị 3 nhiệm vụ hàng ngày, tiến độ và nhận thưởng
// ================================================================
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class QuestPanelWidget extends StatelessWidget {
  final GameProvider gp;
  final VoidCallback onClose;

  const QuestPanelWidget({super.key, required this.gp, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final quests = gp.dailyQuests;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
            child: Row(children: [
              const Text('📋', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Nhiệm Vụ Hôm Nay',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('✖',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]),
          ),

          const Divider(color: Colors.white24, height: 1),

          if (quests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Không có nhiệm vụ hôm nay',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            )
          else
            ...quests.map((q) => _QuestItem(quest: q)),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QuestItem extends StatelessWidget {
  final DailyQuest quest;
  const _QuestItem({required this.quest});

  @override
  Widget build(BuildContext context) {
    final progress = quest.progress;
    final done = quest.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF1B5E20).withOpacity(0.55)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? const Color(0xFF4CAF50) : Colors.white12,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(children: [
            Text(quest.type.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${quest.type.verb} ${quest.targetCount} ${quest.type.unit}',
                style: TextStyle(
                  color: done ? const Color(0xFF81C784) : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (done)
              const Text('✅', style: TextStyle(fontSize: 12))
          ]),
          const SizedBox(height: 5),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                done ? const Color(0xFF4CAF50) : const Color(0xFFFFD54F),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Counter + rewards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quest.currentCount}/${quest.targetCount}',
                style: TextStyle(
                    color: done ? const Color(0xFF81C784) : Colors.white60,
                    fontSize: 9),
              ),
              Row(children: [
                Text('+${quest.expReward} EXP',
                    style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
                if (quest.goldReward > 0) ...[
                  const SizedBox(width: 4),
                  Text('+${quest.goldReward}🪙',
                      style: const TextStyle(
                          color: Color(0xFF81C784),
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ],
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
