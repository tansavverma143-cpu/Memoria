import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';

class FloatingSaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  
  const FloatingSaveButton({
    super.key,
    required this.onPressed,
  });
  
  @override
  State<FloatingSaveButton> createState() => _FloatingSaveButtonState();
}

class _FloatingSaveButtonState extends State<FloatingSaveButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.5), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.royalBlue.withOpacity(_glowAnimation.value * 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppConstants.deepGold.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: AppConstants.royalBlue,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.royalBlue,
                          AppConstants.royalBlue.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  
                  // Inner circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: AppConstants.royalBlue,
                    ),
                  ),
                  
                  // Plus sign with gradient
                  Positioned(
                    child: Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppConstants.premiumGradient,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 4,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppConstants.premiumGradient,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}