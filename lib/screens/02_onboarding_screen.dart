import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/screens/signup_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Your Digital Memory',
      description: 'Save anything instantly - text, photos, documents, voice notes, and more',
      image: 'assets/images/onboarding1.png',
      color: AppConstants.royalBlue,
    ),
    OnboardingPage(
      title: 'AI-Powered Organization',
      description: 'Automatic categorization, smart tags, and natural language search',
      image: 'assets/images/onboarding2.png',
      color: AppConstants.deepGold,
    ),
    OnboardingPage(
      title: '100% Secure & Private',
      description: 'Everything stored locally with AES-256 encryption. No cloud, no tracking',
      image: 'assets/images/onboarding3.png',
      color: AppConstants.royalBlue,
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteConstants.signup);
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page Indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppConstants.royalBlue,
                dotColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _currentPage == _pages.length - 1
                  ? _buildGetStartedButton(context)
                  : _buildNextButton(context),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Illustration
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.1),
                  page.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(140),
              border: Border.all(
                color: page.color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                _getPageIcon(page),
                size: 120,
                color: page.color,
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: 0.8, end: 1.0, curve: Curves.elasticOut),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 300.ms)
          .slideY(begin: 20, end: 0),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 500.ms)
          .slideY(begin: 20, end: 0),
        ],
      ),
    );
  }
  
  IconData _getPageIcon(OnboardingPage page) {
    if (page.title.contains('Memory')) return Icons.memory;
    if (page.title.contains('AI')) return Icons.psychology;
    return Icons.security;
  }
  
  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        'Next',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildGetStartedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, RouteConstants.signup);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppConstants.royalBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Started',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 20, color: Colors.white),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color color;
  
  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}