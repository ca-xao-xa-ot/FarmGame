// ================================================================
//  STORAGE SERVICE  –  SharedPreferences (Local) + Firestore (Online)
// ================================================================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static const _kPlayer      = 'player_data';
  static const _kTiles       = 'tiles_data';
  static const _kAnimals     = 'animals_data';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ✅ ĐÃ SỬA: Dùng .instance thay vì .getInstance()
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Player ───────────────────────────────────────────────────
  Future<void> savePlayer(PlayerModel p) async {
    final prefs = await _prefs;
    await prefs.setString(_kPlayer, jsonEncode(p.toMap()));
  }

  Future<PlayerModel?> loadPlayer() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kPlayer);
      if (raw == null) return null;
      return PlayerModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) { return null; }
  }

  // ── Tiles ────────────────────────────────────────────────────
  Future<void> saveTiles(List<List<TileModel>> tiles) async {
    final prefs = await _prefs;
    final flat = <Map<String, dynamic>>[];
    for (int r = 0; r < tiles.length; r++) {
      for (int c = 0; c < tiles[r].length; c++) {
        flat.add({'r': r, 'c': c, ...tiles[r][c].toMap()});
      }
    }
    await prefs.setString(_kTiles, jsonEncode(flat));
  }

  Future<List<List<TileModel>>?> loadTiles() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kTiles);
      if (raw == null) return null;
      final flat = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final grid = List.generate(
        GameConstants.farmRows,
            (_) => List.generate(GameConstants.farmCols, (_) => TileModel()),
      );
      for (final item in flat) {
        final r = item['r'] as int;
        final c = item['c'] as int;
        if (r < GameConstants.farmRows && c < GameConstants.farmCols) {
          grid[r][c] = TileModel.fromMap(item);
        }
      }
      return grid;
    } catch (_) { return null; }
  }

  // ── Animals ──────────────────────────────────────────────────
  Future<void> saveAnimals(List<AnimalModel> animals) async {
    final prefs = await _prefs;
    await prefs.setString(_kAnimals,
        jsonEncode(animals.map((a) => a.toMap()).toList()));
  }

  Future<List<AnimalModel>> loadAnimals() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kAnimals);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((m) => AnimalModel.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (_) { return []; }
  }

  // ── Leaderboard (ONLINE FIRESTORE) ───────────────────────────
  Future<void> updateLeaderboard(String uid, String name, int gold) async {
    try {
      // Lưu điểm lên Cloud Firestore vào collection 'leaderboard'
      await _firestore.collection('leaderboard').doc(uid).set({
        'uid': uid,
        'name': name,
        'totalGold': gold,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Lỗi cập nhật bảng xếp hạng: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      // Lấy top 20 từ Firestore
      final QuerySnapshot snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('totalGold', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': data['uid'],
          'name': data['name'],
          'totalGold': (data['totalGold'] as num).toInt(),
        };
      }).toList();
    } catch (e) {
      print('Lỗi lấy bảng xếp hạng: $e');
      return [];
    }
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_kPlayer);
    await prefs.remove(_kTiles);
    await prefs.remove(_kAnimals);
  }
}