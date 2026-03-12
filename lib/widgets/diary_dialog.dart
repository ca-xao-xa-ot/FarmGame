// ================================================================
//  DIARY DIALOG
//  Lets the player write / read a diary entry for each day
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class DiaryDialog extends StatefulWidget {
  const DiaryDialog({super.key});
  @override
  State<DiaryDialog> createState() => _DiaryDialogState();
}

class _DiaryDialogState extends State<DiaryDialog> {
  late TextEditingController _ctrl;
  late int _day;

  @override
  void initState() {
    super.initState();
    final gp = context.read<GameProvider>();
    _day  = gp.player?.currentDay ?? 1;
    final entry = gp.player?.getDiaryForDay(_day);
    _ctrl = TextEditingController(text: entry?.content ?? '');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _save() {
    final gp = context.read<GameProvider>();
    gp.saveDiaryEntry(_day, _ctrl.text.trim());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📖 Nhật ký đã lưu!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (_, gp, __) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.78,
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
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(children: [
              const Text('📖', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Nhật Ký Nông Trại',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: Color(0xFF4E342E))),
                Text('Ngày $_day',
                    style: const TextStyle(fontSize: 12, color: Colors.brown)),
              ]),
              const Spacer(),
              // Day picker
              _DayPicker(
                currentDay: _day,
                maxDay: gp.player?.currentDay ?? 1,
                onChanged: (d) {
                  final entry = gp.player?.getDiaryForDay(d);
                  setState(() {
                    _day = d;
                    _ctrl.text = entry?.content ?? '';
                  });
                },
              ),
            ]),
          ),
          const Divider(color: Color(0xFFD7CCC8)),
          // Text area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 14, color: Color(0xFF3E2723), height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: _day == (gp.player?.currentDay ?? 1)
                      ? 'Ghi lại những gì xảy ra hôm nay... 🌾'
                      : 'Ngày này không có ghi chú.',
                  hintStyle: const TextStyle(color: Colors.brown, fontSize: 13),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: const Color(0xFFFFF8E1),
                ),
                // Read-only for past days? Let them edit any day
              ),
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(children: [
              // Stats snapshot
              Expanded(child: _StatsSnapshot(gp: gp)),
              const SizedBox(width: 10),
              // Save button
              ElevatedButton.icon(
                icon: const Text('💾', style: TextStyle(fontSize: 16)),
                label: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ]),
          ),
        ]),
      );
    });
  }
}

// ── Day picker arrows ────────────────────────────────────────────
class _DayPicker extends StatelessWidget {
  final int currentDay, maxDay;
  final ValueChanged<int> onChanged;
  const _DayPicker({required this.currentDay, required this.maxDay, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: const Icon(Icons.chevron_left, size: 20),
        color: currentDay > 1 ? const Color(0xFF4E342E) : Colors.grey,
        onPressed: currentDay > 1 ? () => onChanged(currentDay - 1) : null,
        padding: EdgeInsets.zero,
      ),
      Text('Ngày $currentDay',
          style: const TextStyle(fontSize: 12, color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
      IconButton(
        icon: const Icon(Icons.chevron_right, size: 20),
        color: currentDay < maxDay ? const Color(0xFF4E342E) : Colors.grey,
        onPressed: currentDay < maxDay ? () => onChanged(currentDay + 1) : null,
        padding: EdgeInsets.zero,
      ),
    ]);
  }
}

// ── Stats snapshot row ───────────────────────────────────────────
class _StatsSnapshot extends StatelessWidget {
  final GameProvider gp;
  const _StatsSnapshot({required this.gp});

  @override
  Widget build(BuildContext context) {
    final p = gp.player;
    if (p == null) return const SizedBox();
    return Wrap(spacing: 8, runSpacing: 4, children: [
      _badge('🪙', '${p.gold}'),
      _badge('🐟', '${p.inventory.fishCount}'),
      _badge('🥚', '${p.inventory.eggCount}'),
      _badge('🥛', '${p.inventory.milkCount}'),
    ]);
  }

  Widget _badge(String icon, String val) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFD7CCC8),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 3),
      Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
    ]),
  );
}
