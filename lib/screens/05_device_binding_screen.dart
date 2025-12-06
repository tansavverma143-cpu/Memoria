import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/providers/subscription_provider.dart';
import 'package:memoria/screens/home_screen.dart';
import 'package:provider/provider.dart';

class DeviceBindingScreen extends StatefulWidget {
  const DeviceBindingScreen({super.key});

  @override
  State<DeviceBindingScreen> createState() => _DeviceBindingScreenState();
}

class _DeviceBindingScreenState extends State<DeviceBindingScreen> {
  bool _isBinding = false;
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    _generateDeviceId();
  }

  void _generateDeviceId() {
    // Generate a mock device ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _deviceId = 'DEV-${timestamp.toString().substring(5)}-MEM';
  }

  Future<void> _bindDevice() async {
    setState(() {
      _isBinding = true;
    });

    // Simulate binding process
    await Future.delayed(const Duration(seconds: 2));

    // Initialize subscription with device ID
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    subscriptionProvider.refreshSubscription();

    setState(() {
      _isBinding = false;
    });

    // Navigate to home
    Navigator.pushReplacementNamed(context, RouteConstants.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Device Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppConstants.royalBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.royalBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.devices,
                  size: 60,
                  color: AppConstants.royalBlue,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: AppConstants.royalBlue.withOpacity(0.3)),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Device Binding',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'For security, your subscription will be linked to this device',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Device ID Card
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
                    Text(
                      'Device ID',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _deviceId,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This ID uniquely identifies your device',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Important Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.deepGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppConstants.deepGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppConstants.deepGold,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.deepGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If you sign in on another device, your premium features will not transfer. Each device requires its own subscription.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Bind Device Button
              ElevatedButton(
                onPressed: _isBinding ? null : _bindDevice,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppConstants.royalBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bind This Device',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.link, size: 20, color: Colors.white),
                        ],
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Terms Text
              Text(
                'By proceeding, you agree to device-specific subscription terms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}