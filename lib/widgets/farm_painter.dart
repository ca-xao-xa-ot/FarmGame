









import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../models/game_models.dart';

class FarmPainter extends CustomPainter {
  final List<List<TileModel>> tiles;
  final List<AnimalModel>     animals;
  final double                playerCol;
  final double                playerRow;
  final int                   playerDir;
  final bool                  isMoving;
  final ToolType              selectedTool;
  final Map<String, double>   hoeProgress;

  static int _walkFrame   = 0;
  static int _walkCounter = 0;

  FarmPainter({
    required this.tiles,
    required this.animals,
    required this.playerCol,
    required this.playerRow,
    required this.playerDir,
    required this.isMoving,
    required this.selectedTool,
    required this.hoeProgress,
  });

  static const double ts  = GameConstants.tileSize;
  static const double _hr = ts / 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (tiles.isEmpty) return;

    if (isMoving) {
      _walkCounter++;
      if (_walkCounter >= 8) { _walkCounter = 0; _walkFrame = 1 - _walkFrame; }
    } else {
      _walkFrame = 0; _walkCounter = 0;
    }

    
    for (int r = 0; r < tiles.length; r++) {
      for (int c = 0; c < tiles[r].length; c++) {
        _drawTile(canvas, r, c, tiles[r][c]);
      }
    }

    
    _drawFarmBorder(canvas);

    
    _drawPond(canvas);
    _drawAnimalPen(canvas);
    _drawHouse(canvas);
    _drawWindmill(canvas);
    _drawBigTree(canvas);

    
    for (final a in animals) _drawAnimal(canvas, a);

    
    _drawPlayer(canvas);
  }

  
  
  
  void _drawTile(Canvas canvas, int r, int c, TileModel tile) {
    if (_isPond(r, c) || _inPen(r, c) || _isHouseZone(r, c)) return;

    final Rect rect = Rect.fromLTWH(c * ts, r * ts, ts, ts);
    final paint = Paint();
    final key = '$r,$c';
    final hoeP = hoeProgress[key];

    if (hoeP != null) {
      paint.color = ((r + c) % 2 == 0) ? const Color(0xFF7EC850) : const Color(0xFF76C248);
      canvas.drawRect(rect, paint);
      final dirtAlpha = (hoeP * 255).round().clamp(0, 255);
      paint.color = Color.fromARGB(dirtAlpha, 0x8B, 0x69, 0x14);
      canvas.drawRect(rect, paint);
      _drawHoeParticles(canvas, rect, hoeP);
      if (hoeP > 0.5) _drawEmojiAt(canvas, rect.center.dx - 10, rect.top - 14, '💦', 13);
      canvas.drawRect(rect, Paint()
        ..color = Colors.black.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4);
      return;
    }

    switch (tile.state) {
      case TileState.grass:
        
        final isLight = (r + c) % 2 == 0;
        paint.color = isLight ? const Color(0xFF7EC850) : const Color(0xFF76C248);
        canvas.drawRect(rect, paint);
        _drawGrassDecor(canvas, rect, r, c);
        break;

      case TileState.ground:
        paint.color = const Color(0xFF8B6914);
        canvas.drawRect(rect, paint);
        _drawSoilPattern(canvas, rect);
        break;

      case TileState.planted:
        paint.color = const Color(0xFF6B4F1A);
        canvas.drawRect(rect, paint);
        _drawSoilPattern(canvas, rect);
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
        _drawEmoji(canvas, rect, tile.cropType?.emoji ?? '🌾', ts * 0.58);
        _drawSparkle(canvas, rect);
        break;
    }

    canvas.drawRect(rect, Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4);
  }

  void _drawGrassDecor(Canvas canvas, Rect rect, int r, int c) {
    
    if ((r * 7 + c * 3) % 7 == 0) {
      _drawEmoji(canvas, rect.deflate(8), '🌿', ts * 0.26);
    }
    if ((r * 3 + c * 11) % 13 == 0) {
      _drawEmoji(canvas, rect.deflate(10), '🌸', ts * 0.20);
    }
    if ((r * 5 + c * 7) % 17 == 0) {
      _drawEmoji(canvas, rect.deflate(6), '🍄', ts * 0.22);
    }
    if ((r * 11 + c * 5) % 22 == 0) {
      _drawEmoji(canvas, rect.deflate(9), '🌼', ts * 0.18);
    }
    if ((r * 13 + c * 2) % 29 == 0) {
      _drawEmoji(canvas, rect.deflate(8), '🦋', ts * 0.20);
    }
  }

  void _drawSoilPattern(Canvas canvas, Rect rect) {
    final pDark  = Paint()..color = Colors.black.withOpacity(0.14);
    final pLight = Paint()..color = Colors.white.withOpacity(0.08);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final ox = rect.left + ts * (0.15 + i * 0.23);
        final oy = rect.top  + ts * (0.15 + j * 0.23);
        canvas.drawCircle(Offset(ox, oy), 1.6, pDark);
        canvas.drawCircle(Offset(ox + 3, oy + 2), 0.8, pLight);
      }
    }
  }

  void _drawWaterSheen(Canvas canvas, Rect rect) {
    final p = Paint()..color = const Color(0xFF64B5F6).withOpacity(0.45);
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(rect.left + ts * (0.12 + i * 0.18), rect.top + ts * 0.12), 2.2, p,
      );
    }
    final lp = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(rect.left + ts * 0.1, rect.top + ts * 0.25),
      Offset(rect.right - ts * 0.1, rect.top + ts * 0.25), lp,
    );
  }

  void _drawSparkle(Canvas canvas, Rect rect) {
    final p  = Paint()..color = const Color(0xFFFFD700).withOpacity(0.9);
    final lp = Paint()..color = const Color(0xFFFFD700).withOpacity(0.6)..strokeWidth = 1.5;
    canvas.drawCircle(Offset(rect.right - ts * 0.14, rect.top + ts * 0.14), 4.5, p);
    canvas.drawLine(
      Offset(rect.right - ts * 0.14, rect.top + ts * 0.06),
      Offset(rect.right - ts * 0.14, rect.top + ts * 0.22), lp,
    );
    canvas.drawLine(
      Offset(rect.right - ts * 0.22, rect.top + ts * 0.14),
      Offset(rect.right - ts * 0.06, rect.top + ts * 0.14), lp,
    );
  }

  void _drawHoeParticles(Canvas canvas, Rect rect, double progress) {
    final rng2 = _StableRng(rect.left.toInt() * 31 + rect.top.toInt() * 17);
    final count = (progress * 8).ceil();
    for (int i = 0; i < count; i++) {
      final angle = rng2.nextDouble() * 6.28;
      final dist  = progress * ts * 0.38 * rng2.nextDouble();
      final px    = rect.center.dx + dist * _cos(angle);
      final py    = rect.center.dy + dist * _sin(angle) * 0.6;
      final sz    = (4.0 + rng2.nextDouble() * 5.0) * (1 - progress * 0.5);
      canvas.drawCircle(
        Offset(px, py), sz,
        Paint()..color = const Color(0xFF8B6914).withOpacity((1 - progress) * 0.9),
      );
    }
  }

  
  
  
  void _drawFarmBorder(Canvas canvas) {
    final farmW = GameConstants.farmCols * ts;
    final farmH = GameConstants.farmRows * ts;

    
    final flowerEmojis = ['🌸', '🌼', '🌺', '🌻', '🌷', '🌹'];
    for (int c = 0; c < GameConstants.farmCols; c++) {
      final emoji = flowerEmojis[c % flowerEmojis.length];
      _drawEmojiAt(canvas, c * ts + ts * 0.1, -ts * 0.3, emoji, ts * 0.38);
    }

    
    for (int r = 0; r < GameConstants.farmRows; r++) {
      final emoji = flowerEmojis[(r + 2) % flowerEmojis.length];
      _drawEmojiAt(canvas, -ts * 0.4, r * ts + ts * 0.1, emoji, ts * 0.34);
    }

    
    final pathP = Paint()..color = const Color(0xFFBCAAA4).withOpacity(0.6);
    final pathDarkP = Paint()..color = const Color(0xFF8D6E63).withOpacity(0.3);
    for (int r = 2; r < GameConstants.farmRows - 2; r++) {
      if (!_inPen(r, 10) && !_isPond(r, 10) && !_isHouseZone(r, 10)) {
        final rect = Rect.fromLTWH(10 * ts + ts * 0.1, r * ts + ts * 0.1,
            ts * 0.8, ts * 0.8);
        canvas.drawRRect(RRect.fromRectXY(rect, 4, 4), pathP);
        canvas.drawRRect(RRect.fromRectXY(rect, 4, 4), pathDarkP..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }

    
    _drawRainbow(canvas, farmW * 0.55, -ts * 1.5, farmW * 0.42);
  }

  void _drawRainbow(Canvas canvas, double cx, double top, double radius) {
    final rainbowColors = [
      const Color(0xFFFF5252).withOpacity(0.55),
      const Color(0xFFFF9800).withOpacity(0.50),
      const Color(0xFFFFEB3B).withOpacity(0.50),
      const Color(0xFF4CAF50).withOpacity(0.45),
      const Color(0xFF29B6F6).withOpacity(0.45),
      const Color(0xFF7E57C2).withOpacity(0.40),
    ];
    for (int i = 0; i < rainbowColors.length; i++) {
      final r = radius - i * 7.0;
      if (r <= 0) continue;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, top + r), width: r * 2, height: r * 2),
        3.1416, 3.1416, false,
        Paint()
          ..color = rainbowColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5,
      );
    }
  }

  
  
  
  void _drawWindmill(Canvas canvas) {
    
    final cx = 3.5 * ts;
    final cy = 1.5 * ts;

    
    final towerP = Paint()..color = const Color(0xFFD7CCC8);
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromCenter(center: Offset(cx, cy + ts * 0.4), width: 10, height: ts * 0.8), 3, 3),
      towerP,
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(cx - 4, cy + ts * 0.3, 8, 12), 2, 2),
      Paint()..color = const Color(0xFF8D6E63),
    );

    
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = const Color(0xFFBCAAA4));
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFF8D6E63));

    
    final bladeP = Paint()..color = const Color(0xFFF5F5F5).withOpacity(0.9);
    final bladeDark = Paint()..color = const Color(0xFFE0E0E0).withOpacity(0.8);
    for (int i = 0; i < 4; i++) {
      final angle = i * 1.5708; 
      final bx = cx + _cos(angle) * 18;
      final by = cy + _sin(angle) * 18;
      canvas.drawRRect(
        RRect.fromRectXY(
          Rect.fromCenter(center: Offset(bx, by), width: 8, height: 22),
          3, 3,
        ),
        i % 2 == 0 ? bladeP : bladeDark,
      );
    }
    
    canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = const Color(0xFF5D4037));

    
    _drawEmojiAt(canvas, cx - 8, cy - ts * 1.1, '🌬️', 12);
  }

  
  
  
  void _drawBigTree(Canvas canvas) {
    
    final cx = 7.5 * ts;
    final cy = 0.8 * ts;

    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromCenter(center: Offset(cx, cy + ts * 0.6), width: 14, height: ts), 4, 4),
      Paint()..color = const Color(0xFF795548),
    );

    
    
    canvas.drawCircle(Offset(cx, cy + ts * 0.1), ts * 0.65,
      Paint()..color = const Color(0xFF388E3C).withOpacity(0.9));
    
    canvas.drawCircle(Offset(cx - ts * 0.1, cy - ts * 0.2), ts * 0.52,
      Paint()..color = const Color(0xFF43A047).withOpacity(0.95));
    
    canvas.drawCircle(Offset(cx + ts * 0.08, cy - ts * 0.45), ts * 0.38,
      Paint()..color = const Color(0xFF66BB6A));

    
    canvas.drawCircle(Offset(cx - ts * 0.12, cy - ts * 0.5), ts * 0.18,
      Paint()..color = const Color(0xFF81C784).withOpacity(0.6));

    
    _drawEmojiAt(canvas, cx - 6, cy - ts * 0.8, '🌸', 12);
    _drawEmojiAt(canvas, cx + 8, cy - ts * 0.3, '🍎', 11);
  }

  
  
  
  void _drawPond(Canvas canvas) {
    final left = GameConstants.pondX * ts;
    final top  = GameConstants.pondY * ts;
    final w    = GameConstants.pondW * ts;
    final h    = GameConstants.pondH * ts;
    final rect = Rect.fromLTWH(left, top, w, h);

    
    canvas.drawRRect(
      RRect.fromRectXY(rect, 24, 24),
      Paint()..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)],
      ).createShader(rect),
    );

    
    canvas.drawRRect(
      RRect.fromRectXY(rect, 24, 24),
      Paint()
        ..color = const Color(0xFF81C784).withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    
    final lpP = Paint()..color = const Color(0xFF388E3C).withOpacity(0.75);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(left + w * 0.25, top + h * 0.3), width: 18, height: 11), lpP);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(left + w * 0.72, top + h * 0.7), width: 16, height: 10), lpP);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(left + w * 0.55, top + h * 0.2), width: 12, height: 8), lpP);

    
    final rp = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(Rect.fromCenter(center: rect.center, width: w * 0.48, height: h * 0.3), rp);
    canvas.drawOval(Rect.fromCenter(center: rect.center, width: w * 0.28, height: h * 0.16), rp);

    
    _drawEmojiAt(canvas, left + w * 0.15, top + h * 0.25, '🐟', 12);
    _drawEmojiAt(canvas, left + w * 0.55, top + h * 0.5, '🐠', 10);
    _drawEmoji(canvas, rect, '🎣', 26);
  }

  
  
  
  void _drawAnimalPen(Canvas canvas) {
    final left = GameConstants.penX * ts;
    final top  = GameConstants.penY * ts;
    final w    = GameConstants.penW * ts;
    final h    = GameConstants.penH * ts;
    final rect = Rect.fromLTWH(left, top, w, h);

    
    canvas.drawRect(rect, Paint()..color = const Color(0xFFF5DEB3));

    
    final texP = Paint()..color = const Color(0xFFDEB887).withOpacity(0.4);
    for (double gx = left; gx < left + w; gx += 18) {
      for (double gy = top; gy < top + h; gy += 18) {
        canvas.drawCircle(Offset(gx + 6, gy + 6), 4, texP);
      }
    }

    
    final hayP = Paint()..color = const Color(0xFFDEB887).withOpacity(0.6);
    canvas.drawCircle(Offset(left + w * 0.25, top + h * 0.65), 18, hayP);
    canvas.drawCircle(Offset(left + w * 0.72, top + h * 0.35), 13, hayP);
    canvas.drawCircle(Offset(left + w * 0.5,  top + h * 0.80), 10, hayP);

    
    final tP = Paint()..color = const Color(0xFF90CAF9).withOpacity(0.75);
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(left + w * 0.28, top + h * 0.84, w * 0.44, h * 0.11), 5, 5),
      tP,
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(left + w * 0.28, top + h * 0.84, w * 0.44, h * 0.11), 5, 5),
      Paint()..color = const Color(0xFF795548).withOpacity(0.5)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    
    final fenceP = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect.inflate(2.0), fenceP);

    
    final postP = Paint()..color = const Color(0xFF4E342E);
    for (double x = left; x <= left + w + 1; x += ts) {
      _drawPost(canvas, x, top - 6, postP);
      _drawPost(canvas, x, top + h - 5, postP);
    }
    for (double y = top; y <= top + h + 1; y += ts) {
      _drawPost(canvas, left - 6, y, postP);
      _drawPost(canvas, left + w - 5, y, postP);
    }

    
    _drawEmojiAt(canvas, left + 3, top + 3, '🐾', 14);

    
    _drawEmojiAt(canvas, left + w * 0.42, top - 18, '🌻', 18);
  }

  void _drawPost(Canvas canvas, double x, double y, Paint p) {
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(x, y, 8, 13), 2, 2), p);
  }

  
  
  
  void _drawHouse(Canvas canvas) {
    final left = (GameConstants.houseCol - 1) * ts;
    final top  = (GameConstants.houseRow - 2) * ts - 8;
    const w    = ts * 3.2;
    const h    = ts * 2.8;

    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(left + 6, top + ts * 0.5 + 6, w, h * 0.8), 6, 6),
      Paint()..color = Colors.black.withOpacity(0.10),
    );

    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(left, top + ts * 0.5, w, h * 0.8), 8, 8),
      Paint()..color = const Color(0xFFFFCCBC),
    );

    
    final wallP = Paint()..color = const Color(0xFFBCAAA4).withOpacity(0.2)..strokeWidth = 0.8;
    for (double y = top + ts * 0.65; y < top + ts * 0.5 + h * 0.8; y += 14) {
      canvas.drawLine(Offset(left, y), Offset(left + w, y), wallP);
    }

    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(left + w * 0.74, top - 10, 15, ts * 0.65), 3, 3),
      Paint()..color = const Color(0xFF8D6E63),
    );
    
    canvas.drawRect(
      Rect.fromLTWH(left + w * 0.70, top - 14, 23, 6),
      Paint()..color = const Color(0xFF5D4037),
    );
    _drawEmojiAt(canvas, left + w * 0.72, top - 28, '💨', 13);

    
    final roof = Path()
      ..moveTo(left - ts * 0.18, top + ts * 0.5)
      ..lineTo(left + w / 2,     top - 2)
      ..lineTo(left + w + ts * 0.18, top + ts * 0.5)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFB71C1C));
    
    final roofShade = Path()
      ..moveTo(left - ts * 0.18, top + ts * 0.5)
      ..lineTo(left + w / 2,     top - 2)
      ..lineTo(left + w / 2 + 5, top + 4)
      ..lineTo(left + 6,         top + ts * 0.5)
      ..close();
    canvas.drawPath(roofShade, Paint()..color = Colors.black.withOpacity(0.06));
    
    canvas.drawPath(roof, Paint()
      ..color = const Color(0xFF7B0000).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    
    final tileP = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(
        Offset(left + w * 0.12 * i, top + ts * 0.12),
        Offset(left + w / 2, top - 2),
        tileP,
      );
    }

    
    _drawWindow(canvas, left + ts * 0.22, top + ts * 0.70);
    _drawWindow(canvas, left + w - ts * 1.05, top + ts * 0.70);

    
    canvas.drawRRect(
      RRect.fromRectXY(
        Rect.fromLTWH(left + w / 2 - ts * 0.30, top + ts * 0.5 + h * 0.37, ts * 0.60, h * 0.43),
        5, 5,
      ),
      Paint()..color = const Color(0xFF795548),
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(
        Rect.fromLTWH(left + w / 2 - ts * 0.24, top + ts * 0.5 + h * 0.41, ts * 0.22, h * 0.16),
        2, 2,
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawRRect(
      RRect.fromRectXY(
        Rect.fromLTWH(left + w / 2 + ts * 0.02, top + ts * 0.5 + h * 0.41, ts * 0.22, h * 0.16),
        2, 2,
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    
    canvas.drawCircle(
      Offset(left + w / 2 + ts * 0.20, top + ts * 0.5 + h * 0.62),
      3.5, Paint()..color = const Color(0xFFFFD700),
    );

    
    _drawEmojiAt(canvas, left + w / 2 - ts * 0.55, top + ts * 0.5 + h * 0.55, '🌺', 14);
    _drawEmojiAt(canvas, left + w / 2 + ts * 0.30, top + ts * 0.5 + h * 0.55, '🌷', 14);

    
    _drawEmojiAt(canvas, left + w / 2 - 10, top - 28, '🏠', 18);
  }

  void _drawWindow(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(x, y, ts * 0.68, ts * 0.52), 5, 5),
      Paint()..color = const Color(0xFF90CAF9),
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(x - 3, y + ts * 0.52, ts * 0.74, 5), 2, 2),
      Paint()..color = const Color(0xFFBCAAA4),
    );
    
    final lp = Paint()..color = Colors.white.withOpacity(0.65)..strokeWidth = 1.5;
    canvas.drawLine(Offset(x + ts * 0.34, y), Offset(x + ts * 0.34, y + ts * 0.52), lp);
    canvas.drawLine(Offset(x, y + ts * 0.26), Offset(x + ts * 0.68, y + ts * 0.26), lp);
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(x, y, ts * 0.68, ts * 0.52), 5, 5),
      Paint()..color = Colors.white.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(x + 3, y + 3, ts * 0.14, ts * 0.14), 2, 2),
      Paint()..color = Colors.white.withOpacity(0.75),
    );
  }

  
  
  
  void _drawAnimal(Canvas canvas, AnimalModel a) {
    final x    = a.posX * ts;
    final y    = a.posY * ts;
    final size = a.state == AnimalState.baby ? ts * 0.42 : ts * 0.58;
    final em   = a.state == AnimalState.baby ? a.type.babyEmoji : a.type.emoji;

    
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + size * 0.55), width: size * 0.68, height: size * 0.2),
      Paint()..color = Colors.black.withOpacity(0.16),
    );

    _drawEmojiAt(canvas, x - size / 2, y - size / 2, em, size);

    
    if (a.isFed) _drawEmojiAt(canvas, x + size * 0.2, y - size * 0.9, '✅', 11);

    
    if (a.canProduce()) {
      String prodEm;
      switch (a.type) {
        case AnimalType.chicken:
        case AnimalType.duck:     prodEm = '🥚'; break;
        case AnimalType.turkey:   prodEm = '🥚'; break;
        case AnimalType.cow:      prodEm = '🥛'; break;
        case AnimalType.horse:    prodEm = '🥛'; break;
        case AnimalType.sheep:    prodEm = '🧶'; break;
        case AnimalType.rabbit:   prodEm = '🪶'; break;
        case AnimalType.bee:      prodEm = '🍯'; break;
        case AnimalType.peacock:  prodEm = '🪶'; break;
        default:                  prodEm = '🎁'; break;
      }
      _drawEmojiAt(canvas, x - 8, y - size - 6, prodEm, 18);

      
      canvas.drawCircle(
        Offset(x, y - size - 2), 14,
        Paint()..color = const Color(0xFFFFD700).withOpacity(0.25),
      );
    }
  }

  
  
  
  void _drawPlayer(Canvas canvas) {
    final cx   = playerCol * ts + _hr;
    final cy   = playerRow * ts + _hr;
    final bob  = isMoving ? (_walkFrame == 0 ? -2.8 : 2.2) : 0.0;
    final size = ts * 0.80;

    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, playerRow * ts + ts * 0.92),
        width: size * 0.52, height: size * 0.16,
      ),
      Paint()..color = Colors.black.withOpacity(0.20),
    );

    
    if (!isMoving) {
      canvas.drawCircle(
        Offset(cx, cy + bob),
        size * 0.55,
        Paint()..color = const Color(0xFFF48FB1).withOpacity(0.15),
      );
    }

    
    _drawEmojiAt(canvas, cx - size / 2, cy - size / 2 + bob, '👩‍🌾', size);

    
    _drawEmojiAt(canvas, cx + size * 0.14, cy - size * 0.78 + bob, '🌸', 13);

    
    _drawEmojiAt(canvas, cx + size * 0.30, cy - size * 0.30 + bob, selectedTool.emoji, 16);

    
    if (isMoving && _walkFrame == 0) {
      _drawEmojiAt(canvas, cx - size * 0.4, cy + size * 0.2 + bob, '✨', 10);
    }

    
    if (!isMoving) {
      _drawEmojiAt(canvas, cx - size * 0.5, cy - size * 0.85 + bob, '💕', 12);
    }
  }

  
  
  
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

  double _cos(double a) {
    final t = a % 6.2832;
    if (t < 1.5708) return 1.0 - (t / 1.5708);
    if (t < 3.1416) return -(t - 1.5708) / 1.5708;
    if (t < 4.7124) return -1.0 + (t - 3.1416) / 1.5708;
    return (t - 4.7124) / 1.5708;
  }

  double _sin(double a) {
    final t = a % 6.2832;
    if (t < 1.5708) return t / 1.5708;
    if (t < 3.1416) return (3.1416 - t) / 1.5708;
    if (t < 4.7124) return -((t - 3.1416) / 1.5708);
    return -((6.2832 - t) / 1.5708);
  }

  bool _isPond(int r, int c) =>
      c >= GameConstants.pondX && c < GameConstants.pondX + GameConstants.pondW &&
      r >= GameConstants.pondY && r < GameConstants.pondY + GameConstants.pondH;
  bool _inPen(int r, int c) =>
      c >= GameConstants.penX  && c < GameConstants.penX  + GameConstants.penW &&
      r >= GameConstants.penY  && r < GameConstants.penY  + GameConstants.penH;
  bool _isHouseZone(int r, int c) => c >= 15 && c <= 17 && r >= 7 && r <= 10;

  @override
  bool shouldRepaint(covariant FarmPainter old) => true;
}

class _StableRng {
  int _seed;
  _StableRng(this._seed);
  double nextDouble() {
    _seed = (_seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (_seed & 0x7FFFFFFF) / 0x7FFFFFFF;
  }
}
