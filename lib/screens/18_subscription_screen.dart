import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/providers/subscription_provider.dart';
import 'package:memoria/services/razorpay_service.dart';
import 'package:memoria/services/subscription_service.dart';
import 'package:memoria/widgets/subscription_tile.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final RazorpayService _razorpayService = RazorpayService();
  String _selectedCurrency = 'USD';
  
  @override
  void initState() {
    super.initState();
    _razorpayService.initialize();
    _detectDeviceCurrency();
  }
  
  void _detectDeviceCurrency() {
    // In production, detect based on device locale
    final locale = Localizations.localeOf(context);
    if (locale.countryCode == 'IN') {
      _selectedCurrency = 'INR';
    } else if (locale.countryCode == 'EU') {
      _selectedCurrency = 'EUR';
    } else if (locale.countryCode == 'GB') {
      _selectedCurrency = 'GBP';
    } else if (locale.countryCode == 'JP') {
      _selectedCurrency = 'JPY';
    }
  }
  
  void _handlePayment(SubscriptionPlan plan) {
    final paymentDetails = RazorpayService.getPaymentDetails(plan);
    final localizedPrice = SubscriptionService.getLocalizedPrice(plan, _selectedCurrency);
    final description = 'Upgrade to ${plan.toString().split('.').last.replaceAll('_', ' ')}';
    
    _razorpayService.openCheckout(
      plan: plan,
      amount: paymentDetails['amount']!,
      currency: _selectedCurrency,
      name: 'MEMORIA',
      description: description,
      onSuccess: (successPlan) {
        Provider.of<SubscriptionProvider>(context, listen: false).updatePlan(successPlan);
        _showSuccessDialog();
      },
      onError: (error) {
        _showErrorDialog(error);
      },
    );
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Your subscription has been upgraded successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final currentPlan = subscriptionProvider.currentPlan;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upgrade Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentPlan.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Device Locked',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Plan Comparison
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Basic Plan
            SubscriptionTile(
              plan: SubscriptionPlan.basic_monthly,
              title: 'Basic',
              subtitle: 'Perfect for getting started',
              price: SubscriptionService.getLocalizedPrice(SubscriptionPlan.basic_monthly, _selectedCurrency),
              period: '/month',
              features: const [
                '10GB Storage',
                'AI Auto-Categorization',
                'AI Tag Generation',
                'Manual Reminders',
                'Smart Folders',
                'No Ads',
              ],
              isPopular: false,
              isCurrent: currentPlan == SubscriptionPlan.basic_monthly,
              onTap: () => _handlePayment(SubscriptionPlan.basic_monthly),
            ),
            
            const SizedBox(height: 16),
            
            // Pro Plan
            SubscriptionTile(
              plan: SubscriptionPlan.pro_monthly,
              title: 'Pro',
              subtitle: 'For power users',
              price: SubscriptionService.getLocalizedPrice(SubscriptionPlan.pro_monthly, _selectedCurrency),
              period: '/month',
              features: const [
                'Unlimited Storage',
                'AI Auto-Reminders',
                'Advanced Categorization',
                'NLP Smart Search',
                'Auto-detect Documents',
                'Encrypted Export/Import',
              ],
              isPopular: true,
              isCurrent: currentPlan == SubscriptionPlan.pro_monthly,
              onTap: () => _handlePayment(SubscriptionPlan.pro_monthly),
            ),
            
            const SizedBox(height: 16),
            
            // Vault+ Plan
            SubscriptionTile(
              plan: SubscriptionPlan.vault_plus,
              title: 'Vault+',
              subtitle: 'Ultimate security & features',
              price: SubscriptionService.getLocalizedPrice(SubscriptionPlan.vault_plus, _selectedCurrency),
              period: '/year',
              features: const [
                'Everything in PRO',
                'Full LifeVault (AES-256)',
                'PIN + Biometric Vault',
                'Premium AI Memory Search',
                '100% Offline Mode',
                'Permanent No Ads',
              ],
              isPopular: false,
              isCurrent: currentPlan == SubscriptionPlan.vault_plus,
              onTap: () => _handlePayment(SubscriptionPlan.vault_plus),
            ),
            
            const SizedBox(height: 32),
            
            // Features Comparison
            Text(
              'Plan Comparison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFeatureComparison(),
            
            const SizedBox(height: 32),
            
            // Device Lock Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.devices,
                    color: AppConstants.royalBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Subscription is tied to your original device for security.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureComparison() {
    return Table(
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 1,
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          children: [
            _buildTableCell('Feature'),
            _buildTableCell('Free'),
            _buildTableCell('Basic'),
            _buildTableCell('Pro'),
            _buildTableCell('Vault+'),
          ],
        ),
        _buildComparisonRow('Storage', ['100MB', '10GB', 'Unlimited', 'Unlimited']),
        _buildComparisonRow('AI Categorization', ['❌', '✅', '✅', '✅']),
        _buildComparisonRow('AI Reminders', ['❌', '❌', '✅', '✅']),
        _buildComparisonRow('Smart Search', ['❌', '❌', '✅', '✅']),
        _buildComparisonRow('LifeVault', ['❌', '❌', '❌', '✅']),
        _buildComparisonRow('Ads', ['✅', '❌', '❌', '❌']),
        _buildComparisonRow('Export', ['❌', '❌', '✅', '✅']),
      ],
    );
  }
  
  TableRow _buildComparisonRow(String feature, List<String> values) {
    return TableRow(
      children: [
        _buildTableCell(feature),
        ...values.map((value) => _buildTableCell(value)).toList(),
      ],
    );
  }
  
  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }
}