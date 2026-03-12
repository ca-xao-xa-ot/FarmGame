import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../models/game_models.dart';

/// Renders the entire farm: tiles, crops, pond, house, pen, animals, player.
/// Uses [RepaintBoundary] in GameScreen so only the canvas repaints each frame.
class FarmPainter extends CustomPainter {
  final List<List<TileModel>> tiles;
  final List<AnimalModel>     animals;
  final double                playerCol;
  final double                playerRow;
  final int                   playerDir;
  final bool                  isMoving;
  final ToolType              selectedTool;

  // Walk-cycle frame (simple 2-frame bob)
  static int _walkFrame = 0;
  static int _walkCounter = 0;

  FarmPainter({
    required this.tiles,
    required this.animals,
    required this.playerCol,
    required this.playerRow,
    required this.playerDir,
    required this.isMoving,
    required this.selectedTool,
  });

  static const double ts = GameConstants.tileSize;
  static const double _hr = ts / 2; // half tile

  @override
  void paint(Canvas canvas, Size size) {
    if (tiles.isEmpty) return;

    // Walk animation tick
    if (isMoving) {
      _walkCounter++;
      if (_walkCounter >= 8) { _walkCounter = 0; _walkFrame = 1 - _walkFrame; }
    } else {
      _walkFrame = 0; _walkCounter = 0;
    }

    // ── Draw all tiles ────────────────────────────────────────
    for (int r = 0; r < tiles.length; r++) {
      for (int c = 0; c < tiles[r].length; c++) {
        _drawTile(canvas, r, c, tiles[r][c]);
      }
    }

    // ── Special zones ────────────────────────────────────────
    _drawPond(canvas);
    _drawAnimalPen(canvas);
    _drawHouse(canvas);

    // ── Animals (drawn in pen) ────────────────────────────────
    for (final a in animals) _drawAnimal(canvas, a);

    // ── Player (always on top) ────────────────────────────────
    _drawPlayer(canvas);
  }

  // ──────────────────────────────────────────────────────────
  // TILE
  // ──────────────────────────────────────────────────────────
  void _drawTile(Canvas canvas, int r, int c, TileModel tile) {
    // Skip zones handled separately
    if (_isPond(r, c) || _inPen(r, c) || _isHouseZone(r, c)) return;

    final Rect rect = Rect.fromLTWH(c * ts, r * ts, ts, ts);
    final paint = Paint();

    switch (tile.state) {
      case TileState.grass:
        paint.color = ((r + c) % 2 == 0) ? const Color(0xFF7EC850) : const Color(0xFF76C248);
        canvas.drawRect(rect, paint);
        _drawGrassDecor(canvas, rect, r, c);
        break;
      case TileState.ground:
        paint.color = const Color(0xFF8B6914);
        canvas.drawRect(rect, paint);
        _drawSoilDots(canvas, rect);
        break;
      case TileState.planted:
        paint.color = const Color(0xFF6B4F1A);
        canvas.drawRect(rect, paint);
        _drawSoilDots(canvas, rect);
        _drawEmoji(canvas, rect, '🌱', ts * 0.38);
        break;
      case TileState.watered:
        paint.color = const Color(0xFF4A3010);
        canvas.drawRect(rect, paint);
        _drawWaterSheen(canvas, rect);
        _drawEmoji(canvas, rect, '🌱', ts * 0.40);
        break;
      case TileState.growing:
        paint.color = const Color(0xFF5A4520);
        canvas.drawRect(rect, paint);
        _drawEmoji(canvas, rect, '🌿', ts * 0.46);
        break;
      case TileState.ready:
        paint.color = const Color(0xFF6B5025);
        canvas.drawRect(rect, paint);
        _drawEmoji(canvas, rect, tile.cropType?.emoji ?? '🌾', ts * 0.56);
        _drawSparkle(canvas, rect);
        break;
    }

    // Thin grid line
    canvas.drawRect(rect, Paint()
      ..color = Colors.black.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4);
  }

  void _drawGrassDecor(Canvas canvas, Rect rect, int r, int c) {
    if ((r * 7 + c * 3) % 6 == 0) {
      _drawEmoji(canvas, rect.deflate(8), '🌿', ts * 0.28);
    }
  }

  void _drawSoilDots(Canvas canvas, Rect rect) {
    final p = Paint()..color = Colors.black.withOpacity(0.18);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(rect.left + ts * (0.2 + i * 0.3), rect.top + ts * (0.2 + j * 0.3)),
          1.5, p,
        );
      }
    }
  }

  void _drawWaterSheen(Canvas canvas, Rect rect) {
    final p = Paint()..color = const Color(0xFF64B5F6).withOpacity(0.5);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(rect.left + ts * (0.15 + i * 0.22), rect.top + ts * 0.14),
        2.0, p,
      );
    }
  }

  void _drawSparkle(Canvas canvas, Rect rect) {
    final p = Paint()..color = const Color(0xFFFFD700).withOpacity(0.9);
    canvas.drawCircle(Offset(rect.right - ts * 0.14, rect.top + ts * 0.14), 4.5, p);
    // Cross sparkle lines
    final lp = Paint()..color = const Color(0xFFFFD700).withOpacity(0.6)..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(rect.right - ts * 0.14, rect.top + ts * 0.06),
      Offset(rect.right - ts * 0.14, rect.top + ts * 0.22),
      lp,
    );
    canvas.drawLine(
      Offset(rect.right - ts * 0.22, rect.top + ts * 0.14),
      Offset(rect.right - ts * 0.06, rect.top + ts * 0.14),
      lp,
    );
  }

  // ──────────────────────────────────────────────────────────
  // POND
  // ──────────────────────────────────────────────────────────
  void _drawPond(Canvas canvas) {
    final left = GameConstants.pondX * ts;
    final top  = GameConstants.pondY * ts;
    final w    = GameConstants.pondW * ts;
    final h    = GameConstants.pondH * ts;
    final rect = Rect.fromLTWH(left, top, w, h);

    // Water gradient
    canvas.drawRRect(
      RRect.fromRectXY(rect, 20, 20),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFF42A5F5), const Color(0xFF0D47A1)],
      ).createShader(rect),
    );

    // Ripples
    final rp = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: rect.center, width: w * 0.45, height: h * 0.28), rp,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rect.center, width: w * 0.25, height: h * 0.15), rp,
    );

    _drawEmoji(canvas, rect, '🎣', 28);
  }

  // ──────────────────────────────────────────────────────────
  // ANIMAL PEN
  // ──────────────────────────────────────────────────────────
  void _drawAnimalPen(Canvas canvas) {
    final left = GameConstants.penX * ts;
    final top  = GameConstants.penY * ts;
    final w    = GameConstants.penW * ts;
    final h    = GameConstants.penH * ts;
    final rect = Rect.fromLTWH(left, top, w, h);

    // Ground
    canvas.drawRect(rect, Paint()..color = const Color(0xFFF5DEB3));

    // Hay patches
    final hayP = Paint()..color = const Color(0xFFDEB887).withOpacity(0.5);
    canvas.drawCircle(Offset(left + w * 0.3, top + h * 0.6), 14, hayP);
    canvas.drawCircle(Offset(left + w * 0.7, top + h * 0.4), 10, hayP);

    // Fence
    final fenceP = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect.inflate(1.5), fenceP);

    // Fence posts & rails
    final postP = Paint()..color = const Color(0xFF5D4037);
    for (double x = left; x <= left + w; x += ts) {
      _drawPost(canvas, x, top - 5, postP);
      _drawPost(canvas, x, top + h - 5, postP);
    }
    for (double y = top; y <= top + h; y += ts) {
      _drawPost(canvas, left - 5, y, postP);
      _drawPost(canvas, left + w - 5, y, postP);
    }
  }

  void _drawPost(Canvas canvas, double x, double y, Paint p) {
    canvas.drawRect(Rect.fromLTWH(x, y, 7, 12), p);
  }

  // ──────────────────────────────────────────────────────────
  // HOUSE
  // ──────────────────────────────────────────────────────────
  void _drawHouse(Canvas canvas) {
    final left = (GameConstants.houseCol - 1) * ts;
    final top  = (GameConstants.houseRow - 2) * ts - 8;
    const w    = ts * 3.2;
    const h    = ts * 2.8;

    // Body
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(left, top + ts * 0.5, w, h * 0.8), 5, 5),
      Paint()..color = const Color(0xFFFFCCBC),
    );

    // Roof
    final roof = Path()
      ..moveTo(left - ts * 0.15, top + ts * 0.5)
      ..lineTo(left + w / 2,     top)
      ..lineTo(left + w + ts * 0.15, top + ts * 0.5)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFB71C1C));
    canvas.drawPath(roof, Paint()
      ..color = const Color(0xFF8B0000).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Left window
    _drawWindow(canvas, left + ts * 0.25, top + ts * 0.7);
    // Right window
    _drawWindow(canvas, left + w - ts * 1.0, top + ts * 0.7);

    // Door
    canvas.drawRRect(
      RRect.fromRectXY(
        Rect.fromLTWH(left + w / 2 - ts * 0.28, top + ts * 0.5 + h * 0.38, ts * 0.58, h * 0.42),
        4, 4,
      ),
      Paint()..color = const Color(0xFF795548),
    );
    // Door knob
    canvas.drawCircle(
      Offset(left + w / 2 + ts * 0.18, top + ts * 0.5 + h * 0.62),
      3, Paint()..color = const Color(0xFFFFD700),
    );

    // 🏠 label
    _drawEmojiAt(canvas, left + w / 2, top - 14, '🏠', 16);
  }

  void _drawWindow(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(x, y, ts * 0.65, ts * 0.5), 3, 3),
      Paint()..color = const Color(0xFF90CAF9),
    );
    // Cross
    final lp = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 1;
    canvas.drawLine(Offset(x + ts * 0.325, y), Offset(x + ts * 0.325, y + ts * 0.5), lp);
    canvas.drawLine(Offset(x, y + ts * 0.25), Offset(x + ts * 0.65, y + ts * 0.25), lp);
  }

  // ──────────────────────────────────────────────────────────
  // ANIMAL
  // ──────────────────────────────────────────────────────────
  void _drawAnimal(Canvas canvas, AnimalModel a) {
    final x    = a.posX * ts;
    final y    = a.posY * ts;
    final size = a.state == AnimalState.baby ? ts * 0.42 : ts * 0.58;
    final em   = a.state == AnimalState.baby ? a.type.babyEmoji : a.type.emoji;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + size * 0.55), width: size * 0.7, height: size * 0.2),
      Paint()..color = Colors.black.withOpacity(0.18),
    );

    _drawEmojiAt(canvas, x - size / 2, y - size / 2, em, size);

    // Fed indicator
    if (a.isFed) _drawEmojiAt(canvas, x + size * 0.2, y - size * 0.9, '✅', 11);
    // Produce ready
    if (a.canProduce()) {
      final prodEm = (a.type == AnimalType.chicken || a.type == AnimalType.duck)
          ? '🥚'
          : (a.type == AnimalType.cow ? '🥛' : '🥩');
      _drawEmojiAt(canvas, x - 8, y - size - 4, prodEm, 16);
    }
  }

  // ──────────────────────────────────────────────────────────
  // PLAYER  (with simple walk bob)
  // ──────────────────────────────────────────────────────────
  void _drawPlayer(Canvas canvas) {
    final cx  = playerCol * ts + _hr;
    final cy  = playerRow * ts + _hr;
    final bob = isMoving ? (_walkFrame == 0 ? -2.5 : 2.0) : 0.0;
    final size = ts * 0.76;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, playerRow * ts + ts * 0.88),
        width: size * 0.55, height: size * 0.18,
      ),
      Paint()..color = Colors.black.withOpacity(0.22),
    );

    // Player sprite
    _drawEmojiAt(canvas, cx - size / 2, cy - size / 2 + bob, '🧑‍🌾', size);

    // Tool badge (top-right)
    _drawEmojiAt(canvas, cx + size * 0.22, cy - size * 0.62 + bob, _toolEmoji(), 15);
  }

  String _toolEmoji() => selectedTool.emoji;

  // ──────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────
  void _drawEmoji(Canvas canvas, Rect rect, String emoji, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(
      rect.center.dx - tp.width  / 2,
      rect.center.dy - tp.height / 2,
    ));
  }

  void _drawEmojiAt(Canvas canvas, double x, double y, String emoji, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  bool _isPond(int r, int c) =>
      c >= GameConstants.pondX && c < GameConstants.pondX + GameConstants.pondW &&
          r >= GameConstants.pondY && r < GameConstants.pondY + GameConstants.pondH;
  bool _inPen(int r, int c) =>
      c >= GameConstants.penX  && c < GameConstants.penX  + GameConstants.penW &&
          r >= GameConstants.penY  && r < GameConstants.penY  + GameConstants.penH;
  bool _isHouseZone(int r, int c) => c >= 15 && c <= 17 && r >= 7 && r <= 10;

  @override
  bool shouldRepaint(covariant FarmPainter old) => true; // Ticker drives repaints
}
