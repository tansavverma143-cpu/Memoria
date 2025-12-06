import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/subscription_model.dart';

class SubscriptionTile extends StatelessWidget {
  final SubscriptionPlan plan;
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final bool isCurrent;
  final VoidCallback onTap;
  
  const SubscriptionTile({
    super.key,
    required this.plan,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.isCurrent = false,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCurrent 
                ? AppConstants.royalBlue 
                : Theme.of(context).dividerColor.withOpacity(0.3),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: [
            if (isPopular)
              BoxShadow(
                color: AppConstants.deepGold.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppConstants.goldGradient,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        period,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Features
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppConstants.royalBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Select Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.green : AppConstants.royalBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isCurrent ? 'CURRENT PLAN' : 'SELECT PLAN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Current Plan Badge
            if (isCurrent)
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}