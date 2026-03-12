




import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import 'firebase_save_service.dart';

class LocalStorageService {
  static const _kPlayer  = 'player_data_v9';
  static const _kTiles   = 'tiles_data_v9';
  static const _kAnimals = 'animals_data_v9';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  
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

  
  Future<void> saveTiles(List<List<TileModel>> tiles) async {
    final prefs = await _prefs;
    final flat = <Map<String, dynamic>>[];
    for (int r = 0; r < tiles.length; r++) {
      for (int c = 0; c < tiles[r].length; c++) {
        if (tiles[r][c].state != TileState.grass) {
          flat.add({'r': r, 'c': c, ...tiles[r][c].toMap()});
        }
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

  
  Future<void> updateLeaderboard(String uid, String name, int gold) async {
    await FirebaseSaveService().updateLeaderboard(name, gold, 1);
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return FirebaseSaveService().getLeaderboard();
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_kPlayer);
    await prefs.remove(_kTiles);
    await prefs.remove(_kAnimals);
  }
}
