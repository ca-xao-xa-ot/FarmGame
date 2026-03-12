import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class ToolbarWidget extends StatelessWidget {
  final GameProvider gp;
  const ToolbarWidget({super.key, required this.gp});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF3E2723), Color(0xFF4E342E)],
        ),
        border: Border(top: BorderSide(
            color: const Color(0xFF8D6E63).withOpacity(0.6), width: 1.5)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10, offset: const Offset(0, -4),
        )],
      ),
      child: Row(children: [
        
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: ToolType.values.map((tool) {
                final sel = gp.selectedTool == tool;
                return GestureDetector(
                  onTap: () => gp.setTool(tool),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 66, height: 70,
                    decoration: BoxDecoration(
                      gradient: sel
                          ? const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)])
                          : LinearGradient(
                              colors: [const Color(0xFF5D4037), const Color(0xFF4E342E)]),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFFFD54F)
                            : Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFD54F).withOpacity(0.5),
                                blurRadius: 10, spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(tool.emoji, style: TextStyle(fontSize: sel ? 26 : 22)),
                      const SizedBox(height: 2),
                      Text('[${tool.hotkey}]',
                        style: TextStyle(
                          color: sel ? const Color(0xFF3E2723) : Colors.white38,
                          fontSize: 8, fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(tool.label,
                        style: TextStyle(
                          color: sel ? Colors.black87 : Colors.white60,
                          fontSize: 8, fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        
        if (gp.selectedTool == ToolType.hand)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _SeedBag(gp: gp),
          ),
      ]),
    );
  }
}

class _SeedBag extends StatelessWidget {
  final GameProvider gp;
  const _SeedBag({required this.gp});

  @override
  Widget build(BuildContext context) {
    final p = gp.player;
    if (p == null) return const SizedBox();

    final owned = CropType.values
        .map((c) => MapEntry(c, p.inventory.seeds[c] ?? 0))
        .where((e) => e.value > 0)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () => _openSeedBag(context),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎒', style: TextStyle(fontSize: 18)),
              SizedBox(height: 1),
              Text('Hạt', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 8),

        
        if (owned.isEmpty)
          const Text('Chưa có hạt',
              style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))
        else
          SizedBox(
            width: 150,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: owned.map((e) {
                  final crop = e.key;
                  final cnt  = e.value;
                  final sel  = gp.selectedSeedType == crop;
                  return GestureDetector(
                    onTap: () => gp.selectSeed(crop),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFFFD54F) : Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? const Color(0xFFFFA000) : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(crop.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 3),
                        Text('$cnt',
                          style: TextStyle(
                            color: sel ? Colors.black87 : Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ]),
    );
  }

  void _openSeedBag(BuildContext context) {
    final p = gp.player;
    if (p == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                Text('🎒', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text('Túi hạt giống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
              ]),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: CropType.values.map((crop) {
                  final cnt = p.inventory.seeds[crop] ?? 0;
                  final locked = !gp.isCropUnlocked(crop);
                  final sel = gp.selectedSeedType == crop;
                  return GestureDetector(
                    onTap: (cnt > 0 && !locked) ? () {
                      gp.selectSeed(crop);
                      Navigator.pop(context);
                    } : null,
                    child: Opacity(
                      opacity: locked ? 0.45 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFFFFD54F) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD7CCC8)),
                        ),
                        child: Stack(children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 2),
                                Text('$cnt', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cnt > 0 ? const Color(0xFF2E7D32) : Colors.grey,
                                )),
                              ],
                            ),
                          ),
                          if (locked)
                            Positioned(
                              top: 6, right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('🔒 Lv${crop.unlockLevel}',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        );
      },
    );
  }
}
