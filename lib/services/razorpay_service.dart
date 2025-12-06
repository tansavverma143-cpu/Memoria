import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/subscription_model.dart';
import 'package:memoria/services/subscription_service.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();
  
  late Razorpay _razorpay;
  Function(SubscriptionPlan)? _onSuccess;
  Function(String)? _onError;
  SubscriptionPlan? _currentPlan;
  
  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void openCheckout({
    required SubscriptionPlan plan,
    required String amount,
    required String currency,
    required String name,
    required String description,
    required Function(SubscriptionPlan) onSuccess,
    required Function(String) onError,
  }) {
    _currentPlan = plan;
    _onSuccess = onSuccess;
    _onError = onError;
    
    final options = {
      'key': AppConstants.razorpayKeyId,
      'amount': amount,
      'name': 'MEMORIA',
      'description': description,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'theme': {
        'color': '#1F6FEB',
        'backdrop_color': '#0D1117',
      }
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      onError(e.toString());
    }
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentPlan == null || _onSuccess == null) return;
    
    // Verify payment signature
    final isValid = await SubscriptionService.verifyPayment(
      paymentId: response.paymentId!,
      signature: response.signature!,
      orderId: response.orderId!,
    );
    
    if (isValid) {
      // Update subscription
      await SubscriptionService.updateSubscription(
        plan: _currentPlan!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        orderId: response.orderId!,
      );
      
      _onSuccess!(_currentPlan!);
    } else {
      _onError?.call('Payment verification failed');
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    _onError?.call(response.message ?? 'Payment failed');
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    _onError?.call('External wallet selected: ${response.walletName}');
  }
  
  void dispose() {
    _razorpay.clear();
  }
  
  // Generate order and amount
  static Map<String, dynamic> getPaymentDetails(SubscriptionPlan plan) {
    final price = SubscriptionService.getPlanPrice(plan);
    final amount = (price * 100).toInt(); // Convert to paisa/cents
    
    return {
      'amount': amount.toString(),
      'currency': 'INR',
      'description': _getPlanDescription(plan),
    };
  }
  
  static String _getPlanDescription(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.basic_monthly:
        return 'MEMORIA Basic Monthly Plan';
      case SubscriptionPlan.basic_annual:
        return 'MEMORIA Basic Annual Plan';
      case SubscriptionPlan.pro_monthly:
        return 'MEMORIA Pro Monthly Plan';
      case SubscriptionPlan.pro_annual:
        return 'MEMORIA Pro Annual Plan';
      case SubscriptionPlan.vault_plus:
        return 'MEMORIA Vault+ Annual Plan';
      default:
        return 'MEMORIA Subscription';
    }
  }
}