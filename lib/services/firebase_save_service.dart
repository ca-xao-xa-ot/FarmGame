





import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class FirebaseSaveService {
  static final FirebaseSaveService _instance = FirebaseSaveService._internal();
  factory FirebaseSaveService() => _instance;
  FirebaseSaveService._internal();

  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  
  Future<bool> hasSavedGame() async {
    if (uid == null) return false;
    try {
      final doc = await _db.collection('game_saves').doc(uid).get();
      return doc.exists && doc.data() != null;
    } catch (_) { return false; }
  }

  
  Future<void> saveGame({
    required PlayerModel player,
    required List<List<TileModel>> tiles,
    required List<AnimalModel> animals,
  }) async {
    if (uid == null) return;
    try {
      
      final flatTiles = <Map<String, dynamic>>[];
      for (int r = 0; r < tiles.length; r++) {
        for (int c = 0; c < tiles[r].length; c++) {
          final t = tiles[r][c];
          
          if (t.state != TileState.grass) {
            flatTiles.add({'r': r, 'c': c, ...t.toMap()});
          }
        }
      }

      await _db.collection('game_saves').doc(uid).set({
        'uid'        : uid,
        'displayName': _auth.currentUser?.displayName ?? player.name,
        'email'      : _auth.currentUser?.email ?? '',
        'player'     : player.toMap(),
        'tiles'      : jsonEncode(flatTiles),
        'animals'    : jsonEncode(animals.map((a) => a.toMap()).toList()),
        'savedAt'    : FieldValue.serverTimestamp(),
        'version'    : 9,
      }, SetOptions(merge: false)); 
    } catch (e) {
      print('⚠️  Firebase save error: $e');
    }
  }

  
  
  Future<_CloudSave?> loadGame() async {
    if (uid == null) return null;
    try {
      final doc = await _db.collection('game_saves').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;

      
      final playerMap = data['player'] as Map<String, dynamic>?;
      if (playerMap == null) return null;
      final player = PlayerModel.fromMap(playerMap);

      
      final grid = List.generate(
        GameConstants.farmRows,
        (_) => List.generate(GameConstants.farmCols, (_) => TileModel()),
      );
      final rawTiles = data['tiles'] as String? ?? '[]';
      final flatTiles = (jsonDecode(rawTiles) as List).cast<Map<String, dynamic>>();
      for (final item in flatTiles) {
        final r = item['r'] as int;
        final c = item['c'] as int;
        if (r < GameConstants.farmRows && c < GameConstants.farmCols) {
          grid[r][c] = TileModel.fromMap(item);
        }
      }

      
      final rawAnimals = data['animals'] as String? ?? '[]';
      final animals = (jsonDecode(rawAnimals) as List)
          .map((m) => AnimalModel.fromMap(m as Map<String, dynamic>))
          .toList();

      return _CloudSave(player: player, tiles: grid, animals: animals);
    } catch (e) {
      print('⚠️  Firebase load error: $e');
      return null;
    }
  }

  
  Future<void> updateLeaderboard(String name, int totalGold, int level) async {
    if (uid == null) return;
    try {
      await _db.collection('leaderboard').doc(uid).set({
        'uid'        : uid,
        'name'       : name,
        'totalGold'  : totalGold,
        'level'      : level,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snap = await _db
          .collection('leaderboard')
          .orderBy('totalGold', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((doc) {
        final d = doc.data();
        return {
          'uid'      : d['uid'] ?? '',
          'name'     : d['name'] ?? '?',
          'totalGold': (d['totalGold'] as num? ?? 0).toInt(),
          'level'    : (d['level'] as num? ?? 1).toInt(),
        };
      }).toList();
    } catch (_) { return []; }
  }

  
  Future<void> deleteSave() async {
    if (uid == null) return;
    await _db.collection('game_saves').doc(uid).delete();
  }
}

class _CloudSave {
  final PlayerModel            player;
  final List<List<TileModel>>  tiles;
  final List<AnimalModel>      animals;
  const _CloudSave({required this.player, required this.tiles, required this.animals});
}
