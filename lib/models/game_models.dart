



import 'dart:math';
import '../utils/constants.dart';




class TileModel {
  TileState state;
  CropType? cropType;
  int       dayPlanted;
  bool      isWatered;

  TileModel({
    this.state      = TileState.grass,
    this.cropType,
    this.dayPlanted = 0,
    this.isWatered  = false,
  });

  bool get isReadyToHarvest => state == TileState.ready;

  Map<String, dynamic> toMap() => {
    'state'     : state.index,
    'cropType'  : cropType?.index,
    'dayPlanted': dayPlanted,
    'isWatered' : isWatered,
  };

  factory TileModel.fromMap(Map<String, dynamic> m) => TileModel(
    state      : TileState.values[m['state']      ?? 0],
    cropType   : m['cropType'] != null ? CropType.values[m['cropType']] : null,
    dayPlanted : m['dayPlanted'] ?? 0,
    isWatered  : m['isWatered']  ?? false,
  );
}




class AnimalModel {
  final String id;
  final AnimalType type;
  AnimalState state;
  int         dayBorn;
  bool        isFed;
  bool        hasProduced;

  double posX;
  double posY;

  double _velX    = 0;
  double _velY    = 0;
  double _targetX;
  double _targetY;
  bool   _isRoaming = false;

  AnimalModel({
    required this.id,
    required this.type,
    this.state       = AnimalState.baby,
    required this.dayBorn,
    this.isFed       = false,
    this.hasProduced = false,
    double? posX,
    double? posY,
  })  : posX     = posX ?? (GameConstants.penX + 1.5 + GameConstants.rng.nextDouble() * 3.0),
        posY     = posY ?? (GameConstants.penY + 1.5 + GameConstants.rng.nextDouble() * 4.0),
        _targetX = posX ?? (GameConstants.penX + 1.5),
        _targetY = posY ?? (GameConstants.penY + 1.5);

  bool canProduce()               => state == AnimalState.adult && isFed && !hasProduced;
  bool shouldGrow(int currentDay) => state == AnimalState.baby  && (currentDay - dayBorn) >= type.daysToAdult;

  bool tick() {
    const double tickDt = GameConstants.animalTickMs / 1000.0;

    if (!_isRoaming || _reachedTarget()) {
      if (GameConstants.rng.nextDouble() < GameConstants.animalIdleChance) {
        _pickNewTarget();
        _isRoaming = true;
      } else {
        _isRoaming = false;
        _velX *= (1 - GameConstants.animalFrict * tickDt).clamp(0.0, 1.0);
        _velY *= (1 - GameConstants.animalFrict * tickDt).clamp(0.0, 1.0);
        if (_velX.abs() < 0.01) _velX = 0;
        if (_velY.abs() < 0.01) _velY = 0;
        if (_velX == 0 && _velY == 0) return false;
      }
    }

    if (_isRoaming) {
      final dx  = _targetX - posX;
      final dy  = _targetY - posY;
      final len = sqrt(dx * dx + dy * dy);
      if (len > 0.05) {
        final speed = GameConstants.animalMaxSpd * type.speedMult;
        _velX += (dx / len * speed - _velX) * GameConstants.animalAccel * tickDt;
        _velY += (dy / len * speed - _velY) * GameConstants.animalAccel * tickDt;
      }
    }

    posX += _velX * tickDt;
    posY += _velY * tickDt;
    _clampToPen();
    return true;
  }

  bool _reachedTarget() =>
      (posX - _targetX).abs() < 0.15 && (posY - _targetY).abs() < 0.15;

  void _pickNewTarget() {
    _targetX = GameConstants.penX + 0.8 + GameConstants.rng.nextDouble() * (GameConstants.penW - 1.6);
    _targetY = GameConstants.penY + 0.8 + GameConstants.rng.nextDouble() * (GameConstants.penH - 1.6);
  }

  void _clampToPen() {
    posX = posX.clamp(GameConstants.penX + 0.5, GameConstants.penX + GameConstants.penW - 0.5);
    posY = posY.clamp(GameConstants.penY + 0.5, GameConstants.penY + GameConstants.penH - 0.5);
  }

  Map<String, dynamic> toMap() => {
    'id'         : id,
    'type'       : type.index,
    'state'      : state.index,
    'dayBorn'    : dayBorn,
    'isFed'      : isFed,
    'hasProduced': hasProduced,
    'posX'       : posX,
    'posY'       : posY,
  };

  factory AnimalModel.fromMap(Map<String, dynamic> m) => AnimalModel(
    id         : m['id']          ?? '',
    type       : AnimalType.values[m['type']   ?? 0],
    state      : AnimalState.values[m['state'] ?? 0],
    dayBorn    : m['dayBorn']      ?? 0,
    isFed      : m['isFed']        ?? false,
    hasProduced: m['hasProduced']  ?? false,
    posX       : (m['posX'] ?? (GameConstants.penX + 2.0)).toDouble(),
    posY       : (m['posY'] ?? (GameConstants.penY + 2.0)).toDouble(),
  );
}




class InventoryModel {
  Map<CropType, int> seeds;
  int fishCount;
  int eggCount;
  int milkCount;
  int woolCount;
  int honeyCount;
  int horseMilkCount;
  int peacockFeatherCount;
  int turkeyEggCount;

  InventoryModel({
    Map<CropType, int>? seeds,
    this.fishCount          = 0,
    this.eggCount           = 0,
    this.milkCount          = 0,
    this.woolCount          = 0,
    this.honeyCount         = 0,
    this.horseMilkCount     = 0,
    this.peacockFeatherCount= 0,
    this.turkeyEggCount     = 0,
  }) : seeds = seeds ?? { for (final c in CropType.values) c: 0 };

  Map<String, dynamic> toMap() => {
    'seeds'              : seeds.map((k, v) => MapEntry(k.index.toString(), v)),
    'fishCount'          : fishCount,
    'eggCount'           : eggCount,
    'milkCount'          : milkCount,
    'woolCount'          : woolCount,
    'honeyCount'         : honeyCount,
    'horseMilkCount'     : horseMilkCount,
    'peacockFeatherCount': peacockFeatherCount,
    'turkeyEggCount'     : turkeyEggCount,
  };

  factory InventoryModel.fromMap(Map<String, dynamic> m) {
    final sr  = (m['seeds'] as Map<String, dynamic>?) ?? {};
    final map = <CropType, int>{ for (final c in CropType.values) c: 0 };
    sr.forEach((k, v) {
      final idx = int.tryParse(k);
      if (idx != null && idx < CropType.values.length) {
        map[CropType.values[idx]] = (v as int? ?? 0);
      }
    });
    return InventoryModel(
      seeds               : map,
      fishCount           : m['fishCount']           ?? 0,
      eggCount            : m['eggCount']            ?? 0,
      milkCount           : m['milkCount']           ?? 0,
      woolCount           : m['woolCount']           ?? 0,
      honeyCount          : m['honeyCount']          ?? 0,
      horseMilkCount      : m['horseMilkCount']      ?? 0,
      peacockFeatherCount : m['peacockFeatherCount'] ?? 0,
      turkeyEggCount      : m['turkeyEggCount']      ?? 0,
    );
  }
}




class DiaryEntry {
  final int day;
  String    content;

  DiaryEntry({required this.day, this.content = ''});

  Map<String, dynamic> toMap() => {'day': day, 'content': content};
  factory DiaryEntry.fromMap(Map<String, dynamic> m) =>
      DiaryEntry(day: m['day'] ?? 1, content: m['content'] ?? '');
}




enum QuestType {
  harvestCrops,
  waterTiles,
  feedAnimals,
  catchFish,
  tillSoil,
  earnGold,
}

extension QuestTypeExt on QuestType {
  String get icon {
    switch (this) {
      case QuestType.harvestCrops: return '🌾';
      case QuestType.waterTiles:   return '💧';
      case QuestType.feedAnimals:  return '🌽';
      case QuestType.catchFish:    return '🎣';
      case QuestType.tillSoil:     return '⛏️';
      case QuestType.earnGold:     return '🪙';
    }
  }
  String get verb {
    switch (this) {
      case QuestType.harvestCrops: return 'Thu hoạch';
      case QuestType.waterTiles:   return 'Tưới';
      case QuestType.feedAnimals:  return 'Cho ăn';
      case QuestType.catchFish:    return 'Câu cá';
      case QuestType.tillSoil:     return 'Xới đất';
      case QuestType.earnGold:     return 'Kiếm';
    }
  }
  String get unit {
    switch (this) {
      case QuestType.harvestCrops: return 'cây';
      case QuestType.waterTiles:   return 'ô';
      case QuestType.feedAnimals:  return 'con';
      case QuestType.catchFish:    return 'cá';
      case QuestType.tillSoil:     return 'ô';
      case QuestType.earnGold:     return '🪙';
    }
  }
}

class DailyQuest {
  final String    id;
  final QuestType type;
  final int       targetCount;
  int             currentCount;
  bool            completed;
  final int       expReward;
  final int       goldReward;

  DailyQuest({
    required this.id,
    required this.type,
    required this.targetCount,
    this.currentCount = 0,
    this.completed    = false,
    required this.expReward,
    required this.goldReward,
  });

  double get progress => targetCount <= 0 ? 1.0 : (currentCount / targetCount).clamp(0.0, 1.0);
  String get description => '${type.icon} ${type.verb} $targetCount ${type.unit}';

  Map<String, dynamic> toMap() => {
    'id'          : id,
    'type'        : type.index,
    'targetCount' : targetCount,
    'currentCount': currentCount,
    'completed'   : completed,
    'expReward'   : expReward,
    'goldReward'  : goldReward,
  };

  factory DailyQuest.fromMap(Map<String, dynamic> m) => DailyQuest(
    id          : m['id']           ?? '',
    type        : QuestType.values[m['type'] ?? 0],
    targetCount : m['targetCount']  ?? 1,
    currentCount: m['currentCount'] ?? 0,
    completed   : m['completed']    ?? false,
    expReward   : m['expReward']    ?? 10,
    goldReward  : m['goldReward']   ?? 0,
  );
}




class AchievementDef {
  final String id;
  final String icon;
  final String title;
  final String description;
  final int    expReward;

  const AchievementDef({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.expReward,
  });
}

class Achievements {
  static const List<AchievementDef> all = [
    AchievementDef(id:'first_harvest',  icon:'🌾', title:'Vụ Đầu Tiên',    description:'Thu hoạch lần đầu tiên',        expReward:20),
    AchievementDef(id:'harvest_10',     icon:'🏆', title:'Nông Dân Cần Mẫn', description:'Thu hoạch 10 cây',             expReward:30),
    AchievementDef(id:'harvest_50',     icon:'🥇', title:'Vua Nông Nghiệp', description:'Thu hoạch 50 cây',             expReward:80),
    AchievementDef(id:'first_animal',   icon:'🐾', title:'Chủ Trang Trại',  description:'Mua vật nuôi đầu tiên',        expReward:25),
    AchievementDef(id:'animals_5',      icon:'🐄', title:'Trại Đông Vui',   description:'Sở hữu 5+ vật nuôi',          expReward:50),
    AchievementDef(id:'first_fish',     icon:'🎣', title:'Tay Cần Mới',     description:'Câu cá lần đầu tiên',          expReward:15),
    AchievementDef(id:'fish_20',        icon:'🐟', title:'Ngư Phủ Tài Ba',  description:'Câu được 20 con cá',           expReward:50),
    AchievementDef(id:'gold_1000',      icon:'💰', title:'Phú Nông',        description:'Kiếm được 1000 vàng',          expReward:30),
    AchievementDef(id:'gold_5000',      icon:'💎', title:'Địa Chủ',         description:'Kiếm được 5000 vàng',          expReward:80),
    AchievementDef(id:'level_5',        icon:'⭐', title:'Nông Dân Cấp 5',  description:'Đạt cấp độ 5',                 expReward:40),
    AchievementDef(id:'level_10',       icon:'🌟', title:'Nông Dân Cấp 10', description:'Đạt cấp độ 10',                expReward:80),
    AchievementDef(id:'level_25',       icon:'✨', title:'Cao Thủ Trang Trại', description:'Đạt cấp độ 25',             expReward:150),
    AchievementDef(id:'quest_10',       icon:'📋', title:'Người Chăm Chỉ',  description:'Hoàn thành 10 nhiệm vụ',       expReward:60),
    AchievementDef(id:'survived_10',    icon:'☀️', title:'Sống Sót 10 Ngày', description:'Trải qua 10 ngày trên trang trại', expReward:30),
    AchievementDef(id:'survived_30',    icon:'🌈', title:'Nông Dân Kiên Trì', description:'Trải qua 30 ngày trên trang trại', expReward:80),
  ];

  static AchievementDef? findById(String id) {
    try { return all.firstWhere((a) => a.id == id); }
    catch (_) { return null; }
  }
}




class PlayerModel {
  String         uid;
  String         name;
  int            gold;
  int            totalGoldEarned;
  int            currentDay;
  double         playerX;
  double         playerY;

  int            level;
  int            exp;

  int            totalCropsHarvested;
  int            totalFishCaught;
  int            totalQuestsCompleted;

  
  int            lastGiftDay;
  
  int            avatarId;
  int            flowerPotStyle;

  List<DailyQuest> dailyQuests;
  int              questDay;

  List<String>   unlockedAchievements;

  InventoryModel inventory;
  List<DiaryEntry> diary;

  PlayerModel({
    required this.uid,
    required this.name,
    this.gold                  = GameConstants.startGold,
    this.totalGoldEarned       = 0,
    this.currentDay            = 1,
    this.playerX               = 5.0,
    this.playerY               = 7.0,
    this.level                 = 1,
    this.exp                   = 0,
    this.totalCropsHarvested   = 0,
    this.totalFishCaught       = 0,
    this.totalQuestsCompleted  = 0,
    this.lastGiftDay           = 0,
    this.avatarId              = 0,
    this.flowerPotStyle        = 0,
    List<DailyQuest>? dailyQuests,
    this.questDay              = 0,
    List<String>?    unlockedAchievements,
    InventoryModel?  inventory,
    List<DiaryEntry>? diary,
  })  : dailyQuests           = dailyQuests          ?? [],
        unlockedAchievements  = unlockedAchievements ?? [],
        inventory             = inventory             ?? InventoryModel(),
        diary                 = diary                 ?? [DiaryEntry(day: 1)];

  DiaryEntry getDiaryForDay(int day) {
    final found = diary.where((d) => d.day == day).firstOrNull;
    if (found != null) return found;
    final e = DiaryEntry(day: day);
    diary.add(e);
    diary.sort((a, b) => a.day.compareTo(b.day));
    return e;
  }

  Map<String, dynamic> toMap() => {
    'uid'                 : uid,
    'name'                : name,
    'gold'                : gold,
    'totalGoldEarned'     : totalGoldEarned,
    'currentDay'          : currentDay,
    'playerX'             : playerX,
    'playerY'             : playerY,
    'level'               : level,
    'exp'                 : exp,
    'totalCropsHarvested' : totalCropsHarvested,
    'totalFishCaught'     : totalFishCaught,
    'totalQuestsCompleted': totalQuestsCompleted,
    'lastGiftDay'         : lastGiftDay,
    'avatarId'            : avatarId,
    'flowerPotStyle'      : flowerPotStyle,
    'dailyQuests'         : dailyQuests.map((q) => q.toMap()).toList(),
    'questDay'            : questDay,
    'unlockedAchievements': unlockedAchievements,
    'inventory'           : inventory.toMap(),
    'diary'               : diary.map((d) => d.toMap()).toList(),
  };

  factory PlayerModel.fromMap(Map<String, dynamic> m) => PlayerModel(
    uid                  : m['uid']               ?? '',
    name                 : m['name']              ?? 'Nông Dân',
    gold                 : m['gold']              ?? GameConstants.startGold,
    totalGoldEarned      : m['totalGoldEarned']   ?? 0,
    currentDay           : m['currentDay']        ?? 1,
    playerX              : (m['playerX']          ?? 5.0).toDouble(),
    playerY              : (m['playerY']          ?? 7.0).toDouble(),
    level                : (m['level']            ?? 1) as int,
    exp                  : (m['exp']              ?? 0) as int,
    totalCropsHarvested  : (m['totalCropsHarvested']  ?? 0) as int,
    totalFishCaught      : (m['totalFishCaught']      ?? 0) as int,
    totalQuestsCompleted : (m['totalQuestsCompleted'] ?? 0) as int,
    lastGiftDay          : (m['lastGiftDay']      ?? 0) as int,
    avatarId             : (m['avatarId']         ?? 0) as int,
    flowerPotStyle       : (m['flowerPotStyle']   ?? 0) as int,
    dailyQuests          : m['dailyQuests'] != null
        ? (m['dailyQuests'] as List)
            .map((q) => DailyQuest.fromMap(q as Map<String, dynamic>))
            .toList()
        : [],
    questDay             : (m['questDay'] ?? 0) as int,
    unlockedAchievements : m['unlockedAchievements'] != null
        ? (m['unlockedAchievements'] as List).cast<String>()
        : [],
    inventory            : m['inventory'] != null
        ? InventoryModel.fromMap(m['inventory'] as Map<String, dynamic>)
        : InventoryModel(),
    diary                : m['diary'] != null
        ? (m['diary'] as List)
            .map((d) => DiaryEntry.fromMap(d as Map<String, dynamic>))
            .toList()
        : [],
  );
}
