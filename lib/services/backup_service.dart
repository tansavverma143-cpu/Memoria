import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/user_model.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/models/subscription_model.dart';

class BackupService {
  static Future<String> createEncryptedBackup({
    required String password,
    required User? user,
    required List<SavedItem> items,
    required List<Folder> folders,
    required Subscription subscription,
    required UserSettings settings,
  }) async {
    try {
      // Create backup data structure
      final backupData = {
        'version': '1.0.0',
        'created_at': DateTime.now().toIso8601String(),
        'app_name': AppConstants.appName,
        'data': {
          'user': user?.toJson(),
          'items': items.map((item) => item.toJson()).toList(),
          'folders': folders.map((folder) => folder.toJson()).toList(),
          'subscription': subscription.toJson(),
          'settings': settings.toJson(),
          'statistics': {
            'total_items': items.length,
            'total_folders': folders.length,
            'total_size': _calculateTotalSize(items),
          },
        },
      };
      
      // Convert to JSON
      final jsonString = jsonEncode(backupData);
      
      // Encrypt with password
      final encryptedData = _encryptWithPassword(jsonString, password);
      
      // Create backup file
      final backupFile = await _createBackupFile(encryptedData);
      
      return backupFile.path;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }
  
  static Future<Map<String, dynamic>> restoreFromBackup({
    required String filePath,
    required String password,
  }) async {
    try {
      // Read backup file
      final file = File(filePath);
      final encryptedData = await file.readAsString();
      
      // Decrypt with password
      final decryptedData = _decryptWithPassword(encryptedData, password);
      
      // Parse JSON
      final backupData = jsonDecode(decryptedData) as Map<String, dynamic>;
      
      // Validate backup version
      _validateBackupVersion(backupData['version']);
      
      return backupData['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
  
  static Future<File> _createBackupFile(String encryptedData) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/${AppConstants.backupFolder}');
    
    if (!backupDir.existsSync()) {
      await backupDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'memoria_backup_$timestamp${AppConstants.exportExtension}';
    final filePath = '${backupDir.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(encryptedData);
    
    return file;
  }
  
  static String _encryptWithPassword(String data, String password) {
    // Create key from password
    final key = sha256.convert(utf8.encode(password)).toString();
    
    // Simple XOR encryption (for demo purposes)
    // In production, use AES-256 from encryption_service.dart
    final encryptedBytes = _xorEncrypt(utf8.encode(data), utf8.encode(key));
    
    return base64.encode(encryptedBytes);
  }
  
  static String _decryptWithPassword(String encryptedData, String password) {
    try {
      final key = sha256.convert(utf8.encode(password)).toString();
      final encryptedBytes = base64.decode(encryptedData);
      final decryptedBytes = _xorEncrypt(encryptedBytes, utf8.encode(key));
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('Invalid password or corrupted backup file');
    }
  }
  
  static List<int> _xorEncrypt(List<int> data, List<int> key) {
    final result = List<int>.filled(data.length, 0);
    
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length];
    }
    
    return result;
  }
  
  static void _validateBackupVersion(String version) {
    // Check if backup version is compatible
    final currentVersion = AppConstants.appVersion.split('+')[0];
    final backupVersion = version.split('+')[0];
    
    // Allow restore from same major version
    final currentMajor = currentVersion.split('.')[0];
    final backupMajor = backupVersion.split('.')[0];
    
    if (currentMajor != backupMajor) {
      throw Exception('Backup version $version is not compatible with app version $currentVersion');
    }
  }
  
  static int _calculateTotalSize(List<SavedItem> items) {
    return items.fold(0, (sum, item) => sum + item.fileSize);
  }
  
  static Future<List<File>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/${AppConstants.backupFolder}');
      
      if (!backupDir.existsSync()) {
        return [];
      }
      
      final files = backupDir.listSync().whereType<File>().toList();
      return files.where((file) => file.path.endsWith(AppConstants.exportExtension)).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }
  
  static Future<String> getBackupInfo(File backupFile) async {
    try {
      final encryptedData = await backupFile.readAsString();
      final fileSize = backupFile.lengthSync();
      final lastModified = await backupFile.lastModified();
      
      return '''
File: ${backupFile.uri.pathSegments.last}
Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB
Modified: ${lastModified.toLocal()}
Encrypted: Yes
Extension: ${AppConstants.exportExtension}
''';
    } catch (e) {
      return 'Unable to read backup info';
    }
  }
  
  static Future<bool> validateBackupIntegrity(File backupFile, String password) async {
    try {
      final encryptedData = await backupFile.readAsString();
      _decryptWithPassword(encryptedData, password);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> cleanupOldBackups({int keepLast = 5}) async {
    try {
      final backups = await getAvailableBackups();
      
      if (backups.length <= keepLast) {
        return;
      }
      
      // Sort by modification date (oldest first)
      backups.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      
      // Delete oldest backups
      final toDelete = backups.sublist(0, backups.length - keepLast);
      
      for (final backup in toDelete) {
        await deleteBackup(backup.path);
      }
    } catch (e) {
      // Silent failure
    }
  }
}