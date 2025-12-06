import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/screens/auto_categorization_screen.dart';
import 'package:memoria/screens/smart_search_screen.dart';

class AIWidget extends StatefulWidget {
  const AIWidget({super.key});

  @override
  State<AIWidget> createState() => _AIWidgetState();
}

class _AIWidgetState extends State<AIWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentTip = 0;
  
  final List<String> _aiTips = [
    'Try: "Find my passport from last year"',
    'AI can auto-categorize your bills',
    'Say "Save this" to add voice notes',
    'Create smart folders with rules',
    'Set reminders for expiry dates',
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Rotate tips every 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTip = (_currentTip + 1) % _aiTips.length;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.royalBlue.withOpacity(0.1),
            AppConstants.deepGold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppConstants.premiumGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Powered by on-device AI',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.auto_awesome,
                color: AppConstants.deepGold,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // AI Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppConstants.deepGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _aiTips[_currentTip],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          )
          .animate(
            controller: _controller,
            autoPlay: true,
          )
          .fadeIn(duration: 500.ms)
          .then(delay: 4500.ms)
          .fadeOut(duration: 500.ms),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.search,
                  label: 'Smart Search',
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.smartSearch);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.category,
                  label: 'Auto-Categorize',
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.autoCategorization);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications,
                  label: 'Reminders',
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.aiReminders);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI System Ready',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Text(
                '100% On-Device',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.deepGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppConstants.royalBlue,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}