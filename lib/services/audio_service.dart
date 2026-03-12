







import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._() { _init(); }

  
  final AudioPlayer _water   = AudioPlayer();
  final AudioPlayer _sleep   = AudioPlayer();
  final AudioPlayer _rooster = AudioPlayer();
  final AudioPlayer _coins   = AudioPlayer();
  final AudioPlayer _hoe     = AudioPlayer();
  final AudioPlayer _plant   = AudioPlayer();
  final AudioPlayer _feed    = AudioPlayer();

  
  
  
  final List<AudioPlayer> _fishPlayers = [
    AudioPlayer(), AudioPlayer(), AudioPlayer(),
  ];
  int _fishIdx = 0; 

  
  final AudioPlayer _bgm    = AudioPlayer();
  String _currentBgmKey     = '';

  bool   _enabled = true;
  double _volume  = 0.70;
  final  Random _rng = Random();

  void _init() {
    for (final p in [_water, _sleep, _rooster, _coins, _hoe,
      _plant, _feed, ..._fishPlayers]) {
      p.setReleaseMode(ReleaseMode.stop);
    }
    _bgm.setReleaseMode(ReleaseMode.loop);
  }

  bool   get enabled => _enabled;
  double get volume  => _volume;

  void setEnabled(bool v) {
    _enabled = v;
    if (!v) {
      _bgm.pause();
    } else {
      if (_currentBgmKey == 'day')   startDayBgm(force: true);
      if (_currentBgmKey == 'night') startNightBgm(force: true);
    }
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _bgm.setVolume(_volume * 0.55);
  }

  

  Future<void> startDayBgm({bool force = false}) async {
    if (!force && _currentBgmKey == 'day') return;
    _currentBgmKey = 'day';
    if (!_enabled) return;
    try {
      await _bgm.stop();
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(_volume * 0.55);
      await _bgm.play(AssetSource('audio/day_bgm.mp3'));
    } catch (e) {
      debugPrint('[Audio] BGM day missing – $e');
    }
  }

  Future<void> startNightBgm({bool force = false}) async {
    if (!force && _currentBgmKey == 'night') return;
    _currentBgmKey = 'night';
    if (!_enabled) return;
    try {
      await _bgm.stop();
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(_volume * 0.55);
      await _bgm.play(AssetSource('audio/night_bgm.mp3'));
    } catch (e) {
      debugPrint('[Audio] BGM night missing – $e');
    }
  }

  Future<void> stopBgm() async {
    _currentBgmKey = '';
    await _bgm.stop();
  }

  
  
  
  
  
  

  Future<void> _play(AudioPlayer player, String assetPath) async {
    if (!_enabled) return;
    
    try { await player.stop(); } catch (_) {}
    
    try {
      await player.setVolume(_volume);
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[Audio] Cannot play $assetPath – $e');
    }
  }

  

  Future<void> playWater()   => _play(_water,   'audio/water.mp3');
  Future<void> playSleep()   => _play(_sleep,   'audio/sleep.mp3');
  Future<void> playRooster() => _play(_rooster, 'audio/rooster.mp3');
  Future<void> playCoins()   => _play(_coins,   'audio/coins.mp3');
  Future<void> playHoe()     => _play(_hoe,     'audio/hoe.mp3');
  Future<void> playPlant()   => _play(_plant,   'audio/hoe.mp3');
  Future<void> playFeed()    => _play(_feed,    'audio/feed.mp3');

  
  
  Future<void> playFishing() {
    
    final fileIdx = _rng.nextInt(3) + 1; 
    final player  = _fishPlayers[_fishIdx % 3];
    _fishIdx++;
    return _play(player, 'audio/fishing$fileIdx.mp3');
  }

  void dispose() {
    for (final p in [_water, _sleep, _rooster, _coins, _hoe,
      _plant, _feed, _bgm, ..._fishPlayers]) {
      p.dispose();
    }
  }
}
