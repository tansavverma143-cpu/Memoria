import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/services/ads_service.dart';

class RewardedAdsScreen extends StatefulWidget {
  const RewardedAdsScreen({super.key});

  @override
  State<RewardedAdsScreen> createState() => _RewardedAdsScreenState();
}

class _RewardedAdsScreenState extends State<RewardedAdsScreen> {
  int _extraSaves = 0;
  int _adsWatched = 0;
  int _maxAdsPerDay = 5;
  bool _isAdLoading = false;
  bool _canWatchMoreAds = true;
  
  @override
  void initState() {
    super.initState();
    _loadStats();
  }
  
  void _loadStats() {
    // Load from shared preferences or local storage
    _extraSaves = 10; // Example: 10 extra saves from ads
    _adsWatched = 2; // Example: watched 2 ads today
    _canWatchMoreAds = _adsWatched < _maxAdsPerDay;
  }
  
  Future<void> _watchAdForSaves() async {
    if (!_canWatchMoreAds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily limit reached. Try again tomorrow.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isAdLoading = true;
    });
    
    // Load rewarded ad
    AdsService.loadRewardedAd();
    
    // Show rewarded ad
    AdsService.showRewardedAd(
      onReward: (rewardAmount) {
        // Add extra saves
        setState(() {
          _extraSaves += rewardAmount;
          _adsWatched++;
          _canWatchMoreAds = _adsWatched < _maxAdsPerDay;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$rewardAmount extra saves added!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Save stats
        _saveStats();
      },
      onAdDismissed: () {
        setState(() {
          _isAdLoading = false;
        });
      },
    );
  }
  
  void _saveStats() {
    // Save to shared preferences
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Get Extra Saves'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.royalBlue.withOpacity(0.1),
                    AppConstants.deepGold.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.videocam,
                    size: 80,
                    color: AppConstants.royalBlue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Watch Ads, Get More Saves',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Free plan users can watch rewarded ads to get additional saves',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Stats Card
            Container(
              padding: const EdgeInsets.all(24),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Extra Saves', '$_extraSaves', Icons.save),
                      _buildStatItem('Ads Watched', '$_adsWatched', Icons.videocam),
                      _buildStatItem('Daily Limit', '$_maxAdsPerDay', Icons.timer),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: _adsWatched / _maxAdsPerDay,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _canWatchMoreAds ? AppConstants.royalBlue : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_adsWatched/$_maxAdsPerDay ads watched today',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Watch Ad Button
            _isAdLoading
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: AppConstants.royalBlue,
                        ),
                        const SizedBox(height: 16),
                        const Text('Loading Ad...'),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: _canWatchMoreAds ? _watchAdForSaves : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: _canWatchMoreAds ? AppConstants.royalBlue : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _canWatchMoreAds 
                              ? 'Watch Ad for +10 Saves'
                              : 'Daily Limit Reached',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
            
            const SizedBox(height: 32),
            
            // How It Works
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How It Works:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStep(1, 'Tap "Watch Ad" button'),
                  _buildStep(2, 'Watch a short video (30-60 seconds)'),
                  _buildStep(3, 'Get +10 extra saves instantly'),
                  _buildStep(4, 'Use saves for any item type'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Premium Option
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppConstants.premiumGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Want Unlimited Saves?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upgrade to PRO or Vault+ for unlimited saves and no ads',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to subscription screen
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Plans',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Terms & Conditions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Max $maxAdsPerDay ads per day\n'
                    '• Each ad gives +10 extra saves\n'
                    '• Saves expire after 30 days\n'
                    '• Ads are provided by Google AdMob\n'
                    '• Internet connection required for ads',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppConstants.royalBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppConstants.royalBlue.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: AppConstants.royalBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppConstants.royalBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}