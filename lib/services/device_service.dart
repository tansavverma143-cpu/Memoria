import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:memoria/constants/constants.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _deviceId;
  static DateTime? _lastClockCheck;
  
  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    try {
      if (await _isAndroid()) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (await _isIOS()) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      } else {
        _deviceId = 'unknown_device';
      }
    } catch (e) {
      _deviceId = 'error_device_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Fallback to generated ID
    _deviceId ??= _generateFallbackId();
    
    return _deviceId!;
  }
  
  static String _generateFallbackId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return 'DEV_${timestamp}_${random}_MEMORIA';
  }
  
  static Future<bool> _isAndroid() async {
    try {
      await _deviceInfo.androidInfo;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _isIOS() async {
    try {
      await _deviceInfo.iosInfo;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> checkClockTampering() async {
    try {
      final now = DateTime.now();
      
      // Check if time has been rolled back
      if (_lastClockCheck != null && now.isBefore(_lastClockCheck!)) {
        return true; // Clock was rolled back
      }
      
      _lastClockCheck = now;
      
      // Check if device time is too far off from expected
      final expectedRange = Duration(hours: 24);
      final minDate = DateTime.now().subtract(expectedRange);
      final maxDate = DateTime.now().add(expectedRange);
      
      if (now.isBefore(minDate) || now.isAfter(maxDate)) {
        return true; // Time is suspiciously off
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (await _isAndroid()) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'device': androidInfo.device,
        };
      } else if (await _isIOS()) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
          'utsname': iosInfo.utsname.machine,
        };
      } else {
        return {'platform': 'Unknown'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  static Future<void> checkAndHandleTampering() async {
    final isTampered = await checkClockTampering();
    
    if (isTampered) {
      // Lock subscription if tampering detected
      // This would be implemented in SubscriptionService
      print('Clock tampering detected! Locking subscription...');
    }
  }
}