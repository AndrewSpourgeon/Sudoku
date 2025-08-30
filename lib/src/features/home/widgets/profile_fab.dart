import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../screens/profile_screen.dart';

class ProfileFab extends StatelessWidget {
  const ProfileFab({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photo = user?.photoURL;

    void openProfile() {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          reverseTransitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const ProfileScreen(),
          transitionsBuilder: (_, animation, secondary, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            // No fade: keep content fully visible; gentle scale only.
            return ScaleTransition(
              scale: curved.drive(
                Tween(
                  begin: 0.97,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
        ),
      );
    }

    // Custom circular avatar with gradient ring; wrapped in Hero for smooth transition
    return GestureDetector(
      onTap: openProfile,
      child: Hero(
        tag: 'profile_fab',
        createRectTween: (begin, end) =>
            MaterialRectCenterArcTween(begin: begin, end: end),
        flightShuttleBuilder:
            (
              context,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              final target = flightDirection == HeroFlightDirection.push
                  ? toHeroContext.widget
                  : fromHeroContext.widget;
              // No fade; constant visibility with scale ease.
              final scale = animation.drive(
                Tween(
                  begin: 0.88,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              );
              return ScaleTransition(scale: scale, child: target);
            },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.55),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(5), // ring thickness matching profile
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 1.2,
              ),
              color: Colors.white.withOpacity(0.08),
              image: photo != null
                  ? DecorationImage(
                      image: NetworkImage(photo),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: photo != null
                ? null // Using decoration image instead of child
                : _fallbackIcon(),
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() => Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
  );
}
