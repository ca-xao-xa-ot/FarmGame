import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../widgets/toolbar_widget.dart';
import '../widgets/hud_widget.dart';
import '../widgets/shop_dialog.dart';
import '../widgets/leaderboard_dialog.dart';
import '../widgets/farm_painter.dart';
import '../widgets/animal_panel.dart';
import '../widgets/quest_panel.dart';
import '../widgets/achievement_dialog.dart';
import 'house_screen.dart';












class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Ticker _ticker;
  Duration _lastTick  = Duration.zero;
  bool     _firstTick = true;
  final TransformationController _camCtrl  = TransformationController();
  final FocusNode                _focusNode = FocusNode();
  Offset _pointerDownScreen = Offset.zero;
  bool _showAnimalPanel = false;
  bool _showQuestPanel  = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gp = context.read<GameProvider>();
      
      if (!gp.gameStarted) {
        bool loaded = await gp.tryLoadSavedGame();
        if (!loaded) await gp.startNewGame('Nông dân');
      }
    });

    _ticker = createTicker((elapsed) {
      if (_firstTick) { _lastTick = elapsed; _firstTick = false; return; }
      final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
      _lastTick = elapsed;
      if (mounted) {
        context.read<GameProvider>().updateFrame(dt);
        _followPlayer();
      }
    });
    _ticker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      context.read<GameProvider>().saveGame();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _camCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  
  void _followPlayer() {
    final gp   = context.read<GameProvider>();
    final size = MediaQuery.of(context).size;
    final ts   = GameConstants.tileSize;

    final targetX = gp.playerCol * ts - size.width  / 2 + ts / 2;
    final targetY = gp.playerRow * ts - size.height / 2 + ts / 2;

    final maxX = GameConstants.farmCols * ts - size.width;
    final maxY = GameConstants.farmRows * ts - size.height;
    final cx   = targetX.clamp(0.0, maxX.clamp(0.0, double.infinity));
    final cy   = targetY.clamp(0.0, maxY.clamp(0.0, double.infinity));

    final cur  = _camCtrl.value.getTranslation();
    const lerp = 0.14;
    final nx   = cur.x + (-cx - cur.x) * lerp;
    final ny   = cur.y + (-cy - cur.y) * lerp;

    _camCtrl.value = Matrix4.identity()..translate(nx, ny);
  }

  
  
  

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (ctx, gp, _) {
      if (gp.currentScene == GameScene.house) return const HouseScreen();

      
      final screenH  = MediaQuery.of(context).size.height;
      final topPad   = MediaQuery.of(context).padding.top;
      
      final hudH     = 60.0 + topPad;    
      final toolbarH = 92.0;
      final panelMaxH = screenH - hudH - toolbarH - 16;

      return Focus(
        focusNode : _focusNode,
        autofocus : true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            gp.handleKeyDown(event.logicalKey);
            return KeyEventResult.handled;
          }
          if (event is KeyUpEvent) {
            gp.handleKeyUp(event.logicalKey);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF5A8F2E),
          body: Stack(children: [

            
            _buildFarmView(gp),

            
            AnimatedOpacity(
              opacity : gp.isNight ? 0.72 : 0.0,
              duration: const Duration(milliseconds: 1200),
              child   : Container(color: const Color(0xFF000033)),
            ),

            
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(child: HudWidget(gp: gp)),
            ),

            
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ToolbarWidget(gp: gp),
            ),

            
            
            Positioned(
              bottom: toolbarH + 8,
              right : 10,
              child : _buildActionButtons(ctx, gp, panelMaxH),
            ),

            
            Positioned(
              bottom: toolbarH + 8,
              left  : 10,
              child : _buildDPad(gp),
            ),

            
            if (_showQuestPanel)
              Positioned(
                top : hudH,
                left: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: panelMaxH,
                    maxWidth : 230,
                  ),
                  child: SingleChildScrollView(
                    child: QuestPanelWidget(
                      gp     : gp,
                      onClose: () => setState(() => _showQuestPanel = false),
                    ),
                  ),
                ),
              ),

            
            if (_showAnimalPanel)
              Positioned(
                top  : hudH,
                right: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: panelMaxH,
                    maxWidth : 220,
                  ),
                  child: SingleChildScrollView(
                    child: AnimalPanelWidget(
                      gp     : gp,
                      onClose: () => setState(() => _showAnimalPanel = false),
                    ),
                  ),
                ),
              ),

            
            
            if (!_showAnimalPanel)
              Positioned(
                top  : hudH + 4,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _showAnimalPanel = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.62),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('🐾', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 5),
                      Text('Vật nuôi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ),

            
            if (gp.showMessage)
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    
                    
                    alignment: const Alignment(0.0, -0.25),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: _buildToast(gp.message),
                    ),
                  ),
                ),
              ),

            
            if (gp.isFishing)
              Positioned.fill(
                child: Center(child: _buildFishingOverlay(gp)),
              ),

          ]),
        ),
      );
    });
  }

  
  
  

  Widget _buildFarmView(GameProvider gp) {
    final tw = GameConstants.farmCols * GameConstants.tileSize;
    final th = GameConstants.farmRows * GameConstants.tileSize;

    return InteractiveViewer(
      transformationController: _camCtrl,
      minScale     : 0.5,
      maxScale     : 2.5,
      constrained  : false,
      onInteractionStart: (_) => _focusNode.requestFocus(),
      child: SizedBox(
        width : tw,
        height: th,
        child : Listener(
          onPointerDown: (e) {
            _pointerDownScreen = e.position;
          },
          onPointerUp: (e) {
            final screenDelta = (e.position - _pointerDownScreen).distance;
            if (screenDelta < 10.0) {
              _focusNode.requestFocus();
              final scenePos = _camCtrl.toScene(e.localPosition);
              final col = (scenePos.dx / GameConstants.tileSize).floor();
              final row = (scenePos.dy / GameConstants.tileSize).floor();
              gp.onTileTap(row, col);
            }
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size   : Size(tw, th),
              painter: FarmPainter(
                tiles       : gp.tiles,
                animals     : gp.animals,
                playerCol   : gp.playerCol,
                playerRow   : gp.playerRow,
                playerDir   : gp.playerDir,
                isMoving    : gp.isMoving,
                selectedTool: gp.selectedTool,
                hoeProgress : gp.hoeProgress,
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  
  
  
  
  

  Widget _buildDPad(GameProvider gp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 50),
          _dpadDir('↑', LogicalKeyboardKey.keyW, gp),
          const SizedBox(width: 50),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _dpadDir('←', LogicalKeyboardKey.keyA, gp),
          _dpadAct('⚡', gp),
          _dpadDir('→', LogicalKeyboardKey.keyD, gp),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 50),
          _dpadDir('↓', LogicalKeyboardKey.keyS, gp),
          const SizedBox(width: 50),
        ]),
      ],
    );
  }

  Widget _dpadDir(String label, LogicalKeyboardKey key, GameProvider gp) {
    return _DPadButton(
      child   : Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      color   : Colors.black.withOpacity(0.58),
      onDown  : () => gp.handleKeyDown(key),
      onUp    : () => gp.handleKeyUp(key),
      onCancel: () => gp.handleKeyUp(key),
    );
  }

  Widget _dpadAct(String emoji, GameProvider gp) {
    return _DPadButton(
      child   : Text(emoji, style: const TextStyle(fontSize: 18)),
      color   : Colors.amber.withOpacity(0.80),
      onDown  : () => gp.handleKeyDown(LogicalKeyboardKey.keyE),
      onUp    : () => gp.handleKeyUp(LogicalKeyboardKey.keyE),
      onCancel: () => gp.handleKeyUp(LogicalKeyboardKey.keyE),
    );
  }

  
  
  

  Widget _buildActionButtons(BuildContext ctx, GameProvider gp, double maxH) {
    final btns = <Widget>[
      _fab('🏪', 'Shop',  () => _openShop(ctx, gp),
          colors: [const Color(0xFFFF9800), const Color(0xFFE65100)]),
      _fab('🏆', 'Hạng',  () => _openLeaderboard(ctx, gp),
          colors: [const Color(0xFFFFD700), const Color(0xFFFF8F00)]),
      _fab('💾', 'Lưu',   () => gp.saveGame(),
          colors: [const Color(0xFF42A5F5), const Color(0xFF1565C0)]),
      _fab('🌙', 'Ngủ',   () => gp.goToSleep(),
          colors: [const Color(0xFF7E57C2), const Color(0xFF4527A0)]),
      _fab('🐾', 'Nuôi',  () => setState(() => _showAnimalPanel = !_showAnimalPanel),
          colors: [const Color(0xFF66BB6A), const Color(0xFF2E7D32)]),
      _fab('📋', 'Quest', () => setState(() => _showQuestPanel = !_showQuestPanel),
          colors: [const Color(0xFFEF5350), const Color(0xFFC62828)]),
      _fab(gp.audio.enabled ? '🔊' : '🔇', '',
              () { gp.audio.setEnabled(!gp.audio.enabled); setState(() {}); }),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: btns.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: b,
          )).toList(),
        ),
      ),
    );
  }

  
  Widget _fab(String emoji, String label, VoidCallback onTap, {List<Color>? colors}) {
    final btnColors = colors ?? [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)];
    final isWhite = colors == null;
    return GestureDetector(
      onTap: () { _focusNode.requestFocus(); onTap(); },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: btnColors,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isWhite ? Colors.black : btnColors[1]).withOpacity(0.3),
                blurRadius: 8, offset: const Offset(0, 3),
              ),
              if (!isWhite) BoxShadow(
                color: btnColors[0].withOpacity(0.4),
                blurRadius: 12, spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.6), width: 1.5,
            ),
          ),
          child: Center(child: Text(emoji,
              style: const TextStyle(fontSize: 20))),
        ),
        if (label.isNotEmpty) ...[        
          const SizedBox(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: const TextStyle(
              color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ]),
    );
  }

  
  
  

  Widget _buildToast(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.4),
              blurRadius: 8, spreadRadius: 1),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('✨', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Flexible(child: Text(msg,
            style: const TextStyle(color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center)),
        const SizedBox(width: 6),
        const Text('✨', style: TextStyle(fontSize: 14)),
      ]),
    );
  }

  
  
  

  Widget _buildFishingOverlay(GameProvider gp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.lightBlue.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF29B6F6).withOpacity(0.4),
              blurRadius: 20, spreadRadius: 3),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎣 Đang câu cá...',
            style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${gp.fishingCountdown}s',
            style: const TextStyle(color: Colors.yellow, fontSize: 36,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 160,
          child: LinearProgressIndicator(
            value: 1 - (gp.fishingCountdown / GameConstants.fishingSeconds),
            backgroundColor: Colors.blue.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ]),
    );
  }

  
  
  

  void _openShop(BuildContext ctx, GameProvider gp) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ChangeNotifierProvider.value(value: gp, child: const ShopDialog()),
    );
  }

  void _openLeaderboard(BuildContext ctx, GameProvider gp) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ChangeNotifierProvider.value(value: gp, child: const LeaderboardDialog()),
    );
  }
}





class _DPadButton extends StatefulWidget {
  final Widget       child;
  final Color        color;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final VoidCallback onCancel;

  const _DPadButton({
    required this.child,
    required this.color,
    required this.onDown,
    required this.onUp,
    required this.onCancel,
  });

  @override
  State<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<_DPadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        widget.onDown();
        setState(() => _pressed = true);
      },
      onPointerUp: (_) {
        widget.onUp();
        setState(() => _pressed = false);
      },
      onPointerCancel: (_) {
        widget.onCancel();
        setState(() => _pressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width : 44,
        height: 44,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.95)
              : widget.color,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: _pressed ? Colors.white60 : Colors.white24,
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 4, offset: const Offset(0, 2))]
              : [BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 3, offset: const Offset(0, 1))],
        ),
        transform: _pressed
            ? (Matrix4.identity()..translate(0.0, 1.5))
            : Matrix4.identity(),
        child: Center(child: widget.child),
      ),
    );
  }
}
