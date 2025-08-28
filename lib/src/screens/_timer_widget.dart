import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'dart:math' as math;

class TimerWidget extends StatefulWidget {
  final bool compact;
  final double? height;
  final Size? painterSize; // width/height of orbit painter
  final double? fontSize; // override text size
  final EdgeInsets? innerPadding; // override inner time capsule padding
  const TimerWidget({
    super.key,
    this.compact = false,
    this.height,
    this.painterSize,
    this.fontSize,
    this.innerPadding,
  });
  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final timeLimit = controller.timeLimit ?? Duration.zero;
    final elapsed = controller.elapsed;
    final remaining = timeLimit - elapsed;
    final min = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    final totalSeconds = timeLimit.inSeconds;
    final usedSeconds = elapsed.inSeconds.clamp(0, totalSeconds);
    final progress = totalSeconds == 0 ? 0.0 : usedSeconds / totalSeconds;

    final bool compact = widget.compact;
    final double h = widget.height ?? (compact ? 44 : 80);
    final Size painterSize =
        widget.painterSize ??
        (compact ? const Size(140, 60) : const Size(180, 110));
    final double textSize = widget.fontSize ?? (compact ? 24 : 30);
    final EdgeInsets innerPad =
        widget.innerPadding ??
        (compact
            ? const EdgeInsets.symmetric(vertical: 6, horizontal: 24)
            : const EdgeInsets.symmetric(vertical: 10, horizontal: 32));

    return SizedBox(
      height: h,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _orbit,
              builder: (context, child) {
                return CustomPaint(
                  painter: _OrbitRectPainter(
                    orbitProgress: _orbit.value,
                    progress: progress,
                  ),
                  size: painterSize,
                );
              },
            ),
            Container(
              padding: innerPad,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.30),
                borderRadius: BorderRadius.circular(compact ? 16 : 20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.30),
                    blurRadius: compact ? 16 : 22,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.26),
                    blurRadius: compact ? 24 : 34,
                    spreadRadius: -10,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Text(
                '$min:$sec',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitRectPainter extends CustomPainter {
  final double orbitProgress; // 0..1 animation offset for moving segment
  final double progress; // time progress 0..1
  _OrbitRectPainter({required this.orbitProgress, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    // Background frame fill
    final framePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(r, framePaint);

    // Base border
    final baseBorder = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(r, baseBorder);

    // Path + metrics
    final path = Path()..addRRect(r);
    final metric = path.computeMetrics().first;
    final total = metric.length;

    // Snake length grows with progress (at least a minimum so it is visible)
    final clampedProgress = progress.clamp(0.0, 1.0);
    final minFrac = 0.05; // 5% perimeter minimal visibility
    final snakeLength =
        (total * (clampedProgress == 0 ? minFrac : clampedProgress)).clamp(
          total * minFrac,
          total,
        );

    // Head moves continuously around perimeter
    final headOffset = (orbitProgress * total) % total;
    final tailOffset = (headOffset - snakeLength) % total;

    // Build a single path for the snake body (avoid tiny caps causing a dot)
    Path snakePath = Path();
    if (snakeLength >= total - 0.5) {
      snakePath = metric.extractPath(0, total);
    } else {
      if (tailOffset < headOffset) {
        // no wrap
        snakePath.addPath(
          metric.extractPath(tailOffset, headOffset),
          Offset.zero,
        );
      } else {
        // wrapped around: tail->end and 0->head
        snakePath.addPath(metric.extractPath(tailOffset, total), Offset.zero);
        snakePath.addPath(metric.extractPath(0, headOffset), Offset.zero);
      }
    }

    // Body paint (no round caps so no isolated dot at seams)
    final bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 6
      ..shader = LinearGradient(
        colors: const [Color(0xFF06B6D4), Color(0xFF4F7DF1), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..blendMode = BlendMode.plus;

    canvas.drawPath(snakePath, bodyPaint);

    // Head highlight (separate so only one bright cap exists and moves)
    final headTangent = metric.getTangentForOffset(headOffset)!;
    final headPos = headTangent.position;

    final headGlow = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(headPos, 2, headGlow);

    final headCore = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFF06B6D4), Color(0xFF6366F1)],
      ).createShader(Rect.fromCircle(center: headPos, radius: 10));
    canvas.drawCircle(headPos, 5.5, headCore);

    // Tail soft fade (draw a clipped portion with alpha gradient) optional
    final tailFadeLength = math.min(snakeLength * 0.35, total * 0.18);
    if (tailFadeLength > 6) {
      final tailStart = (headOffset - snakeLength) % total;
      final fadeEnd = (tailStart + tailFadeLength) % total;
      Path fadePath = Path();
      if (snakeLength >= total - 0.5) {
        fadePath = metric.extractPath(0, total);
      } else {
        if (tailStart < fadeEnd) {
          fadePath.addPath(metric.extractPath(tailStart, fadeEnd), Offset.zero);
        } else {
          fadePath.addPath(metric.extractPath(tailStart, total), Offset.zero);
          fadePath.addPath(metric.extractPath(0, fadeEnd), Offset.zero);
        }
      }
      final fadePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.02),
            Colors.white.withOpacity(0.18),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(rect);
      canvas.drawPath(fadePath, fadePaint);
    }

    // Soft outer ambient glow
    final outerGlow = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
    canvas.drawRRect(r, outerGlow);
  }

  @override
  bool shouldRepaint(covariant _OrbitRectPainter old) =>
      old.orbitProgress != orbitProgress || old.progress != progress;
}

class MistakeCounter extends StatelessWidget {
  const MistakeCounter({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final remaining = (controller.mistakeLimit - controller.mistakes).clamp(
      0,
      controller.mistakeLimit,
    );
    final ratio = controller.mistakes / controller.mistakeLimit;
    Color color;
    if (ratio < 0.5) {
      color = Colors.greenAccent;
    } else if (ratio < 0.8) {
      color = Colors.amberAccent;
    } else {
      color = Colors.redAccent;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.24), color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            'Mistakes ${controller.mistakes}/${controller.mistakeLimit}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
          if (remaining == 0) ...[
            const SizedBox(width: 12),
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
