// ================================================================
//  CONSTANTS  v6  (Firebase kept)
//  ✅ Adds Level/XP support (max level 100)
//  ✅ Adds new animals: Duck, Pig
//  ✅ Adds unlock levels for seeds & animals
// ================================================================
import 'dart:math';

class GameConstants {
  // ── Grid ─────────────────────────────────────────────────────
  static const int    farmCols = 20;
  static const int    farmRows = 15;
  static const double tileSize = 52.0;

  // ── Level system ─────────────────────────────────────────────
  static const int maxLevel = 100;

  // ── Player physics ───────────────────────────────────────────
  static const double playerRadius   = 0.30;
  static const double playerMaxSpd   = 6.5;
  static const double playerAccel    = 38.0;
  static const double playerFrict    = 32.0;
  static const double diagMultiplier = 0.7071;

  // ── Starting resources ───────────────────────────────────────
  static const int startGold = 500;

  // ── Fishing ──────────────────────────────────────────────────
  static const int fishingSeconds = 5;
  static const int fishGoldValue  = 30;

  // ── Animal pen (top-right) ───────────────────────────────────
  static const int penX = 14;
  static const int penY = 0;
  static const int penW = 6;
  static const int penH = 8;

  // ── House ────────────────────────────────────────────────────
  static const int houseCol = 16;
  static const int houseRow = 9;

  // ── Pond (bottom-left) ───────────────────────────────────────
  static const int pondX = 0;
  static const int pondY = 11;
  static const int pondW = 4;
  static const int pondH = 3;

  // ── Animal movement / roaming ────────────────────────────────
  static const int    animalTickMs      = 50;
  static const double animalMaxSpd      = 1.2;
  static const double animalAccel       = 8.0;
  static const double animalFrict       = 10.0;
  static const double animalIdleChance  = 0.018;

  // ── Collision rectangles [left, top, right, bottom] tiles ────
  static const List<List<double>> solidRects = [
    // Pond
    [pondX + 0.0, pondY + 0.0, pondX + pondW + 0.0, pondY + pondH + 0.0],
    // House body (col 15..18, row 7..10)
    [15.0, 7.0, 18.5, 10.5],
  ];

  static final Random rng = Random();
}

// ═══════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════
enum CropType    { rice, tomato, strawberry, carrot, eggplant }
enum TileState   { grass, ground, planted, watered, growing, ready }
enum ToolType    { hand, hoe, wateringCan, fishingRod }
enum AnimalType  { chicken, duck, cow, pig }
enum AnimalState { baby, adult }
enum GameScene   { farm, house }

// ═══════════════════════════════════════════════════
// EXTENSIONS  –  CropType
// ═══════════════════════════════════════════════════
extension CropTypeExt on CropType {
  String get label     => const ['Lúa','Cà Chua','Dâu Tây','Cà Rốt','Cà Tím'][index];
  String get emoji     => const ['🌾','🍅','🍓','🥕','🍆'][index];
  int    get seedCost  => const [20, 40, 60, 30, 50][index];
  int    get goldValue => const [60, 100, 150, 80, 120][index];

  /// Unlock levels requested
  int get unlockLevel  => const [1, 7, 13, 19, 25][index];

  /// Days after planting to become 'ready' (via sleep cycle)
  int get growDays => 2;
}

// ═══════════════════════════════════════════════════
// EXTENSIONS  –  ToolType
// ═══════════════════════════════════════════════════
extension ToolTypeExt on ToolType {
  String get label  => const ['Tay', 'Cuốc', 'Tưới', 'Câu Cá'][index];
  String get emoji  => const ['🖐️', '⛏️', '💧', '🎣'][index];
  String get hotkey => const ['1', '2', '3', '4'][index];
}

// ═══════════════════════════════════════════════════
// EXTENSIONS  –  AnimalType
// ═══════════════════════════════════════════════════
extension AnimalTypeExt on AnimalType {
  String get label     => const ['Gà', 'Vịt', 'Bò', 'Lợn'][index];
  String get emoji     => const ['🐔', '🦆', '🐄', '🐷'][index];
  String get babyEmoji => const ['🐤', '🐣', '🐮', '🐽'][index];

  /// Produce name
  String get produce   => const ['Trứng 🥚', 'Trứng vịt 🥚', 'Sữa 🥛', 'Thịt heo 🥩'][index];

  int    get buyCost   => const [80, 120, 200, 260][index];
  int    get feedCost  => const [10, 12, 20, 25][index];
  int    get daysToAdult => const [3, 4, 5, 6][index];

  /// Gold gained when collecting produce
  int    get produceVal => const [25, 30, 50, 90][index];

  /// Movement speed multiplier in pen
  double get speedMult  => const [1.2, 1.0, 0.7, 0.65][index];

  /// Unlock levels requested
  int get unlockLevel   => const [2, 5, 10, 15][index];

  /// Max count requested
  int get maxCount      => const [5, 5, 3, 3][index];
}
