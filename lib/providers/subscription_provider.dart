import 'package:flutter/material.dart';
import 'package:memoria/models/subscription_model.dart';
import 'package:memoria/services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  Subscription _currentSubscription = SubscriptionService.getCurrentSubscription();
  
  Subscription get currentSubscription => _currentSubscription;
  SubscriptionPlan get currentPlan => _currentSubscription.plan;
  bool get hasPremiumAccess => _currentSubscription.hasPremiumAccess;
  int get retentionDays => _currentSubscription.getRetentionDays();
  
  SubscriptionProvider() {
    _checkExpiry();
  }
  
  void _checkExpiry() {
    if (_currentSubscription.isExpired) {
      SubscriptionService.checkAndHandleExpiry();
      _currentSubscription = SubscriptionService.getCurrentSubscription();
      notifyListeners();
    }
  }
  
  Future<void> updatePlan(SubscriptionPlan plan) async {
    // This would be called after successful payment
    _currentSubscription.plan = plan;
    _currentSubscription.isActive = true;
    _currentSubscription.expiryDate = _calculateExpiry(plan);
    _currentSubscription.purchaseDate = DateTime.now();
    _currentSubscription.retentionDays = _currentSubscription.getRetentionDays();
    
    await StorageService.saveSubscription(_currentSubscription);
    notifyListeners();
  }
  
  DateTime _calculateExpiry(SubscriptionPlan plan) {
    final now = DateTime.now();
    switch (plan) {
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.pro_monthly:
        return now.add(const Duration(days: 30));
      case SubscriptionPlan.basic_annual:
      case SubscriptionPlan.pro_annual:
      case SubscriptionPlan.vault_plus:
        return now.add(const Duration(days: 365));
      default:
        return now;
    }
  }
  
  bool canSaveItem(int fileSize) {
    return SubscriptionService.canSaveMoreItems() && 
           SubscriptionService.hasEnoughStorage(fileSize);
  }
  
  void incrementSaves() {
    _currentSubscription.totalSavesUsed++;
    StorageService.saveSubscription(_currentSubscription);
    notifyListeners();
  }
  
  void addStorageUsed(int bytes) {
    _currentSubscription.totalStorageUsed += bytes;
    StorageService.saveSubscription(_currentSubscription);
    notifyListeners();
  }
  
  void refreshSubscription() {
    _currentSubscription = SubscriptionService.getCurrentSubscription();
    notifyListeners();
  }
  
  String getRetentionInfo() {
    return SubscriptionService.getRetentionPeriodInfo();
  }
}