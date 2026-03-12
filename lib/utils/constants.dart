






import 'dart:math';

class GameConstants {
  
  static const int    farmCols = 20;
  static const int    farmRows = 15;
  static const double tileSize = 52.0;

  
  static const int maxLevel = 100;

  
  static const double playerRadius   = 0.30;
  static const double playerMaxSpd   = 6.5;
  static const double playerAccel    = 38.0;
  static const double playerFrict    = 32.0;
  static const double diagMultiplier = 0.7071;

  
  static const int startGold = 500;

  
  static const int fishingSeconds = 5;
  static const int fishGoldValue  = 30;

  
  static const int penX = 14;
  static const int penY = 0;
  static const int penW = 6;
  static const int penH = 8;

  
  static const int houseCol = 16;
  static const int houseRow = 9;

  
  static const int pondX = 0;
  static const int pondY = 11;
  static const int pondW = 4;
  static const int pondH = 3;

  
  static const int    animalTickMs      = 50;
  static const double animalMaxSpd      = 1.2;
  static const double animalAccel       = 8.0;
  static const double animalFrict       = 10.0;
  static const double animalIdleChance  = 0.018;

  
  static const int hoeDurationMs = 320;

  
  static const List<List<double>> solidRects = [
    
    [pondX + 0.0, pondY + 0.0, pondX + pondW + 0.0, pondY + pondH + 0.0],
    
    [15.0, 7.0, 18.5, 10.5],
  ];

  static final Random rng = Random();
}




enum CropType {
  rice, tomato, strawberry, carrot, eggplant,
  corn, watermelon, pumpkin, sunflower,
  blueberry, peach, lavender, pepper, cabbage
}
enum TileState   { grass, ground, planted, watered, growing, ready }
enum ToolType    { hand, hoe, wateringCan, fishingRod }
enum AnimalType  { chicken, duck, cow, pig, sheep, rabbit, bee, horse, peacock, turkey }
enum AnimalState { baby, adult }
enum GameScene   { farm, house }




extension CropTypeExt on CropType {
  String get label => const [
    'Lúa', 'Cà Chua', 'Dâu Tây', 'Cà Rốt', 'Cà Tím',
    'Ngô', 'Dưa Hấu', 'Bí Ngô', 'Hướng Dương',
    'Việt Quất', 'Đào', 'Oải Hương', 'Ớt', 'Bắp Cải',
  ][index];

  String get emoji => const [
    '🌾', '🍅', '🍓', '🥕', '🍆',
    '🌽', '🍉', '🎃', '🌻',
    '🫐', '🍑', '💜', '🌶️', '🥬',
  ][index];

  int get seedCost => const [
    20, 40, 60, 30, 50,
    35, 80, 55, 45,
    70, 65, 50, 45, 25,
  ][index];

  int get goldValue => const [
    60, 100, 150, 80, 120,
    90, 200, 140, 110,
    180, 160, 130, 115, 70,
  ][index];

  
  int get unlockLevel => const [
    1, 7, 13, 19, 25,
    4, 18, 22, 10,
    16, 20, 14, 11, 3,
  ][index];

  
  int get growDays => 2;
  
  
  String get tag => const [
    '', '', '💎', '', '',
    '', '💎', '', '',
    '🆕', '🆕', '🆕', '🆕', '🆕',
  ][index];
}




extension ToolTypeExt on ToolType {
  String get label  => const ['Tay', 'Cuốc', 'Tưới', 'Câu Cá'][index];
  String get emoji  => const ['🖐️', '⛏️', '💧', '🎣'][index];
  String get hotkey => const ['1', '2', '3', '4'][index];
}




extension AnimalTypeExt on AnimalType {
  String get label => const [
    'Gà', 'Vịt', 'Bò', 'Lợn', 'Cừu', 'Thỏ', 'Ong',
    'Ngựa', 'Công', 'Gà Tây',
  ][index];

  String get emoji => const [
    '🐔', '🦆', '🐄', '🐷', '🐑', '🐰', '🐝',
    '🐴', '🦚', '🦃',
  ][index];

  String get babyEmoji => const [
    '🐤', '🐣', '🐮', '🐽', '🐏', '🐇', '🍯',
    '🐎', '🦜', '🐔',
  ][index];

  
  String get produce => const [
    'Trứng 🥚', 'Trứng vịt 🥚', 'Sữa 🥛', 'Thịt heo 🥩',
    'Len 🧶', 'Lông thỏ 🪶', 'Mật ong 🍯',
    'Sữa ngựa 🥛', 'Lông đuôi 🪶', 'Trứng lớn 🥚',
  ][index];

  int get buyCost => const [
    80, 120, 200, 260, 180, 150, 300,
    450, 380, 200,
  ][index];

  int get feedCost => const [
    10, 12, 20, 25, 15, 8, 5,
    35, 30, 18,
  ][index];

  int get daysToAdult => const [
    3, 4, 5, 6, 4, 3, 7,
    8, 6, 5,
  ][index];

  
  int get produceVal => const [
    25, 30, 50, 90, 60, 40, 120,
    150, 130, 55,
  ][index];

  
  double get speedMult => const [
    1.2, 1.0, 0.7, 0.65, 0.8, 1.4, 0.3,
    1.5, 0.9, 1.1,
  ][index];

  
  int get unlockLevel => const [
    2, 5, 10, 15, 8, 6, 20,
    25, 22, 12,
  ][index];

  
  int get maxCount => const [
    5, 5, 3, 3, 4, 6, 2,
    2, 2, 4,
  ][index];

  
  bool get isNew => index >= 7;
}
