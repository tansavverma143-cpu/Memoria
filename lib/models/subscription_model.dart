import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 6)
enum SubscriptionPlan {
  @HiveField(0)
  free,
  
  @HiveField(1)
  basic_monthly,
  
  @HiveField(2)
  basic_annual,
  
  @HiveField(3)
  pro_monthly,
  
  @HiveField(4)
  pro_annual,
  
  @HiveField(5)
  vault_plus,
}

@HiveType(typeId: 7)
class Subscription {
  @HiveField(0)
  SubscriptionPlan plan;
  
  @HiveField(1)
  DateTime? expiryDate;
  
  @HiveField(2)
  bool isActive;
  
  @HiveField(3)
  String deviceId;
  
  @HiveField(4)
  String? paymentId;
  
  @HiveField(5)
  String? signature;
  
  @HiveField(6)
  DateTime? purchaseDate;
  
  @HiveField(7)
  List<PurchaseHistory> purchaseHistory;
  
  @HiveField(8)
  int totalSavesUsed;
  
  @HiveField(9)
  int totalStorageUsed;
  
  @HiveField(10)
  int retentionDays;
  
  Subscription({
    this.plan = SubscriptionPlan.free,
    this.expiryDate,
    this.isActive = false,
    required this.deviceId,
    this.paymentId,
    this.signature,
    this.purchaseDate,
    this.purchaseHistory = const [],
    this.totalSavesUsed = 0,
    this.totalStorageUsed = 0,
    this.retentionDays = 30,
  });
  
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: SubscriptionPlan.values.firstWhere((e) => e.toString() == json['plan']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      isActive: json['isActive'],
      deviceId: json['deviceId'],
      paymentId: json['paymentId'],
      signature: json['signature'],
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate']) : null,
      purchaseHistory: List<PurchaseHistory>.from(
        json['purchaseHistory'].map((x) => PurchaseHistory.fromJson(x))
      ),
      totalSavesUsed: json['totalSavesUsed'],
      totalStorageUsed: json['totalStorageUsed'],
      retentionDays: json['retentionDays'] ?? 30,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'plan': plan.toString(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'deviceId': deviceId,
      'paymentId': paymentId,
      'signature': signature,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchaseHistory': purchaseHistory.map((x) => x.toJson()).toList(),
      'totalSavesUsed': totalSavesUsed,
      'totalStorageUsed': totalStorageUsed,
      'retentionDays': retentionDays,
    };
  }
  
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  bool get isValidOnDevice {
    return deviceId == SubscriptionService.currentDeviceId;
  }
  
  bool get hasPremiumAccess {
    return isActive && !isExpired && isValidOnDevice;
  }
  
  int getRetentionDays() {
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
}

@HiveType(typeId: 8)
class PurchaseHistory {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final SubscriptionPlan plan;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final String currency;
  
  @HiveField(4)
  final DateTime purchaseDate;
  
  @HiveField(5)
  final DateTime expiryDate;
  
  @HiveField(6)
  final String paymentMethod;
  
  @HiveField(7)
  final String? transactionId;
  
  PurchaseHistory({
    required this.id,
    required this.plan,
    required this.amount,
    required this.currency,
    required this.purchaseDate,
    required this.expiryDate,
    required this.paymentMethod,
    this.transactionId,
  });
  
  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'],
      plan: SubscriptionPlan.values.firstWhere((e) => e.toString() == json['plan']),
      amount: json['amount'],
      currency: json['currency'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': plan.toString(),
      'amount': amount,
      'currency': currency,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }
}