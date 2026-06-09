import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// ElementIcon — assets/images/elements/ PNG 사용
// 한국어 속성명 → 파일명 매핑 후 Image.asset 로드
// 파일 없을 시 CustomPainter 폴백
// ─────────────────────────────────────────────────────────────
class ElementIcon extends StatelessWidget {
  final String element;
  final double size;

  const ElementIcon({required this.element, this.size = 20, super.key});

  // 속성 이름 → PNG 파일 스템 매핑
  static const Map<String, String> _elemToFile = {
    '불':   'fire',
    '화염': 'fire',
    '물':   'water',
    '번개': 'lightning',
    '전기': 'lightning',
    '광물': 'metal',
    '철':   'metal',
    '자연': 'grass',
    '꽃':   'grass',
    '풀':   'grass',
    '그림자': 'dark',
    '암흑': 'dark',
    '어둠': 'dark',
    '전설': 'rainbow',
    '영혼': 'normal',
    '노말': 'normal',
    '광명': 'light',
    '신성': 'light',
    '빛':   'light',
    '구름': 'cloud',
    '바람': 'wind',
    '폭풍': 'wind',
    '얼음': 'ice',
    '냉기': 'ice',
    '흙':   'earth',
    '모래': 'earth',
    '독':   'poison',
    '요정': 'fairy',
    '마법': 'fairy',
    '혼돈': 'fairy',
    '우주': 'dark',
  };

  String? get _assetPath {
    final file = _elemToFile[element];
    if (file == null) return null;
    return 'assets/images/elements/element_$file.png';
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetPath;
    if (path != null) {
      return Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final cfg = _configs[element] ?? _defaultConfig;
    return CustomPaint(
      size: Size(size, size),
      painter: _ElemPainter(cfg, size),
    );
  }

  static const _defaultConfig = _ElemCfg(
    bg: Color(0xFFBDBDBD),
    border: Color(0xFF9E9E9E),
    shape: _ElemShape.circle,
    symbol: '?',
    symbolColor: Colors.white,
  );

  static const Map<String, _ElemCfg> _configs = {
    '불': _ElemCfg(bg: Color(0xFFFF4500), border: Color(0xFFFF7A00), shape: _ElemShape.circle, symbol: '🔥', symbolColor: Colors.white),
    '물': _ElemCfg(bg: Color(0xFF1565C0), border: Color(0xFF42A5F5), shape: _ElemShape.circle, symbol: '💧', symbolColor: Colors.white),
    '번개': _ElemCfg(bg: Color(0xFFFFB300), border: Color(0xFFFFD600), shape: _ElemShape.circle, symbol: '⚡', symbolColor: Colors.white),
    '광물': _ElemCfg(bg: Color(0xFF78909C), border: Color(0xFFB0BEC5), shape: _ElemShape.hexagon, symbol: '⬡', symbolColor: Colors.white),
    '자연': _ElemCfg(bg: Color(0xFF388E3C), border: Color(0xFF66BB6A), shape: _ElemShape.circle, symbol: '🌿', symbolColor: Colors.white),
    '꽃': _ElemCfg(bg: Color(0xFF4CAF50), border: Color(0xFF81C784), shape: _ElemShape.circle, symbol: '🌸', symbolColor: Colors.white),
    '그림자': _ElemCfg(bg: Color(0xFF311B92), border: Color(0xFF7E57C2), shape: _ElemShape.circle, symbol: '🌙', symbolColor: Color(0xFFCE93D8)),
    '암흑': _ElemCfg(bg: Color(0xFF1A1A1A), border: Color(0xFF4A148C), shape: _ElemShape.circle, symbol: '🌑', symbolColor: Color(0xFF9C27B0)),
    '전설': _ElemCfg(bg: Color(0xFFE91E63), border: Color(0xFFFF80AB), shape: _ElemShape.circle, symbol: '🌈', symbolColor: Colors.white),
    '영혼': _ElemCfg(bg: Color(0xFFEEEEEE), border: Color(0xFFBDBDBD), shape: _ElemShape.circle, symbol: '○', symbolColor: Color(0xFF9E9E9E)),
    '광명': _ElemCfg(bg: Color(0xFFFFD700), border: Color(0xFFFFF176), shape: _ElemShape.diamond, symbol: '◆', symbolColor: Color(0xFF7B5800)),
    '구름': _ElemCfg(bg: Color(0xFFB3E5FC), border: Color(0xFF81D4FA), shape: _ElemShape.cloud, symbol: '☁', symbolColor: Color(0xFF0277BD)),
    '바람': _ElemCfg(bg: Color(0xFF00BCD4), border: Color(0xFF80DEEA), shape: _ElemShape.circle, symbol: '〜', symbolColor: Colors.white),
    '얼음': _ElemCfg(bg: Color(0xFF0288D1), border: Color(0xFF4FC3F7), shape: _ElemShape.circle, symbol: '❄', symbolColor: Colors.white),
    '흙': _ElemCfg(bg: Color(0xFF795548), border: Color(0xFFA1887F), shape: _ElemShape.square, symbol: '◆', symbolColor: Color(0xFFD7CCC8)),
    '독': _ElemCfg(bg: Color(0xFF6A1B9A), border: Color(0xFFCE93D8), shape: _ElemShape.circle, symbol: '☠', symbolColor: Color(0xFFE1BEE7)),
    '요정': _ElemCfg(bg: Color(0xFFAD1457), border: Color(0xFFF48FB1), shape: _ElemShape.circle, symbol: '✦', symbolColor: Color(0xFFFCE4EC)),
  };
}

// ─────────────────────────────────────────────────────────────
// CustomPainter 폴백용 (PNG 없는 경우)
// ─────────────────────────────────────────────────────────────
enum _ElemShape { circle, hexagon, diamond, square, cloud }

class _ElemCfg {
  final Color bg, border, symbolColor;
  final _ElemShape shape;
  final String symbol;
  const _ElemCfg({required this.bg, required this.border, required this.shape, required this.symbol, required this.symbolColor});
}

class _ElemPainter extends CustomPainter {
  final _ElemCfg cfg;
  final double size;
  _ElemPainter(this.cfg, this.size);

  @override
  void paint(Canvas canvas, Size sz) {
    final cx = sz.width / 2, cy = sz.height / 2, r = sz.width / 2 - 0.5;
    final fill = Paint()..color = cfg.bg..style = PaintingStyle.fill;
    final stroke = Paint()..color = cfg.border..style = PaintingStyle.stroke..strokeWidth = sz.width * 0.09;
    Path path;
    switch (cfg.shape) {
      case _ElemShape.hexagon: path = _hexPath(cx, cy, r);
      case _ElemShape.diamond: path = _diamondPath(cx, cy, r);
      case _ElemShape.square:  path = _squarePath(cx, cy, r * 0.85);
      case _ElemShape.cloud:   path = _cloudPath(cx, cy, r);
      default: path = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    }
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    final tp = TextPainter(
      text: TextSpan(text: cfg.symbol, style: TextStyle(fontSize: sz.width * 0.50, color: cfg.symbolColor, height: 1.0)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  Path _hexPath(double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = cx + r * math.cos(angle), y = cy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    return path..close();
  }
  Path _diamondPath(double cx, double cy, double r) => Path()
    ..moveTo(cx, cy - r)..lineTo(cx + r * 0.72, cy)..lineTo(cx, cy + r)..lineTo(cx - r * 0.72, cy)..close();
  Path _squarePath(double cx, double cy, double r) {
    final a = math.pi / 4;
    return Path()
      ..moveTo(cx + r*math.cos(a), cy - r*math.sin(a))..lineTo(cx + r*math.cos(a), cy + r*math.sin(a))
      ..lineTo(cx - r*math.cos(a), cy + r*math.sin(a))..lineTo(cx - r*math.cos(a), cy - r*math.sin(a))..close();
  }
  Path _cloudPath(double cx, double cy, double r) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(cx, cy + r * 0.1), radius: r * 0.7));
    path.addOval(Rect.fromCircle(center: Offset(cx - r * 0.45, cy + r * 0.25), radius: r * 0.55));
    path.addOval(Rect.fromCircle(center: Offset(cx + r * 0.45, cy + r * 0.25), radius: r * 0.55));
    return path;
  }

  @override
  bool shouldRepaint(covariant _ElemPainter old) => old.cfg != cfg || old.size != size;
}
