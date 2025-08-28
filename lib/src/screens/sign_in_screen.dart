import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;
import '../repositories/user_repository.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  // NEW: avatar consent state
  bool _avatarConsent = false; // user choice
  bool _consentTouched = false; // track if user interacted
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
    lowerBound: .85,
    upperBound: 1.05,
  )..repeat(reverse: true);
  final _userRepo = UserRepository();

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
      _consentTouched = true;
    });
    try {
      final account = await GoogleSignIn().signIn();
      if (account == null) {
        setState(() {
          _loading = false;
          _error = 'Sign in aborted.';
        });
        return;
      }
      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // Ensure user doc exists then persist consent + photo (if allowed)
      try {
        await _userRepo.getOrCreateCurrentUser();
        await _userRepo.setAvatarConsent(_avatarConsent);
      } catch (_) {}
      // Auth stream handles navigation.
    } catch (e) {
      setState(() {
        _error = 'Sign in failed';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Galaxy animated background
          Positioned.fill(child: _GalaxyBackground(animation: _anim)),
          // Floating accent blobs (kept for subtle color bloom)
          Positioned(
            top: -120,
            left: -60,
            child: _Blob(
              size: 320,
              colors: const [Color(0xFF6366F1), Color(0xFF0EA5E9)],
              progress: _anim,
            ),
          ),
          Positioned(
            bottom: -140,
            right: -80,
            child: _Blob(
              size: 360,
              colors: const [Color(0xFFFB7185), Color(0xFFF59E0B)],
              progress: _anim,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo / Title
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => Transform.scale(
                              scale: _pulse.value,
                              child: ShaderMask(
                                shaderCallback: (rect) => const LinearGradient(
                                  colors: [
                                    Color(0xFFF0F9FF),
                                    Color(0xFFBAE6FD),
                                    Color(0xFF818CF8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(rect),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  'Sudoku',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.2,
                                    height: .90,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Mindful · Logical · Beautiful',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 42),
                          // Creators section
                          _MiniGlass(
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF0EA5E9),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/drew.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(
                                          'D',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Crafted with passion',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: Colors.white70,
                                              letterSpacing: .8,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'by Drew',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.amber.shade300,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 46),
                          // Sign-in panel
                          _GlassPanel(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Animated colorful cloud badge replacing static icon
                                _AnimatedCloudBadge(progress: _anim),
                                const SizedBox(height: 18),
                                Text(
                                  'Sync & Compete',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Save progress, track stats, climb ranks',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white60,
                                    letterSpacing: .4,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                if (_error != null) ...[
                                  Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                // NEW: consent checkbox
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _avatarConsent = !_avatarConsent;
                                          _consentTouched = true;
                                        });
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                            value: _avatarConsent,
                                            onChanged: (v) {
                                              setState(() {
                                                _avatarConsent = v ?? false;
                                                _consentTouched = true;
                                              });
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(
                                                .45,
                                              ),
                                            ),
                                            activeColor: const Color(
                                              0xFF3B82F6,
                                            ),
                                            checkColor: Colors.white,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.white70,
                                                        height: 1.3,
                                                      ),
                                                  children: const [
                                                    TextSpan(
                                                      text:
                                                          'I consent to show my Google profile image on leaderboards so other players can see it. ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          'You can change this later in your profile settings.',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!_avatarConsent && _consentTouched)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 4,
                                        ),
                                        child: Text(
                                          'If unchecked your image won\'t appear in leaderboards.',
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _GoogleButton(
                                  loading: _loading,
                                  onPressed: _loading
                                      ? null
                                      : _signInWithGoogle,
                                ),
                                const SizedBox(height: 22),
                                AnimatedOpacity(
                                  opacity: _loading ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: const SizedBox(
                                    height: 38,
                                    width: 38,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool loading;
  const _GoogleButton({required this.onPressed, required this.loading});
  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _hover,
          builder: (_, __) {
            final t = Curves.easeOutCubic.transform(_hover.value);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFF1E40AF),
                      const Color(0xFF3B82F6),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFF2563EB),
                      const Color(0xFF60A5FA),
                      t,
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(.35 + .25 * t),
                    blurRadius: 30 * (1 + t),
                    offset: const Offset(0, 14),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(.10 + .10 * t),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleMark(size: 26),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.loading ? 'Signing in...' : 'Continue with Google',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  final double size;
  const _GoogleMark({required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Image.asset(
        'assets/images/googlelogo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.g_mobiledata_rounded,
            size: size * .9,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}

class _MiniGlass extends StatelessWidget {
  final Widget child;
  const _MiniGlass({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.15)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(.14),
                Colors.white.withOpacity(.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(30, 34, 30, 38),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(.10)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(.22),
                Colors.white.withOpacity(.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.55),
                blurRadius: 50,
                offset: const Offset(0, 34),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final Animation<double> progress;
  const _Blob({
    required this.size,
    required this.colors,
    required this.progress,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Transform.rotate(
        angle: progress.value * 6.283,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colors.first.withOpacity(.55),
                colors.last.withOpacity(.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// New Galaxy background implementation
class _GalaxyBackground extends StatefulWidget {
  final Animation<double> animation;
  const _GalaxyBackground({required this.animation});
  @override
  State<_GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<_GalaxyBackground> {
  late final List<_Star> _stars;
  late final List<_Nebula> _nebulas;
  final int _starCount = 140; // balanced for performance
  final math.Random _rnd = math.Random(7);

  @override
  void initState() {
    super.initState();
    _stars = List.generate(_starCount, (i) {
      final depth = _rnd.nextDouble();
      return _Star(
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble(),
        baseAlpha: .25 + _rnd.nextDouble() * .55,
        radius: .6 + _rnd.nextDouble() * 2.2,
        twinkleSpeed: 2 + _rnd.nextDouble() * 2.5,
        depth: depth, // 0 (near) .. 1 (far)
      );
    });
    _nebulas = [
      _Nebula(
        color: const Color(0xFF4F46E5),
        radius: 480,
        dx: .15,
        dy: .28,
        pulse: .9,
      ),
      _Nebula(
        color: const Color(0xFF0EA5E9),
        radius: 420,
        dx: .78,
        dy: .22,
        pulse: 1.1,
      ),
      _Nebula(
        color: const Color(0xFF9333EA),
        radius: 520,
        dx: .62,
        dy: .68,
        pulse: 1.0,
      ),
      _Nebula(
        color: const Color(0xFFF59E0B),
        radius: 360,
        dx: .28,
        dy: .72,
        pulse: 1.05,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) => CustomPaint(
        painter: _GalaxyPainter(
          t: widget.animation.value,
          stars: _stars,
          nebulas: _nebulas,
        ),
      ),
    );
  }
}

class _GalaxyPainter extends CustomPainter {
  final double t; // 0..1 loop
  final List<_Star> stars;
  final List<_Nebula> nebulas;
  _GalaxyPainter({required this.t, required this.stars, required this.nebulas});

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintNebulas(canvas, size);
    _paintStars(canvas, size);
    _paintSubtleVignette(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFF050A1B),
          Color(0xFF0B1635),
          Color(0xFF1B0F33),
          Color(0xFF00010A),
        ],
        stops: const [0, .45, .75, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, base);
  }

  void _paintNebulas(Canvas canvas, Size size) {
    for (final neb in nebulas) {
      final pulse =
          0.85 + math.sin((t * 2 * math.pi) * neb.pulse + neb.dx * 5) * 0.15;
      final center = Offset(
        neb.dx * size.width +
            math.sin(t * 2 * math.pi + neb.dy) * 20 * (neb.dx - .5),
        neb.dy * size.height +
            math.cos(t * 2 * math.pi + neb.dx) * 20 * (neb.dy - .5),
      );
      final radius = neb.radius * (0.9 + 0.1 * pulse);
      final shader = RadialGradient(
        colors: [
          neb.color.withOpacity(.0),
          neb.color.withOpacity(.08 * pulse),
          neb.color.withOpacity(.0),
        ],
        stops: const [0, .55, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      final paint = Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final depthScale =
          0.4 + (1 - s.depth) * 0.8; // nearby stars a bit larger/brighter
      final twinkle =
          math.sin((t * s.twinkleSpeed * 2 * math.pi) + s.x * 10) * .5 + .5;
      final alpha = s.baseAlpha * (.6 + twinkle * .8) * depthScale;
      paint.color = Colors.white.withOpacity(alpha.clamp(0, 1));
      final parallaxX = (s.x + (t * 0.02 * (1 - s.depth))) % 1.0; // slow drift
      final parallaxY = (s.y + (t * 0.01 * (1 - s.depth))) % 1.0;
      final pos = Offset(parallaxX * size.width, parallaxY * size.height);
      final r = s.radius * depthScale;
      canvas.drawCircle(pos, r, paint);
      // Occasional subtle glow for brighter stars
      if (alpha > .55) {
        final glow = Paint()
          ..color = Colors.white.withOpacity(alpha * .18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(pos, r * 2.2, glow);
      }
    }
  }

  void _paintSubtleVignette(Canvas canvas, Size size) {
    final shader =
        RadialGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(.35)],
          stops: const [.65, 1],
        ).createShader(
          Rect.fromCircle(
            center: size.center(Offset.zero),
            radius: size.longestSide * .75,
          ),
        );
    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.darken;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter old) => true;
}

class _Star {
  final double x, y, baseAlpha, radius, twinkleSpeed, depth;
  _Star({
    required this.x,
    required this.y,
    required this.baseAlpha,
    required this.radius,
    required this.twinkleSpeed,
    required this.depth,
  });
}

class _Nebula {
  final Color color;
  final double radius;
  final double dx;
  final double dy;
  final double pulse;
  _Nebula({
    required this.color,
    required this.radius,
    required this.dx,
    required this.dy,
    required this.pulse,
  });
}

class _AnimatedCloudBadge extends StatelessWidget {
  final Animation<double> progress;
  const _AnimatedCloudBadge({required this.progress});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        final wobble = math.sin(t * 2 * math.pi) * .035;
        return Transform.scale(
          scale: 1 + wobble,
          child: SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Modern sharp orbital frame
                CustomPaint(
                  size: const Size.square(100),
                  painter: _ModernCloudFramePainter(t),
                ),
                // Soft inner glow backdrop
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(
                          .22 + .10 * math.sin(t * 2 * math.pi).abs(),
                        ),
                        Colors.white.withOpacity(.04),
                      ],
                      stops: const [0, 1],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(.18),
                      width: 1.2,
                    ),
                  ),
                ),
                // Single gradient cloud icon with subtle glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Opacity(
                        opacity: .55,
                        child: _GradientIcon(
                          icon: Icons.cloud,
                          size: 46,
                          t: t,
                          opacity: 1,
                        ),
                      ),
                    ),
                    _GradientIcon(
                      icon: Icons.cloud,
                      size: 46,
                      t: t,
                      opacity: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModernCloudFramePainter extends CustomPainter {
  final double t;
  _ModernCloudFramePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * .48;
    final sweepPhase = t * 2 * math.pi;

    // Base outer ring (thin crisp stroke)
    final baseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(.18)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, baseStroke);

    // Gradient primary arc (accent sweep)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          Color(0xFF6366F1),
          Color(0xFF0EA5E9),
          Color(0xFF10B981),
          Color(0xFFF59E0B),
          Color(0xFFEF4444),
          Color(0xFF6366F1),
        ],
        stops: const [0, .22, .40, .60, .80, 1],
        transform: GradientRotation(sweepPhase),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    // Draw segmented arcs for sharp look
    final segments = 5;
    for (int i = 0; i < segments; i++) {
      final segStart = sweepPhase + (i / segments) * math.pi * 2;
      final segSweep = math.pi * 2 / segments * .55; // gap between
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segStart,
        segSweep,
        false,
        arcPaint,
      );
    }

    // Inner ring
    final innerRadius = radius * .72;
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(.35), Colors.white.withOpacity(.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerPaint);

    // Orbiting accent dots
    final dotCount = 3;
    for (int i = 0; i < dotCount; i++) {
      final angle =
          sweepPhase +
          i * (2 * math.pi / dotCount) +
          math.sin(sweepPhase + i) * .15;
      final r = radius - 4;
      final pos = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      final dot = Paint()
        ..style = PaintingStyle.fill
        ..color = [
          const Color(0xFF0EA5E9),
          const Color(0xFFF59E0B),
          const Color(0xFFEF4444),
        ][i % 3].withOpacity(.85);
      canvas.drawCircle(pos, 4.2, dot);
      canvas.drawCircle(
        pos,
        8,
        Paint()
          ..color = dot.color.withOpacity(.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Subtle radial mask vignette overlay to sharpen outer area
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(.10), Colors.transparent],
        stops: const [0, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.15));
    canvas.drawCircle(center, radius * 1.15, vignette);
  }

  @override
  bool shouldRepaint(covariant _ModernCloudFramePainter old) => true;
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double t; // 0..1 animation value for rotation
  final double opacity;
  const _GradientIcon({
    required this.icon,
    required this.size,
    required this.t,
    this.opacity = 1,
  });
  @override
  Widget build(BuildContext context) {
    final rotation = t * 2 * math.pi;
    final colors = const [
      Color(0xFF6366F1),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF6366F1),
    ];
    return ShaderMask(
      shaderCallback: (rect) => SweepGradient(
        startAngle: rotation,
        endAngle: rotation + math.pi * 2,
        colors: [
          for (int i = 0; i < colors.length; i++)
            colors[i].withOpacity(opacity * (i.isEven ? 1 : .85)),
        ],
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}
