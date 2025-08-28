import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'theme.dart';
import 'controllers/game_controller.dart';
import 'controllers/profile_controller.dart';
import 'repositories/user_repository.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/leaderboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        ChangeNotifierProvider(
          create: (_) => ProfileController(UserRepository()),
        ),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          // Listen to profile controller so UI rebuilds when it finishes loading
          final pc = context.watch<ProfileController>();
          if (user != null && pc.profile == null && !pc.loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (pc.profile == null && !pc.loading) {
                pc.load();
              }
            });
          }
          Widget child;
          if (snapshot.connectionState == ConnectionState.waiting) {
            child = const _Splash();
          } else if (user == null) {
            child = const SignInScreen();
          } else if (pc.loading || pc.profile == null) {
            child = const _Splash();
          } else {
            child = const HomeScreen();
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sudoku',
            theme: AppTheme.lightTheme,
            home: child,
            routes: {
              GameScreen.routeName: (_) => const GameScreen(),
              LeaderboardScreen.routeName: (_) => const LeaderboardScreen(),
            },
          );
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final base = size.width < size.height ? size.width : size.height;
    final lottieSize = (base * .78).clamp(0, 520).toDouble(); // enlarged size
    final glowSize = lottieSize * 1.4;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft colored glow backdrop
            Container(
              width: glowSize,
              height: glowSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(.46),
                    const Color(0xFF0EA5E9).withOpacity(.14),
                    Colors.transparent,
                  ],
                  stops: const [0, .50, 1],
                ),
              ),
            ),
            SizedBox(
              width: lottieSize,
              height: lottieSize,
              child: Lottie.asset(
                'assets/lottie/loading.json',
                repeat: true,
                frameRate: FrameRate.max,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
