import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/screens/subscription_screen.dart';

class LockedFeatureScreen extends StatelessWidget {
  final String featureName;
  final String featureDescription;
  final String requiredPlan;
  final IconData featureIcon;
  
  const LockedFeatureScreen({
    super.key,
    required this.featureName,
    required this.featureDescription,
    required this.requiredPlan,
    required this.featureIcon,
  });
  
  factory LockedFeatureScreen.aiReminders() {
    return LockedFeatureScreen(
      featureName: 'AI Auto-Reminders',
      featureDescription: 'Automatically detect and set reminders for due dates, expiry dates, and renewals',
      requiredPlan: 'PRO',
      featureIcon: Icons.auto_awesome,
    );
  }
  
  factory LockedFeatureScreen.lifeVault() {
    return LockedFeatureScreen(
      featureName: 'LifeVault',
      featureDescription: 'AES-256 encrypted secure storage with PIN and biometric protection',
      requiredPlan: 'VAULT+',
      featureIcon: Icons.lock,
    );
  }
  
  factory LockedFeatureScreen.smartSearch() {
    return LockedFeatureScreen(
      featureName: 'NLP Smart Search',
      featureDescription: 'Search naturally like "Find my passport from last year" or "Bills from last month"',
      requiredPlan: 'PRO',
      featureIcon: Icons.search,
    );
  }
  
  factory LockedFeatureScreen.export() {
    return LockedFeatureScreen(
      featureName: 'Encrypted Export',
      featureDescription: 'Export all your data with military-grade encryption',
      requiredPlan: 'PRO',
      featureIcon: Icons.backup,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Premium Feature'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Lock Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.royalBlue.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.royalBlue.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.royalBlue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.lock,
                size: 60,
                color: AppConstants.royalBlue,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Feature Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppConstants.premiumGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                featureIcon,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Feature Name
            Text(
              featureName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Required Plan Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.deepGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.deepGold,
                ),
              ),
              child: Text(
                '$requiredPlan PLAN REQUIRED',
                style: TextStyle(
                  color: AppConstants.deepGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Feature Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppConstants.royalBlue,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Feature Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    featureDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Plan Comparison
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.deepGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppConstants.deepGold.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppConstants.deepGold,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Plan Comparison',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPlanRow('Free Plan', '❌', false),
                  _buildPlanRow('Basic Plan', '❌', false),
                  _buildPlanRow('Pro Plan', requiredPlan == 'PRO' ? '✅' : '❌', requiredPlan == 'PRO'),
                  _buildPlanRow('Vault+ Plan', '✅', true),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Upgrade Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Upgrade to $requiredPlan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Continue with Free
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue with Free Plan'),
            ),
            
            const SizedBox(height: 32),
            
            // Features List
            Text(
              'What you get with $requiredPlan:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              children: _getPlanFeatures(requiredPlan).map((feature) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppConstants.royalBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanRow(String plan, String status, bool isTarget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              plan,
              style: TextStyle(
                fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
                color: isTarget ? AppConstants.royalBlue : null,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
              color: isTarget ? Colors.green : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  List<String> _getPlanFeatures(String plan) {
    switch (plan) {
      case 'PRO':
        return [
          'Unlimited Storage',
          'AI Auto-Reminders',
          'NLP Smart Search',
          'Advanced Categorization',
          'Encrypted Export/Import',
          'No Ads',
        ];
      case 'VAULT+':
        return [
          'Everything in PRO',
          'LifeVault (AES-256)',
          'PIN + Biometric Protection',
          'Premium AI Memory Search',
          '100% Offline Mode',
          'Permanent No Ads',
        ];
      default:
        return [
          'AI Auto-Categorization',
          '10GB Storage',
          'Manual Reminders',
          'Smart Folders',
          'No Ads',
        ];
    }
  }
}