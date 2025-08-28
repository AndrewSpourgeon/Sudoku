import 'package:flutter/material.dart';
import '../models/quick_stat.dart';

class QuickStatTile extends StatelessWidget {
  final QuickStat stat;
  final int
  index; // retained for potential stagger logic (not used internally now)
  final Animation<double> animation; // drives entrance
  const QuickStatTile({
    super.key,
    required this.stat,
    required this.index,
    required this.animation,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = animation.value.clamp(0.0, 1.0);
        final scale = 0.92 + 0.08 * v;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 34),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: _TileBody(stat: stat),
            ),
          ),
        );
      },
    );
  }
}

class _TileBody extends StatelessWidget {
  final QuickStat stat;
  const _TileBody({required this.stat});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stat.color.withOpacity(0.70), width: 1.2),
        gradient: LinearGradient(
          colors: [
            stat.color.withOpacity(0.90),
            stat.color.withOpacity(0.55),
            stat.color.withOpacity(0.22),
          ],
          stops: const [0, .55, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(.70),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.18),
            blurRadius: 20,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.55),
            blurRadius: 34,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.34,
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.35),
                        Colors.white.withOpacity(.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: stat.color.withOpacity(.60),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(.35),
                      width: 1.1,
                    ),
                  ),
                  child: Icon(stat.icon, color: Colors.white, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      stat.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(.85),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900, // made bolder
                        fontSize: 11,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(.92),
                          stat.color.withOpacity(.95),
                        ],
                        stops: const [0, .55, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(rect),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        stat.value,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
