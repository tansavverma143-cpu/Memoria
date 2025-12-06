import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/screens/home_screen.dart';
import 'package:memoria/screens/onboarding_screen.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Check if user has completed onboarding
    final settings = StorageService.getSettings();
    final user = StorageService.getCurrentUser();
    
    // Navigate to appropriate screen
    if (user == null) {
      Navigator.pushReplacementNamed(context, RouteConstants.onboarding);
    } else {
      Navigator.pushReplacementNamed(context, RouteConstants.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppConstants.premiumGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.royalBlue.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Brain wave curve
                  CustomPaint(
                    painter: _BrainWavePainter(),
                    size: const Size(120, 120),
                  ),
                  
                  // Letter M
                  Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.pureWhite,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate(controller: _controller)
            .scale(begin: 0.5, end: 1.0, curve: Curves.elasticOut)
            .fadeIn(duration: 800.ms),
            
            const SizedBox(height: 30),
            
            // App Name
            Text(
              'MEMORIA',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppConstants.royalBlue,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            )
            .animate(controller: _controller)
            .slideY(begin: 0.5, end: 0, delay: 300.ms)
            .fadeIn(delay: 300.ms),
            
            const SizedBox(height: 10),
            
            // Tagline
            Text(
              'Your Second Brain',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppConstants.deepGold,
                letterSpacing: 1,
              ),
            )
            .animate(controller: _controller)
            .slideY(begin: 0.5, end: 0, delay: 500.ms)
            .fadeIn(delay: 500.ms),
            
            const SizedBox(height: 50),
            
            // Loading indicator
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.deepGold),
                strokeWidth: 3,
                backgroundColor: AppConstants.royalBlue.withOpacity(0.2),
              ),
            )
            .animate(controller: _controller)
            .fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}

class _BrainWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.deepGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Draw brain wave pattern
    for (double angle = 0; angle < 2 * 3.14159; angle += 0.1) {
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle) + sin(angle * 3) * 10;
      
      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}