import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp; // for timestamp conversion

class ProfilePerformancePanel extends StatelessWidget {
  final List<Map<String, dynamic>> recent;
  final dynamic profile; // expects easy / medium / hard objects
  const ProfilePerformancePanel({
    super.key,
    required this.recent,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final recentSorted = [...recent];
    recentSorted.sort((a, b) {
      DateTime parse(dynamic v) {
        if (v is DateTime) return v;
        if (v is Timestamp) return v.toDate();
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      final da = parse(a['ts']);
      final db = parse(b['ts']);
      return da.compareTo(db);
    });
    final points = recentSorted.take(20).toList();
    final durations = points.map((g) {
      final s = g['seconds'];
      if (s is num) return s.toDouble();
      return 0.0;
    }).toList();
    final maxDur = durations.isEmpty
        ? 0.0
        : durations.reduce(math.max).toDouble().clamp(1.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: durations.isEmpty
              ? const Center(
                  child: Text(
                    'Play games to see performance trends.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                )
              : _LineChart(points: points, maxSeconds: maxDur),
        ),
        const SizedBox(height: 18),
        _DifficultyBars(profile: profile),
      ],
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> points; // ascending
  final double maxSeconds;
  const _LineChart({required this.points, required this.maxSeconds});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(points: points, maxSeconds: maxSeconds),
      child: Container(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  final double maxSeconds;
  _LineChartPainter({required this.points, required this.maxSeconds});
  @override
  void paint(Canvas canvas, Size size) {
    final pad = 12.0;
    final chartW = size.width - pad * 2;
    final chartH = size.height - pad * 2;
    if (points.isEmpty) return;

    final path = Path();
    final fill = Path();
    for (int i = 0; i < points.length; i++) {
      final g = points[i];
      final secRaw = g['seconds'];
      final sec = (secRaw is num) ? secRaw.toDouble() : 0.0;
      final x =
          pad + (i / ((points.length - 1).clamp(1, double.infinity))) * chartW;
      final norm = (sec / maxSeconds).clamp(0.0, 1.0);
      final y = pad + chartH - norm * chartH;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, pad + chartH);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
      // point dot
    }
    fill.lineTo(pad + chartW, pad + chartH);
    fill.close();

    final gradient = LinearGradient(
      colors: [
        const Color(0xFF38BDF8).withOpacity(.65),
        const Color(0xFFA78BFA).withOpacity(.15),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawPath(fill, Paint()..shader = gradient.createShader(rect));

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = LinearGradient(
        colors: const [Color(0xFF38BDF8), Color(0xFF6366F1), Color(0xFFA78BFA)],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, stroke);

    // dots
    final dotPaintWin = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.fill;
    final dotPaintLoss = Paint()
      ..color = const Color(0xFFFF4E70)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      final g = points[i];
      final secRaw = g['seconds'];
      final sec = (secRaw is num) ? secRaw.toDouble() : 0.0;
      final x =
          pad + (i / ((points.length - 1).clamp(1, double.infinity))) * chartW;
      final norm = (sec / maxSeconds).clamp(0.0, 1.0);
      final y = pad + chartH - norm * chartH;
      canvas.drawCircle(
        Offset(x, y),
        4.2,
        (g['win'] == true) ? dotPaintWin : dotPaintLoss,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.points != points || old.maxSeconds != maxSeconds;
}

class _DifficultyBars extends StatelessWidget {
  final dynamic profile;
  const _DifficultyBars({required this.profile});
  @override
  Widget build(BuildContext context) {
    final items = [
      _diff('Easy', profile?.easy),
      _diff('Medium', profile?.medium),
      _diff('Hard', profile?.hard),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty Win Ratios',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        for (final d in items)
          _BarRow(label: d.label, wins: d.wins, games: d.games, color: d.color),
      ],
    );
  }

  _DiffData _diff(String label, dynamic obj) {
    if (obj == null) {
      return _DiffData(label: label, wins: 0, games: 0, color: _color(label));
    }
    final wins = (obj.wins ?? 0) as int;
    final games = (obj.gamesPlayed ?? 0) as int;
    return _DiffData(
      label: label,
      wins: wins,
      games: games,
      color: _color(label),
    );
  }

  Color _color(String l) {
    switch (l) {
      case 'Easy':
        return const Color(0xFF4ADE80);
      case 'Medium':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFFFB7185);
    }
  }
}

class _DiffData {
  final String label;
  final int wins;
  final int games;
  final Color color;
  _DiffData({
    required this.label,
    required this.wins,
    required this.games,
    required this.color,
  });
}

class _BarRow extends StatelessWidget {
  final String label;
  final int wins;
  final int games;
  final Color color;
  const _BarRow({
    required this.label,
    required this.wins,
    required this.games,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final ratio = games == 0 ? 0 : wins / games;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(.08),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(.85),
                          color.withOpacity(.45),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 54,
            child: Text(
              games == 0 ? '0%' : '${(ratio * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
