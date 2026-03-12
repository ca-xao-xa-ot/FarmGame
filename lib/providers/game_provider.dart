







import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_save_service.dart';
import '../services/audio_service.dart';

class GameProvider extends ChangeNotifier {
  
  PlayerModel?          player;
  List<List<TileModel>> tiles           = [];
  List<AnimalModel>     animals         = [];
  ToolType              selectedTool    = ToolType.hand;
  CropType?             selectedSeedType;
  GameScene             currentScene    = GameScene.farm;
  bool                  isNight         = false;
  bool                  isFishing       = false;
  bool                  fishingJustDone = false;
  bool                  isLoading       = false;
  bool                  gameStarted     = false;
  String                message         = '';
  bool                  showMessage     = false;
  int                   fishingCountdown= 0;

  
  
  final Map<String, double> _hoeProgress = {};
  Map<String, double> get hoeProgress => _hoeProgress;

  
  double playerCol = 5.0;
  double playerRow = 7.0;
  int    playerDir = 0;
  bool   isMoving  = false;

  double _velX = 0.0;
  double _velY = 0.0;

  
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  
  final LocalStorageService  _storage = LocalStorageService();
  final FirebaseSaveService  _cloud   = FirebaseSaveService();
  final AudioService         _audio   = AudioService();
  final Uuid                 _uuid    = const Uuid();
  Timer?                     _animalTimer;
  Timer?                     _cloudSaveDebounce;

  AudioService get audio => _audio;

  
  int get expToNextLevel {
    final lv = player?.level ?? 1;
    if (lv >= GameConstants.maxLevel) return 0;
    final x = (lv - 1);
    final need = 60 + x * 25 + x * x * 2;
    return need.clamp(60, 5000);
  }

  bool isCropUnlocked(CropType c)    => (player?.level ?? 1) >= c.unlockLevel;
  bool isAnimalUnlocked(AnimalType a) => (player?.level ?? 1) >= a.unlockLevel;

  void showToast(String msg) => _showMsg(msg);

  void _addExp(int amount) {
    if (player == null || amount <= 0) return;
    if (player!.level >= GameConstants.maxLevel) return;
    player!.exp += amount;
    bool leveledUp = false;
    while (player!.level < GameConstants.maxLevel && player!.exp >= expToNextLevel) {
      player!.exp -= expToNextLevel;
      player!.level += 1;
      leveledUp = true;
    }
    if (leveledUp) {
      _showMsg('🎉 Lên cấp ${player!.level}! Mở khóa thêm trong shop 🏪');
    }
    _checkAchievements();
  }

  
  List<DailyQuest> get dailyQuests => player?.dailyQuests ?? [];

  void _generateDailyQuests(int day) {
    if (player == null) return;
    final rng = GameConstants.rng;
    final lv  = player!.level;
    final pool = <QuestType>[
      QuestType.harvestCrops,
      QuestType.waterTiles,
      QuestType.tillSoil,
      QuestType.catchFish,
    ];
    if (animals.isNotEmpty) pool.add(QuestType.feedAnimals);
    pool.shuffle(rng);
    final chosen = pool.take(3).toList();

    player!.dailyQuests = chosen.map((type) {
      int target, expRew, goldRew;
      switch (type) {
        case QuestType.harvestCrops:
          target = (3 + lv ~/ 5).clamp(3, 15); expRew = 20 + lv * 2; goldRew = 30 + lv * 5; break;
        case QuestType.waterTiles:
          target = (4 + lv ~/ 4).clamp(4, 20); expRew = 15 + lv;     goldRew = 20 + lv * 3; break;
        case QuestType.feedAnimals:
          target = (animals.length).clamp(1, 5); expRew = 18 + lv * 2; goldRew = 25 + lv * 4; break;
        case QuestType.catchFish:
          target = (2 + lv ~/ 6).clamp(2, 8); expRew = 25 + lv * 2; goldRew = 40 + lv * 5; break;
        case QuestType.tillSoil:
          target = (3 + lv ~/ 5).clamp(3, 12); expRew = 12 + lv; goldRew = 15 + lv * 2; break;
        case QuestType.earnGold:
          target = (100 + lv * 20).clamp(100, 2000); expRew = 30 + lv * 3; goldRew = 0; break;
      }
      return DailyQuest(
        id: _uuid.v4(), type: type, targetCount: target,
        expReward: expRew, goldReward: goldRew,
      );
    }).toList();
    player!.questDay = day;
  }

  void _progressQuest(QuestType type, {int amount = 1}) {
    if (player == null) return;
    bool anyNewlyCompleted = false;
    for (final q in player!.dailyQuests) {
      if (q.type == type && !q.completed) {
        q.currentCount = (q.currentCount + amount).clamp(0, q.targetCount);
        if (q.currentCount >= q.targetCount) {
          q.completed = true;
          anyNewlyCompleted = true;
          player!.gold += q.goldReward;
          player!.totalGoldEarned += q.goldReward;
          player!.totalQuestsCompleted++;
          _addExp(q.expReward);
          _showMsg('📋 Hoàn thành nhiệm vụ \"${q.description}\"!\n+${q.expReward} EXP  +${q.goldReward}🪙');
          _checkAchievements();
        }
      }
    }
    if (anyNewlyCompleted) _saveAll();
  }

  
  bool hasAchievement(String id) => player?.unlockedAchievements.contains(id) ?? false;

  void _unlockAchievement(String id) {
    if (player == null || hasAchievement(id)) return;
    final def = Achievements.findById(id);
    if (def == null) return;
    player!.unlockedAchievements.add(id);
    _addExp(def.expReward);
    _showMsg('🏅 Thành tích: \"${def.title}\" +${def.expReward} EXP!');
    _saveAll();
  }

  void _checkAchievements() {
    if (player == null) return;
    final p = player!;
    if (p.totalCropsHarvested >= 1)   _unlockAchievement('first_harvest');
    if (p.totalCropsHarvested >= 10)  _unlockAchievement('harvest_10');
    if (p.totalCropsHarvested >= 50)  _unlockAchievement('harvest_50');
    if (animals.isNotEmpty)           _unlockAchievement('first_animal');
    if (animals.length >= 5)          _unlockAchievement('animals_5');
    if (p.totalFishCaught >= 1)       _unlockAchievement('first_fish');
    if (p.totalFishCaught >= 20)      _unlockAchievement('fish_20');
    if (p.totalGoldEarned >= 1000)    _unlockAchievement('gold_1000');
    if (p.totalGoldEarned >= 5000)    _unlockAchievement('gold_5000');
    if (p.level >= 5)                 _unlockAchievement('level_5');
    if (p.level >= 10)                _unlockAchievement('level_10');
    if (p.level >= 25)                _unlockAchievement('level_25');
    if (p.totalQuestsCompleted >= 10) _unlockAchievement('quest_10');
    if (p.currentDay >= 10)           _unlockAchievement('survived_10');
    if (p.currentDay >= 30)           _unlockAchievement('survived_30');
  }

  
  
  
  void updateFrame(double dt) {
    if (!gameStarted || currentScene != GameScene.farm) return;
    _updatePlayerPhysics(dt.clamp(0.0, 0.05));
  }

  void _updatePlayerPhysics(double dt) {
    double intentX = 0, intentY = 0;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft))  intentX -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) intentX += 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp))    intentY -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown))  intentY += 1;

    if (intentX != 0 && intentY != 0) {
      intentX *= GameConstants.diagMultiplier;
      intentY *= GameConstants.diagMultiplier;
    }

    final maxSpd = GameConstants.playerMaxSpd;
    final accel  = GameConstants.playerAccel;
    final fric   = GameConstants.playerFrict;

    if (intentX != 0) {
      _velX += (intentX * maxSpd - _velX) * accel * dt;
    } else {
      _velX *= (1.0 - (fric * dt).clamp(0.0, 1.0));
      if (_velX.abs() < 0.02) _velX = 0;
    }
    if (intentY != 0) {
      _velY += (intentY * maxSpd - _velY) * accel * dt;
    } else {
      _velY *= (1.0 - (fric * dt).clamp(0.0, 1.0));
      if (_velY.abs() < 0.02) _velY = 0;
    }

    final newCol = playerCol + _velX * dt;
    final newRow = playerRow + _velY * dt;
    if (_canMoveTo(newCol, playerRow)) { playerCol = newCol; } else { _velX = 0; }
    if (_canMoveTo(playerCol, newRow)) { playerRow = newRow; } else { _velY = 0; }

    if (_velX.abs() > 0.05 || _velY.abs() > 0.05) {
      if (_velX.abs() >= _velY.abs()) {
        playerDir = _velX > 0 ? 3 : 2;
      } else {
        playerDir = _velY > 0 ? 0 : 1;
      }
    }

    final wasMoving = isMoving;
    isMoving = _velX.abs() > 0.02 || _velY.abs() > 0.02;
    if (player != null) { player!.playerX = playerCol; player!.playerY = playerRow; }
    if (isMoving || wasMoving) notifyListeners();
  }

  
  
  
  bool _canMoveTo(double col, double row) {
    final r = GameConstants.playerRadius;
    if (col - r < 0 || col + r > GameConstants.farmCols - 0.3) return false;
    if (row - r < 0 || row + r > GameConstants.farmRows - 0.3) return false;
    for (final rect in GameConstants.solidRects) {
      if (col + r > rect[0] && col - r < rect[2] &&
          row + r > rect[1] && row - r < rect[3]) return false;
    }
    return true;
  }

  bool _isNearHouse() =>
      (playerCol - GameConstants.houseCol).abs() < 3.5 &&
      (playerRow - GameConstants.houseRow).abs() < 3.5;

  
  
  
  void handleKeyDown(LogicalKeyboardKey key) {
    _pressedKeys.add(key);
    if (key == LogicalKeyboardKey.digit1) setTool(ToolType.hand);
    if (key == LogicalKeyboardKey.digit2) setTool(ToolType.hoe);
    if (key == LogicalKeyboardKey.digit3) setTool(ToolType.wateringCan);
    if (key == LogicalKeyboardKey.digit4) setTool(ToolType.fishingRod);
    if (key == LogicalKeyboardKey.keyE || key == LogicalKeyboardKey.space) {
      _interactFront();
    }
    if (key == LogicalKeyboardKey.keyF) goToSleep();
    if (key == LogicalKeyboardKey.keyH) {
      if (currentScene == GameScene.house) {
        exitHouse();
      } else if (_isNearHouse()) {
        enterHouse();
      } else {
        _showMsg('Đến gần nhà rồi nhấn H để vào 🏠');
      }
    }
  }

  void handleKeyUp(LogicalKeyboardKey key) => _pressedKeys.remove(key);
  void clearKeys()                          => _pressedKeys.clear();

  void _interactFront() {
    const off = 1.1;
    double tc = playerCol, tr = playerRow;
    switch (playerDir) {
      case 0: tr += off; break;
      case 1: tr -= off; break;
      case 2: tc -= off; break;
      case 3: tc += off; break;
    }
    onTileTap(tr.round(), tc.round());
  }

  
  
  

  
  
  Future<void> startNewGame(String name) async {
    isLoading = true; notifyListeners();

    final User? currentUser = FirebaseAuth.instance.currentUser;
    String uid = currentUser?.uid ?? _uuid.v4();

    
    
    if (currentUser != null) {
      final cloudSave = await _cloud.loadGame();
      if (cloudSave != null) {
        player    = cloudSave.player;
        player!.uid = uid;
        playerCol = player!.playerX; playerRow = player!.playerY;
        tiles     = cloudSave.tiles;
        animals   = cloudSave.animals;
        gameStarted = true;
        _startAnimalTimer();
        await _saveLocal();
        isLoading = false; notifyListeners();
        _audio.startDayBgm();
        _showMsg('☁️ Đã tải dữ liệu trang trại của bạn!');
        return;
      }
    }

    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);

    player      = PlayerModel(uid: uid, name: name);
    tiles       = _buildDefaultTiles();
    animals     = [];
    playerCol   = 5.0; playerRow = 7.0;
    isNight     = false;
    gameStarted = true;

    _generateDailyQuests(1);
    _startAnimalTimer();
    await _saveAll();
    isLoading = false; notifyListeners();
    _audio.startDayBgm();
    _showMsg('🌾 Chào mừng ${name} đến Nông Trại Xanh!');
  }

  
  Future<bool> tryLoadSavedGame() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    isLoading = true; notifyListeners();

    
    try {
      final cloudSave = await _cloud.loadGame();
      if (cloudSave != null) {
        player    = cloudSave.player;
        player!.uid = currentUser.uid;
        playerCol = player!.playerX; playerRow = player!.playerY;
        tiles     = cloudSave.tiles;
        animals   = cloudSave.animals;
        gameStarted = true;
        _startAnimalTimer();
        await _saveLocal();   
        isLoading = false; notifyListeners();
        _audio.startDayBgm();
        return true;
      }
    } catch (_) {}

    
    try {
      final p = await _storage.loadPlayer();
      if (p != null) {
        p.uid = currentUser.uid;
        player    = p;
        playerCol = p.playerX; playerRow = p.playerY;
        tiles     = (await _storage.loadTiles()) ?? _buildDefaultTiles();
        animals   = await _storage.loadAnimals();
        gameStarted = true;
        _startAnimalTimer();
        
        await _saveCloud();
        isLoading = false; notifyListeners();
        _audio.startDayBgm();
        return true;
      }
    } catch (_) {}

    isLoading = false; notifyListeners();
    return false;
  }

  List<List<TileModel>> _buildDefaultTiles() => List.generate(
      GameConstants.farmRows,
      (_) => List.generate(GameConstants.farmCols, (_) => TileModel()));

  
  
  
  void _startAnimalTimer() {
    _animalTimer?.cancel();
    _animalTimer = Timer.periodic(
      const Duration(milliseconds: GameConstants.animalTickMs),
      (_) {
        if (animals.isEmpty || currentScene != GameScene.farm) return;
        bool changed = false;
        for (final a in animals) { if (a.tick()) changed = true; }
        if (changed) notifyListeners();
      },
    );
  }

  
  
  
  void onTileTap(int row, int col) {
    if (player == null) return;
    if (row < 0 || row >= GameConstants.farmRows ||
        col < 0 || col >= GameConstants.farmCols) return;

    final dist = sqrt(pow(col - playerCol, 2) + pow(row - playerRow, 2));
    if (dist > 2.6) {
      _showMsg('Quá xa! Đến gần hơn 👣  (dùng D-pad)');
      notifyListeners(); return;
    }

    if (_isHouseTile(row, col)) { enterHouse(); return; }

    if (_isPond(row, col)) {
      selectedTool == ToolType.fishingRod
          ? _startFishing()
          : _showMsg('Chọn 🎣 cần câu (phím 4 / toolbar) rồi bấm ao!');
      notifyListeners(); return;
    }

    if (_inPen(row, col)) {
      _showMsg('Khu chăn nuôi 🐔🐑🐝 – dùng panel bên phải để tương tác');
      notifyListeners(); return;
    }

    final tile = tiles[row][col];
    switch (selectedTool) {
      case ToolType.hoe:         _useHoeSmooth(tile, row, col); break;
      case ToolType.wateringCan: _useWater(tile);  break;
      case ToolType.hand:        _useHand(tile);   break;
      case ToolType.fishingRod:  _showMsg('Đến ao để câu cá! 🎣'); break;
    }
    notifyListeners();
    _saveAll();
  }

  
  void _useHoeSmooth(TileModel t, int row, int col) {
    if (t.state != TileState.grass) {
      _showMsg('Chỉ xới được ô cỏ!');
      return;
    }
    final key = '$row,$col';
    if (_hoeProgress.containsKey(key)) return; 

    _audio.playHoe();
    _hoeProgress[key] = 0.0;
    notifyListeners();

    const int steps = 12; 
    const int stepMs = GameConstants.hoeDurationMs ~/ steps;
    int step = 0;

    Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      step++;
      _hoeProgress[key] = step / steps;
      notifyListeners();
      if (step >= steps) {
        timer.cancel();
        _hoeProgress.remove(key);
        t.state = TileState.ground;
        _showMsg('Đã xới đất ⛏️  –  giờ trồng cây (tay → bấm đất)');
        _progressQuest(QuestType.tillSoil);
        notifyListeners();
        _saveAll();
      }
    });
  }

  void _useWater(TileModel t) {
    if (t.state == TileState.planted) {
      t.isWatered = true;
      t.state = TileState.watered;
      _audio.playWater();
      _showMsg('Đã tưới nước 💧  –  ngủ để cây lớn (nút 🌙)');
      _progressQuest(QuestType.waterTiles);
    } else if (t.state == TileState.growing) {
      _showMsg('Cây đang lớn, đợi 1 ngày nữa!');
    } else {
      _showMsg('Cần trồng cây trước!');
    }
  }

  void _useHand(TileModel t) {
    if (t.state == TileState.ground) {
      _tryPlant(t);
    } else if (t.state == TileState.ready) {
      _harvest(t);
    } else if (t.state == TileState.grass) {
      _showMsg('Dùng ⛏️ cuốc xới đất trước (toolbar)');
    } else {
      _showMsg('Cây chưa chín, hãy đợi thêm!');
    }
  }

  void _tryPlant(TileModel t) {
    if (selectedSeedType == null) {
      _showMsg('Chọn hạt giống từ shop trước! (bấm 🏪)');
      return;
    }
    final cnt = player!.inventory.seeds[selectedSeedType!] ?? 0;
    if (cnt <= 0) {
      _showMsg('Hết hạt ${selectedSeedType!.emoji} ${selectedSeedType!.label}! Mua thêm ở 🏪');
      return;
    }
    player!.inventory.seeds[selectedSeedType!] = cnt - 1;
    t.state = TileState.planted;
    t.cropType = selectedSeedType;
    t.dayPlanted = player!.currentDay;
    t.isWatered  = false;
    _audio.playPlant();
    _showMsg('Đã gieo ${selectedSeedType!.emoji} ${selectedSeedType!.label}! Tưới nước đi 💧');
  }

  void _harvest(TileModel t) {
    if (t.cropType == null) return;
    final gold = t.cropType!.goldValue;
    player!.gold += gold;
    player!.totalGoldEarned += gold;
    player!.totalCropsHarvested++;
    _addExp((gold / 10).round().clamp(3, 25));
    _audio.playCoins();
    _showMsg('+$gold 🪙  Thu hoạch ${t.cropType!.emoji} ${t.cropType!.label}!');
    t.state = TileState.grass;
    t.cropType = null;
    t.isWatered = false;
    t.dayPlanted = 0;
    _cloud.updateLeaderboard(player!.name, player!.totalGoldEarned, player!.level);
    _progressQuest(QuestType.harvestCrops);
    _checkAchievements();
  }

  
  
  
  Future<void> _startFishing() async {
    if (isFishing) return;
    isFishing        = true;
    fishingJustDone  = false;
    fishingCountdown = GameConstants.fishingSeconds;
    notifyListeners();
    for (int i = GameConstants.fishingSeconds; i > 0; i--) {
      await _audio.playFishing();
      await Future.delayed(const Duration(seconds: 1));
      fishingCountdown = i - 1;
      notifyListeners();
    }
    isFishing       = false;
    fishingJustDone = true;
    if (player != null) {
      player!.inventory.fishCount++;
      player!.totalFishCaught++;
    }
    _progressQuest(QuestType.catchFish);
    _checkAchievements();
    _showMsg('🐟 Câu được cá! (+${GameConstants.fishGoldValue}🪙) – Bấm "Bán" trong bảng Vật nuôi 🎣');
    notifyListeners();
    _saveAll();
  }

  
  
  
  Future<void> goToSleep() async {
    if (isNight) return;
    isNight = true;
    _audio.playSleep();
    Future.delayed(const Duration(milliseconds: 600), _audio.startNightBgm);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1600));

    player!.currentDay++;
    for (final row in tiles) {
      for (final t in row) {
        if (t.state == TileState.watered)     t.state = TileState.growing;
        else if (t.state == TileState.growing) t.state = TileState.ready;
        t.isWatered = false;
      }
    }
    for (final a in animals) {
      if (a.shouldGrow(player!.currentDay)) a.state = AnimalState.adult;
      if (a.state == AnimalState.adult)     a.hasProduced = false;
      a.isFed = false;
    }
    player!.getDiaryForDay(player!.currentDay);
    _generateDailyQuests(player!.currentDay);
    isNight = false;
    _audio.playRooster();
    Future.delayed(const Duration(milliseconds: 1200), _audio.startDayBgm);
    _checkAchievements();
    _showMsg('🐓  Gà gáy rồi! Ngày ${player!.currentDay} bắt đầu ☀️');
    notifyListeners();
    await _saveAll();
  }

  
  
  
  void enterHouse() {
    currentScene = GameScene.house;
    _showMsg('🏠 Đã vào nhà!');
    notifyListeners();
  }

  void exitHouse() {
    currentScene = GameScene.farm;
    notifyListeners();
  }

  
  
  
  bool buySeed(CropType type, int qty) {
    if (player == null) return false;
    if (!isCropUnlocked(type)) {
      _showMsg('🔒 Cần Lv${type.unlockLevel} để mua ${type.label}!');
      notifyListeners(); return false;
    }
    final cost = type.seedCost * qty;
    if (player!.gold < cost) return false;
    player!.gold -= cost;
    player!.inventory.seeds[type] = (player!.inventory.seeds[type] ?? 0) + qty;
    selectSeed(type);
    _showMsg('Mua ${qty}x ${type.emoji} ${type.label}! (-${cost}🪙)');
    notifyListeners(); _saveAll(); return true;
  }

  bool buyAnimal(AnimalType type) {
    if (player == null) return false;
    if (!isAnimalUnlocked(type)) {
      _showMsg('🔒 Cần Lv${type.unlockLevel} để mua ${type.label}!');
      notifyListeners(); return false;
    }
    if (player!.gold < type.buyCost) {
      _showMsg('Không đủ 🪙! Cần ${type.buyCost}🪙');
      notifyListeners(); return false;
    }
    final cnt = animals.where((a) => a.type == type).length;
    final max = type.maxCount;
    if (cnt >= max) {
      _showMsg('Đã đủ $max con ${type.label}!');
      notifyListeners(); return false;
    }
    player!.gold -= type.buyCost;
    animals.add(AnimalModel(id: _uuid.v4(), type: type, dayBorn: player!.currentDay));
    _showMsg('Mua ${type.emoji} ${type.label}! (-${type.buyCost}🪙)');
    _checkAchievements();
    notifyListeners(); _saveAll(); return true;
  }

  
  
  
  void feedAnimal(String id) {
    if (player == null) return;
    final a = animals.where((x) => x.id == id).firstOrNull;
    if (a == null) return;
    if (a.state == AnimalState.baby) {
      final daysLeft = a.type.daysToAdult - (player!.currentDay - a.dayBorn);
      _showMsg('${a.type.babyEmoji} Còn nhỏ! Ngủ thêm ~$daysLeft ngày nữa 🌱');
      notifyListeners(); return;
    }
    if (a.isFed) {
      _showMsg('${a.type.emoji} Đã ăn no rồi! Đợi ngày mai ✅');
      notifyListeners(); return;
    }
    if (player!.gold < a.type.feedCost) {
      _showMsg('Không đủ 🪙! Cần ${a.type.feedCost}🪙');
      notifyListeners(); return;
    }
    player!.gold -= a.type.feedCost;
    a.isFed = true;
    _audio.playFeed();
    _showMsg('Đã cho ${a.type.emoji} ăn! (-${a.type.feedCost}🪙)  Chờ sản phẩm 🥚🥛');
    _progressQuest(QuestType.feedAnimals);
    notifyListeners(); _saveAll();
  }

  void collectProduce(String id) {
    if (player == null) return;
    final a = animals.where((x) => x.id == id).firstOrNull;
    if (a == null || !a.canProduce()) {
      _showMsg('Chưa có sản phẩm! Hãy cho ăn trước 🌽');
      notifyListeners(); return;
    }
    final v = a.type.produceVal;
    player!.gold += v;
    player!.totalGoldEarned += v;
    _addExp((v / 10).round().clamp(2, 20));
    a.hasProduced = true;

    switch (a.type) {
      case AnimalType.chicken: case AnimalType.duck: case AnimalType.turkey:
        player!.inventory.eggCount++;
        player!.inventory.turkeyEggCount += (a.type == AnimalType.turkey ? 1 : 0);
        break;
      case AnimalType.cow: case AnimalType.horse:
        player!.inventory.milkCount++;
        player!.inventory.horseMilkCount += (a.type == AnimalType.horse ? 1 : 0);
        break;
      case AnimalType.sheep:
        player!.inventory.woolCount++;
        break;
      case AnimalType.bee:
        player!.inventory.honeyCount++;
        break;
      case AnimalType.rabbit: case AnimalType.peacock:
        player!.inventory.peacockFeatherCount += (a.type == AnimalType.peacock ? 1 : 0);
        break;
      case AnimalType.pig: break;
    }

    _audio.playCoins();
    _showMsg('+${v}🪙  Thu được ${a.type.produce}!');
    _cloud.updateLeaderboard(player!.name, player!.totalGoldEarned, player!.level);
    _checkAchievements();
    notifyListeners(); _saveAll();
  }

  void sellFish() {
    if (player == null || player!.inventory.fishCount <= 0) {
      _showMsg('Không có cá để bán!');
      notifyListeners(); return;
    }
    final earned = player!.inventory.fishCount * GameConstants.fishGoldValue;
    player!.gold += earned;
    player!.totalGoldEarned += earned;
    _addExp((earned / 50).round().clamp(1, 20));
    player!.inventory.fishCount = 0;
    _audio.playCoins();
    _showMsg('+${earned}🪙  Bán toàn bộ cá!');
    _cloud.updateLeaderboard(player!.name, player!.totalGoldEarned, player!.level);
    _checkAchievements();
    notifyListeners(); _saveAll();
  }

  
  
  
  void selectSeed(CropType t) {
    if (!isCropUnlocked(t)) {
      _showMsg('🔒 Cần Lv${t.unlockLevel} để dùng ${t.label}!');
      notifyListeners(); return;
    }
    selectedSeedType = t;
    notifyListeners();
  }

  void setTool(ToolType t) {
    selectedTool = t;
    notifyListeners();
  }

  void feedAllAnimals() {
    if (player == null) return;
    final feedables = animals.where((a) => a.state == AnimalState.adult && !a.isFed).toList();
    if (feedables.isEmpty) {
      _showMsg('Tất cả vật nuôi đã ăn no ✅');
      notifyListeners(); return;
    }
    int fedCount = 0, spent = 0;
    for (final a in feedables) {
      final cost = a.type.feedCost;
      if (player!.gold < cost) break;
      player!.gold -= cost;
      spent += cost;
      a.isFed = true;
      fedCount++;
    }
    if (fedCount == 0) {
      final minCost = feedables.map((a) => a.type.feedCost).reduce((a, b) => a < b ? a : b);
      _showMsg('Không đủ 🪙 để cho ăn! Cần ít nhất ${minCost}🪙');
      notifyListeners(); return;
    }
    _audio.playFeed();
    _progressQuest(QuestType.feedAnimals, amount: fedCount);
    _showMsg('🌽 Đã cho ăn $fedCount con (-${spent}🪙)');
    notifyListeners(); _saveAll();
  }

  
  void claimDailyGift() {
    if (player == null) return;
    final today = player!.currentDay;
    if (player!.lastGiftDay >= today) {
      _showMsg('🎁 Bạn đã nhận quà hôm nay rồi! Quay lại ngày mai nhé!');
      notifyListeners(); return;
    }
    
    final rng = today * 31 + player!.level * 7;
    final goldGift = 50 + (rng % 100);
    final seedBonus = (rng % 3) == 0;
    player!.gold += goldGift;
    player!.lastGiftDay = today;
    _audio.playCoins();
    if (seedBonus) {
      _showMsg('🎁 Phần thưởng: +${goldGift}🪙 + Hạt giống miễn phí! 🌱');
    } else {
      _showMsg('🎁 Phần thưởng hôm nay: +${goldGift}🪙! 💰');
    }
    _addExp(30);
    _checkAchievements();
    notifyListeners(); _saveAll();
  }

  void saveDiaryEntry(int day, String content) {
    if (player == null) return;
    player!.getDiaryForDay(day).content = content;
    notifyListeners(); _saveAll();
  }

  Future<void> saveGame() async {
    await _saveAll();
    _showMsg('☁️ Game đã lưu lên đám mây!');
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() => _cloud.getLeaderboard();

  
  Future<void> _saveAll() async {
    if (player == null) return;
    await Future.wait([
      _saveLocal(),
      _saveCloudDebounced(),
    ]);
  }

  Future<void> _saveLocal() async {
    if (player == null) return;
    await Future.wait([
      _storage.savePlayer(player!),
      _storage.saveTiles(tiles),
      _storage.saveAnimals(animals),
    ]);
  }

  Future<void> _saveCloud() async {
    if (player == null) return;
    await _cloud.saveGame(player: player!, tiles: tiles, animals: animals);
  }

  
  Future<void> _saveCloudDebounced() async {
    _cloudSaveDebounce?.cancel();
    _cloudSaveDebounce = Timer(const Duration(seconds: 3), _saveCloud);
  }

  void _showMsg(String msg) {
    message = msg; showMessage = true;
    Future.delayed(const Duration(seconds: 3), () {
      showMessage = false; notifyListeners();
    });
  }

  bool _isPond(int r, int c) =>
      c >= GameConstants.pondX && c < GameConstants.pondX + GameConstants.pondW &&
      r >= GameConstants.pondY && r < GameConstants.pondY + GameConstants.pondH;
  bool _inPen(int r, int c) =>
      c >= GameConstants.penX && c < GameConstants.penX + GameConstants.penW &&
      r >= GameConstants.penY && r < GameConstants.penY + GameConstants.penH;
  bool _isHouseTile(int r, int c) => c >= 15 && c <= 17 && r >= 8 && r <= 10;

  @override
  void dispose() {
    _animalTimer?.cancel();
    _cloudSaveDebounce?.cancel();
    super.dispose();
  }
}
