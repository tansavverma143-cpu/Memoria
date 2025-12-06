import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/subscription_model.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/services/device_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();
  
  static String get currentDeviceId => DeviceService.getDeviceId();
  
  static Subscription getCurrentSubscription() {
    return StorageService.getSubscription();
  }
  
  static bool hasPremiumAccess() {
    final subscription = getCurrentSubscription();
    return subscription.hasPremiumAccess;
  }
  
  static bool canSaveMoreItems() {
    final subscription = getCurrentSubscription();
    
    if (subscription.plan == SubscriptionPlan.free) {
      return subscription.totalSavesUsed < AppConstants.freePlanSaves;
    }
    
    return true;
  }
  
  static bool hasEnoughStorage(int fileSize) {
    final subscription = getCurrentSubscription();
    final totalStorage = subscription.totalStorageUsed + fileSize;
    
    switch (subscription.plan) {
      case SubscriptionPlan.free:
        return totalStorage < 100 * 1024 * 1024; // 100MB limit
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.basic_annual:
        return totalStorage < AppConstants.basicPlanStorageBytes;
      case SubscriptionPlan.pro_monthly:
      case SubscriptionPlan.pro_annual:
      case SubscriptionPlan.vault_plus:
        return true; // Unlimited
      default:
        return false;
    }
  }
  
  static List<String> getAvailableFeatures() {
    final subscription = getCurrentSubscription();
    final features = <String>[];
    
    switch (subscription.plan) {
      case SubscriptionPlan.free:
        features.addAll([
          'Basic Search',
          'Basic Folders',
          'Limited AI Tags',
          'Rewarded Ads for Extra Saves',
          '30-day Trash Retention',
        ]);
        break;
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.basic_annual:
        features.addAll([
          '10GB Storage',
          'AI Auto-Categorization',
          'AI Tag Generation',
          'Manual Reminders',
          'Smart Folders',
          'No Ads',
          '60-day Trash Retention',
        ]);
        break;
      case SubscriptionPlan.pro_monthly:
      case SubscriptionPlan.pro_annual:
        features.addAll([
          'Unlimited Storage',
          'AI Auto-Reminders',
          'Advanced Categorization',
          'NLP Smart Search',
          'Auto-detect Documents',
          'Encrypted Export/Import',
          'Smart Folder Automation',
          'No Ads',
          '1-year Trash Retention',
        ]);
        break;
      case SubscriptionPlan.vault_plus:
        features.addAll([
          'Everything in PRO',
          'Full LifeVault (AES-256)',
          'PIN + Biometric Vault',
          'Premium AI Memory Search',
          '100% Offline Mode',
          'Permanent No Ads',
          '1-year Trash Retention',
        ]);
        break;
    }
    
    return features;
  }
  
  static List<String> getRestrictedFeatures() {
    final subscription = getCurrentSubscription();
    final restrictions = <String>[];
    
    switch (subscription.plan) {
      case SubscriptionPlan.free:
        restrictions.addAll([
          'No Smart AI',
          'No Auto Reminders',
          'No LifeVault',
          'No Export',
          'No Unlimited Storage',
          'Only 30-day Trash',
        ]);
        break;
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.basic_annual:
        restrictions.addAll([
          'No AI Auto-Reminder',
          'No Advanced AI Search',
          'No LifeVault',
          'Only 60-day Trash',
        ]);
        break;
      case SubscriptionPlan.pro_monthly:
      case SubscriptionPlan.pro_annual:
        restrictions.addAll([
          'No LifeVault Premium Layer',
        ]);
        break;
      case SubscriptionPlan.vault_plus:
        // No restrictions
        break;
    }
    
    return restrictions;
  }
  
  static Future<bool> verifyPayment({
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    // Generate expected signature for verification
    final data = '$orderId|$paymentId';
    final expectedSignature = generateSignature(data);
    
    return expectedSignature == signature;
  }
  
  static String generateSignature(String data) {
    final bytes = utf8.encode(data + AppConstants.razorpayKeySecret);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static Future<void> updateSubscription({
    required SubscriptionPlan plan,
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    final currentSubscription = getCurrentSubscription();
    final now = DateTime.now();
    
    // Calculate expiry date
    DateTime expiryDate;
    switch (plan) {
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.pro_monthly:
        expiryDate = now.add(const Duration(days: 30));
        break;
      case SubscriptionPlan.basic_annual:
      case SubscriptionPlan.pro_annual:
      case SubscriptionPlan.vault_plus:
        expiryDate = now.add(const Duration(days: 365));
        break;
      default:
        expiryDate = now;
    }
    
    // Create purchase history entry
    final purchaseHistory = PurchaseHistory(
      id: 'purchase_${now.millisecondsSinceEpoch}',
      plan: plan,
      amount: getPlanPrice(plan),
      currency: 'USD',
      purchaseDate: now,
      expiryDate: expiryDate,
      paymentMethod: 'Razorpay',
      transactionId: paymentId,
    );
    
    // Update subscription
    final updatedSubscription = Subscription(
      plan: plan,
      expiryDate: expiryDate,
      isActive: true,
      deviceId: currentDeviceId,
      paymentId: paymentId,
      signature: signature,
      purchaseDate: now,
      purchaseHistory: [...currentSubscription.purchaseHistory, purchaseHistory],
      totalSavesUsed: currentSubscription.totalSavesUsed,
      totalStorageUsed: currentSubscription.totalStorageUsed,
      retentionDays: _getRetentionDaysForPlan(plan),
    );
    
    await StorageService.saveSubscription(updatedSubscription);
  }
  
  static double getPlanPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.basic_monthly:
        return 1.99;
      case SubscriptionPlan.basic_annual:
        return 19.99;
      case SubscriptionPlan.pro_monthly:
        return 3.99;
      case SubscriptionPlan.pro_annual:
        return 39.99;
      case SubscriptionPlan.vault_plus:
        return 9.99;
    }
  }
  
  static String getLocalizedPrice(SubscriptionPlan plan, String currencyCode) {
    final basePrice = getPlanPrice(plan);
    final rate = AppConstants.currencyRates[currencyCode] ?? 1.0;
    final localPrice = basePrice * rate;
    
    switch (currencyCode) {
      case 'INR':
        return '₹${localPrice.toStringAsFixed(0)}';
      case 'EUR':
        return '€${localPrice.toStringAsFixed(2)}';
      case 'GBP':
        return '£${localPrice.toStringAsFixed(2)}';
      case 'JPY':
        return '¥${localPrice.toStringAsFixed(0)}';
      default:
        return '\$${localPrice.toStringAsFixed(2)}';
    }
  }
  
  static void checkAndHandleExpiry() {
    final subscription = getCurrentSubscription();
    
    if (subscription.isExpired) {
      // Downgrade to free plan
      final downgradedSubscription = Subscription(
        plan: SubscriptionPlan.free,
        deviceId: subscription.deviceId,
        totalSavesUsed: subscription.totalSavesUsed,
        totalStorageUsed: subscription.totalStorageUsed,
        retentionDays: 30,
      );
      
      StorageService.saveSubscription(downgradedSubscription);
    }
  }
  
  static int _getRetentionDaysForPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 30;
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.basic_annual:
        return 60;
      case SubscriptionPlan.pro_monthly:
      case SubscriptionPlan.pro_annual:
      case SubscriptionPlan.vault_plus:
        return 365;
    }
  }
  
  static String getRetentionPeriodInfo() {
    final subscription = getCurrentSubscription();
    final days = _getRetentionDaysForPlan(subscription.plan);
    
    if (days == 30) {
      return '30 days retention in Recently Deleted';
    } else if (days == 60) {
      return '60 days retention in Recently Deleted';
    } else {
      return '1 year retention in Recently Deleted';
    }
  }
  
  static int getRetentionDays() {
    final subscription = getCurrentSubscription();
    return _getRetentionDaysForPlan(subscription.plan);
  }
}