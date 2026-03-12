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

// ================================================================
//  GAME SCREEN  v5
//  ✅ Fix #1 – Tile tap now uses Listener (bypasses gesture arena)
//              with screen-space delta to reject drag vs tap
//  ✅ Fix #2 – Virtual D-pad replaces keyboard-only hint;
//              Listener-based press/release → buttery 60fps movement
//  ✅ Audio   – D-pad interact button fires E-key logic
// ================================================================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Ticker _ticker;
  Duration _lastTick  = Duration.zero;
  bool     _firstTick = true;
  final TransformationController _camCtrl = TransformationController();
  final FocusNode _focusNode = FocusNode();
  Offset _pointerDownScreen = Offset.zero;
  bool _showAnimalPanel = false;
  bool _showQuestPanel = false;
  @override
  void initState() {
    super.initState();

    // Bật lắng nghe sự kiện vòng đời App (Để biết khi nào người dùng thoát app)
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gp = context.read<GameProvider>();
      bool loaded = await gp.tryLoadSavedGame();
      if (!loaded) await gp.startNewGame("Nông dân");
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

  // HÀM NÀY GIÚP AUTO-SAVE KHI BẠN VUỐT ẨN HOẶC ĐÓNG APP / TRÌNH DUYỆT
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      // Gọi hàm lưu dữ liệu lập tức khi thoát
      context.read<GameProvider>().saveGame();
    }
  }

  @override
  void dispose() {
    // Tắt lắng nghe khi thoát màn hình
    WidgetsBinding.instance.removeObserver(this);

    _ticker.dispose();
    _camCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Smooth camera follow ─────────────────────────────────────
  void _followPlayer() {
    final gp   = context.read<GameProvider>();
    final size = MediaQuery.of(context).size;
    final ts   = GameConstants.tileSize;

    final targetX = gp.playerCol * ts - size.width  / 2 + ts / 2;
    final targetY = gp.playerRow * ts - size.height / 2 + ts / 2;

    final maxX    = GameConstants.farmCols * ts - size.width;
    final maxY    = GameConstants.farmRows * ts - size.height;
    final cx      = targetX.clamp(0.0, maxX.clamp(0.0, double.infinity));
    final cy      = targetY.clamp(0.0, maxY.clamp(0.0, double.infinity));

    final cur  = _camCtrl.value.getTranslation();
    const lerp = 0.14;
    final nx   = cur.x + (-cx - cur.x) * lerp;
    final ny   = cur.y + (-cy - cur.y) * lerp;

    _camCtrl.value = Matrix4.identity()..translate(nx, ny);
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (ctx, gp, _) {
      if (gp.currentScene == GameScene.house) return const HouseScreen();

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

            // ① Farm view (pan/zoom) + Listener for tile taps
            _buildFarmView(gp),

            // ② Night overlay
            AnimatedOpacity(
              opacity : gp.isNight ? 0.72 : 0.0,
              duration: const Duration(milliseconds: 1200),
              child   : Container(color: const Color(0xFF000033)),
            ),

            // ③ HUD
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(child: HudWidget(gp: gp)),
            ),

            // ④ Toolbar
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ToolbarWidget(gp: gp),
            ),

            // ⑤ Action buttons (right)
            Positioned(
              bottom: 100, right: 12,
              child : _buildActionButtons(ctx, gp),
            ),

            // ⑥ Virtual D-pad (left)  ← replaces keyboard hint
            Positioned(
              bottom: 100, left: 12,
              child : _buildDPad(gp),
            ),

            // ⑦ Quest panel (toggleable, left side)
            if (_showQuestPanel)
              Positioned(
                top: 120,
                left: 0,
                child: QuestPanelWidget(
                  gp: gp,
                  onClose: () => setState(() => _showQuestPanel = false),
                ),
              ),

            // ⑦ Animal panel (toggleable)
            if (_showAnimalPanel)
              Positioned(
                top: 120,
                right: 0,
                child: AnimalPanelWidget(
                  gp: gp,
                  onClose: () => setState(() => _showAnimalPanel = false),
                ),
              )
            else
              Positioned(
                top: 128,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _showAnimalPanel = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.62),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('🐾', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 6),
                      Text('Vật nuôi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ),

            // ⑧ Toast (placed under HUD, avoids overlap)
            if (gp.showMessage)
              Positioned(
                top: 0, left: 20, right: 20,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 88),
                    child: _buildToast(gp.message),
                  ),
                ),
              ),

            // ⑨ Fishing overlay
            if (gp.isFishing)
              Positioned(top: 150, left: 0, right: 0,
                  child: _buildFishingOverlay(gp)),

          ]),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════
  // FARM VIEW  –  ✅ Listener replaces GestureDetector
  //   • Listener bypasses gesture arena → always receives events
  //   • Use SCREEN-space delta (e.position) to tell tap from drag
  //   • Use LOCAL-space position (e.localPosition) for tile index
  // ════════════════════════════════════════════════════════════

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
          // ── Track touch/mouse DOWN in screen space ──────────
          onPointerDown: (e) {
            _pointerDownScreen = e.position; // global screen coords
          },
          // ── On UP: if barely moved → it's a tap ─────────────
          onPointerUp: (e) {
            final screenDelta =
                (e.position - _pointerDownScreen).distance;

            // Allow up to 10 logical pixels of drift (finger wobble)
            if (screenDelta < 10.0) {
              _focusNode.requestFocus();
              // localPosition is already in scene (farm) coordinates
              final col = (e.localPosition.dx / GameConstants.tileSize).floor();
              final row = (e.localPosition.dy / GameConstants.tileSize).floor();
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // VIRTUAL D-PAD  –  ✅ Listener for zero-lag press/release
  //
  //   Layout:
  //       [ ↑ ]
  //   [←] [⚡] [→]     ⚡ = Interact (E key)
  //       [ ↓ ]
  // ════════════════════════════════════════════════════════════

  Widget _buildDPad(GameProvider gp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Up button
        Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 48),
          _dpadDir('↑', LogicalKeyboardKey.keyW, gp),
          const SizedBox(width: 48),
        ]),
        // Row 2: Left | Interact | Right
        Row(mainAxisSize: MainAxisSize.min, children: [
          _dpadDir('←', LogicalKeyboardKey.keyA, gp),
          _dpadAct('⚡', gp),
          _dpadDir('→', LogicalKeyboardKey.keyD, gp),
        ]),
        // Row 3: Down button
        Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 48),
          _dpadDir('↓', LogicalKeyboardKey.keyS, gp),
          const SizedBox(width: 48),
        ]),
      ],
    );
  }

  /// Direction button – holds key while finger is pressed
  Widget _dpadDir(String label, LogicalKeyboardKey key, GameProvider gp) {
    return _DPadButton(
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      color: Colors.black.withOpacity(0.58),
      onDown  : () => gp.handleKeyDown(key),
      onUp    : () => gp.handleKeyUp(key),
      onCancel: () => gp.handleKeyUp(key),
    );
  }

  /// Action (interact) button – fires E key on press
  Widget _dpadAct(String emoji, GameProvider gp) {
    return _DPadButton(
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
      color: Colors.amber.withOpacity(0.80),
      onDown  : () => gp.handleKeyDown(LogicalKeyboardKey.keyE),
      onUp    : () => gp.handleKeyUp(LogicalKeyboardKey.keyE),
      onCancel: () => gp.handleKeyUp(LogicalKeyboardKey.keyE),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ACTION BUTTONS (right side)
  // ════════════════════════════════════════════════════════════

  Widget _buildActionButtons(BuildContext ctx, GameProvider gp) {
    final size = MediaQuery.of(ctx).size;
    final narrow = size.width < 390;
    final btnSize = narrow ? 46.0 : 50.0;
    final emojiSize = narrow ? 20.0 : 22.0;
    final labelFont = narrow ? 9.0 : 10.0;

    // Prevent overflow on short screens
    final maxH = (size.height - 92 /*toolbar*/ - 120 /*top HUD zone*/)
        .clamp(240.0, size.height);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _fab('🏪', 'Shop', () => _openShop(ctx, gp),
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
            const SizedBox(height: 8),
            _fab('🏆', 'Hạng', () => _openLeaderboard(ctx, gp),
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
            const SizedBox(height: 8),
            _fab('💾', 'Lưu', () => gp.saveGame(),
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
            const SizedBox(height: 8),
            _fab('🌙', 'Ngủ', () => gp.goToSleep(),
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
            const SizedBox(height: 8),
            _fab('🐾', 'Nuôi', () => setState(() => _showAnimalPanel = !_showAnimalPanel),
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
            const SizedBox(height: 8),
            _fab('📋', 'NV', () => setState(() => _showQuestPanel = !_showQuestPanel),
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
            const SizedBox(height: 8),
            _fab(gp.audio.enabled ? '🔊' : '🔇', '',
                () {
                  gp.audio.setEnabled(!gp.audio.enabled);
                  setState(() {});
                },
                size: btnSize, emojiSize: emojiSize, labelFont: labelFont),
          ],
        ),
      ),
    );
  }

  Widget _fab(
    String emoji,
    String label,
    VoidCallback onTap, {
    double size = 50,
    double emojiSize = 22,
    double labelFont = 10,
  }) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
        onTap();
      },
      child: Column(children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFont,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  // TOAST
  // ════════════════════════════════════════════════════════════

  Widget _buildToast(String msg) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.82),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(msg,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            textAlign: TextAlign.center),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // FISHING OVERLAY
  // ════════════════════════════════════════════════════════════

  Widget _buildFishingOverlay(GameProvider gp) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1).withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
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
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DIALOGS
  // ════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════
// _DPadButton  –  reusable D-pad key widget
//   Uses Listener for zero-lag pointer events (no gesture arena)
// ════════════════════════════════════════════════════════════

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
      behavior: HitTestBehavior.opaque, // always receive events
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
