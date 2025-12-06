import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/services/subscription_service.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();
  
  static bool _isInitialized = false;
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  
  static bool get shouldShowAds {
    final subscription = SubscriptionService.getCurrentSubscription();
    return subscription.plan == SubscriptionPlan.free;
  }
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }
  
  static BannerAd createBannerAd(AdSize adSize) {
    return BannerAd(
      adUnitId: AppConstants.admobBannerId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Banner ad loaded.'),
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
  
  static Future<void> loadInterstitialAd() async {
    if (!shouldShowAds) return;
    
    await InterstitialAd.load(
      adUnitId: AppConstants.admobInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }
  
  static void showInterstitialAd() {
    if (!shouldShowAds || _interstitialAd == null) return;
    
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('Interstitial ad shown.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show interstitial ad: $error');
        ad.dispose();
        loadInterstitialAd();
      },
    );
    
    _interstitialAd?.show();
    _interstitialAd = null;
  }
  
  static Future<void> loadRewardedAd() async {
    if (!shouldShowAds) return;
    
    await RewardedAd.load(
      adUnitId: AppConstants.admobRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }
  
  static void showRewardedAd({
    required Function(int) onReward,
    required Function() onAdDismissed,
  }) {
    if (!shouldShowAds || _rewardedAd == null) return;
    
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('Rewarded ad shown.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show rewarded ad: $error');
        ad.dispose();
        loadRewardedAd();
      },
    );
    
    _rewardedAd?.setImmersiveMode(true);
    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        onReward(reward.amount.toInt());
      },
    );
    _rewardedAd = null;
  }
  
  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}