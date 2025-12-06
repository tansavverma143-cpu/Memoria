import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/services/encryption_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';

class BackupExportScreen extends StatefulWidget {
  const BackupExportScreen({super.key});

  @override
  State<BackupExportScreen> createState() => _BackupExportScreenState();
}

class _BackupExportScreenState extends State<BackupExportScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isCreatingBackup = false;
  bool _backupCreated = false;
  File? _backupFile;
  String? _backupPassword;
  
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _createBackup() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isCreatingBackup = true;
    });
    
    try {
      // Get all data
      final user = StorageService.getCurrentUser();
      final items = StorageService.getAllItems();
      final folders = StorageService.getAllFolders();
      final subscription = StorageService.getSubscription();
      final settings = StorageService.getSettings();
      
      // Create backup data
      final backupData = {
        'app_version': '1.0.0',
        'backup_date': DateTime.now().toIso8601String(),
        'user': user?.toJson(),
        'items': items.map((item) => item.toJson()).toList(),
        'folders': folders.map((folder) => folder.toJson()).toList(),
        'subscription': subscription.toJson(),
        'settings': settings.toJson(),
      };
      
      // Convert to JSON string
      final jsonString = backupData.toString();
      
      // Encrypt with password
      final encryptedData = EncryptionService.encryptVaultData(
        jsonString,
        _passwordController.text,
      );
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/${AppConstants.backupFolder}');
      if (!backupDir.existsSync()) {
        await backupDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${backupDir.path}/memoria_backup_$timestamp${AppConstants.exportExtension}';
      _backupFile = File(backupPath);
      await _backupFile!.writeAsString(encryptedData);
      
      // Save password for this backup
      _backupPassword = _passwordController.text;
      
      setState(() {
        _backupCreated = true;
        _isCreatingBackup = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      setState(() {
        _isCreatingBackup = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _shareBackup() async {
    if (_backupFile == null) return;
    
    try {
      await Share.shareXFiles([XFile(_backupFile!.path)],
        text: 'MEMORIA Backup File\nPassword: $_backupPassword\n\nDO NOT SHARE THIS PASSWORD WITH ANYONE!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _copyBackupToDownloads() async {
    if (_backupFile == null) return;
    
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final destPath = '${downloadsDir.path}/${_backupFile!.uri.pathSegments.last}';
        await _backupFile!.copy(destPath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup saved to Downloads folder'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Backup & Export'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.royalBlue.withOpacity(0.1),
                    AppConstants.deepGold.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.backup,
                        color: AppConstants.royalBlue,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Secure Backup',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'All data is encrypted with AES-256',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Backup includes:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBackupItem('All saved items'),
                  _buildBackupItem('Folders & categories'),
                  _buildBackupItem('User settings'),
                  _buildBackupItem('Subscription info'),
                  _buildBackupItem('Activity history'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Password Input
            Text(
              'Set Backup Password',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This password will be required to restore the backup',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _passwordController,
              label: 'Backup Password',
              hintText: 'Enter a strong password',
              isPassword: true,
              prefixIcon: Icons.lock,
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hintText: 'Re-enter the password',
              isPassword: true,
              prefixIcon: Icons.lock,
            ),
            
            const SizedBox(height: 32),
            
            // Backup Button
            ElevatedButton(
              onPressed: _isCreatingBackup ? null : _createBackup,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isCreatingBackup
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.backup, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Create Encrypted Backup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 32),
            
            // Backup Created Section
            if (_backupCreated && _backupFile != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Backup Created Successfully!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'File: ${_backupFile!.uri.pathSegments.last}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Size: ${(_backupFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '⚠️ IMPORTANT: Save this password in a safe place!',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      child: SelectableText(
                        'Password: $_backupPassword',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _shareBackup,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: AppConstants.royalBlue,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share),
                                SizedBox(width: 8),
                                Text('Share Backup'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _copyBackupToDownloads,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.royalBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('Save to Device'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Security Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: AppConstants.deepGold,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Security Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Backup files are encrypted with AES-256\n'
                    '• Without the password, backup cannot be restored\n'
                    '• Store password separately from backup file\n'
                    '• Backup does not include app settings\n'
                    '• Regular backups are recommended',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackupItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppConstants.royalBlue,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}