import 'package:flutter/material.dart';
import '../models/difficulty_option.dart';

class DifficultyCard extends StatefulWidget {
  final DifficultyOption option;
  final VoidCallback onTap;
  final int index;
  const DifficultyCard({
    super.key,
    required this.option,
    required this.onTap,
    required this.index,
  });
  @override
  State<DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<DifficultyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();
  bool _pressed = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.option;
    final anim = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.1 * widget.index,
        0.6 + 0.1 * widget.index,
        curve: Curves.easeOutCubic,
      ),
    );
    final borderGradient = LinearGradient(
      colors: [d.colors.first, d.colors.last, d.colors.first.withOpacity(.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) => Opacity(
        opacity: anim.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, 26 * (1 - anim.value)),
          child: child,
        ),
      ),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: _pressed ? 0.96 : 1.0,
            curve: Curves.easeOut,
            child: Container(
              height: 158,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: borderGradient,
                boxShadow: [
                  BoxShadow(
                    color: d.colors.last.withOpacity(0.60),
                    blurRadius: 36,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 36,
                    offset: const Offset(0, 28),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: [
                      d.colors.first.withOpacity(.35),
                      d.colors.last.withOpacity(.18),
                      Colors.black.withOpacity(.15),
                    ],
                    stops: const [.0, .55, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(-6, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [d.colors.first, d.colors.last],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: d.colors.last.withOpacity(.70),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Icon(d.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          d.label,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                fontSize: d.label.length >= 6 ? 16.5 : null,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, _) {
                          final scale = MediaQuery.of(context).textScaler;
                          final capped = scale.textScaleFactor.clamp(0.8, 1.1);
                          return MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaler: TextScaler.linear(capped)),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${d.size} x ${d.size}',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 0.7,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
