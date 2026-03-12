



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class LeaderboardDialog extends StatefulWidget {
  const LeaderboardDialog({super.key});
  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gp = context.read<GameProvider>();
    
    final list = await gp.getLeaderboard();
    if (mounted) setState(() { _entries = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], 
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(children: [
            Text('🌍', style: TextStyle(fontSize: 28)), 
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Top Nông Dân',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Bảng xếp hạng toàn máy chủ', 
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
          ]),
        ),
        const Divider(color: Colors.white24, height: 1),
        
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _entries.isEmpty
              ? _buildEmpty()
              : _buildList(),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🌐', style: TextStyle(fontSize: 52)),
      const SizedBox(height: 10),
      const Text('Chưa có dữ liệu máy chủ!',
          style: TextStyle(color: Colors.white70, fontSize: 16)),
      const SizedBox(height: 4),
      Text('Bạn hãy trở thành người đầu tiên kiếm 🪙 nhé!',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
    ]),
  );

  Widget _buildList() {
    final medals = ['🥇', '🥈', '🥉'];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: _entries.length,
      itemBuilder: (_, i) {
        final e    = _entries[i];
        final name = e['name'] as String? ?? '?';
        final gold = e['totalGold'] as int? ?? 0;
        final rank = medals.length > i ? medals[i] : '${i + 1}.';
        final isMe = context.read<GameProvider>().player?.uid == e['uid'];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withOpacity(0.28)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: isMe
                ? Border.all(color: const Color(0xFFFFD700), width: 2)
                : null,
          ),
          child: Row(children: [
            SizedBox(
              width: 34,
              child: Text(rank, style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name + (isMe ? ' (Bạn)' : ''),
                style: TextStyle(
                  color: isMe ? const Color(0xFFFFD700) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ])),
            Row(children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                _format(gold),
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}