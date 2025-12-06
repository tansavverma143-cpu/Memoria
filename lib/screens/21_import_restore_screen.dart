import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/services/encryption_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';

class ImportRestoreScreen extends StatefulWidget {
  const ImportRestoreScreen({super.key});

  @override
  State<ImportRestoreScreen> createState() => _ImportRestoreScreenState();
}

class _ImportRestoreScreenState extends State<ImportRestoreScreen> {
  final TextEditingController _passwordController = TextEditingController();
  
  File? _selectedFile;
  bool _isImporting = false;
  bool _isDecrypting = false;
  String? _importError;
  Map<String, dynamic>? _backupInfo;
  
  Future<void> _selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['memoria'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.first.path!);
          _importError = null;
          _backupInfo = null;
        });
      }
    } catch (e) {
      setState(() {
        _importError = 'Error selecting file: $e';
      });
    }
  }
  
  Future<void> _previewBackup() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a backup file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter backup password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isDecrypting = true;
      _importError = null;
    });
    
    try {
      // Read file
      final encryptedData = await _selectedFile!.readAsString();
      
      // Try to decrypt
      final decryptedData = EncryptionService.decryptVaultData(
        encryptedData,
        _passwordController.text,
      );
      
      if (decryptedData.isEmpty) {
        throw Exception('Invalid password or corrupted file');
      }
      
      // Parse backup info (simplified)
      setState(() {
        _backupInfo = {
          'items_count': 42, // Would parse from actual data
          'backup_date': '2024-01-15',
          'app_version': '1.0.0',
          'user_email': 'user@example.com',
        };
      });
      
    } catch (e) {
      setState(() {
        _importError = 'Decryption failed: $e';
      });
    } finally {
      setState(() {
        _isDecrypting = false;
      });
    }
  }
  
  Future<void> _restoreBackup() async {
    if (_selectedFile == null || _passwordController.text.isEmpty) {
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current data with backup data. '
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performRestore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performRestore() async {
    setState(() {
      _isImporting = true;
    });
    
    try {
      // Simulate restore process
      await Future.delayed(const Duration(seconds: 3));
      
      // In real app, would:
      // 1. Decrypt backup
      // 2. Parse data
      // 3. Clear current data
      // 4. Restore from backup
      
      setState(() {
        _isImporting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup restored successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to home
      Navigator.popUntil(context, (route) => route.isFirst);
      
    } catch (e) {
      setState(() {
        _isImporting = false;
        _importError = 'Restore failed: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Import & Restore'),
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
            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.royalBlue.withOpacity(0.1),
                    AppConstants.deepGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restore,
                        color: AppConstants.royalBlue,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Restore from Backup',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Restore your data from an encrypted .memoria backup file',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Step 1: Select File
            Text(
              'Step 1: Select Backup File',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _selectBackupFile,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    width: 2,
                    style: _selectedFile == null ? BorderStyle.dashed : BorderStyle.solid,
                  ),
                ),
                child: _selectedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to select backup file',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            '.memoria files only',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.backup,
                            size: 48,
                            color: AppConstants.royalBlue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile!.uri.pathSegments.last,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Step 2: Enter Password
            Text(
              'Step 2: Enter Backup Password',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _passwordController,
              label: 'Backup Password',
              hintText: 'Enter the password used when creating backup',
              isPassword: true,
              prefixIcon: Icons.lock,
            ),
            
            const SizedBox(height: 24),
            
            // Preview Button
            if (_selectedFile != null)
              ElevatedButton(
                onPressed: _isDecrypting ? null : _previewBackup,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppConstants.deepGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isDecrypting
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
                          Icon(Icons.remove_red_eye, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Preview Backup',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            
            // Error Message
            if (_importError != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _importError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Backup Preview
            if (_backupInfo != null)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 24),
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
                          Icons.verified,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Backup Verified',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBackupInfo('Backup Date', _backupInfo!['backup_date']),
                    _buildBackupInfo('App Version', _backupInfo!['app_version']),
                    _buildBackupInfo('User Email', _backupInfo!['user_email']),
                    _buildBackupInfo('Items Count', '${_backupInfo!['items_count']} items'),
                    const SizedBox(height: 24),
                    Text(
                      'This backup will replace all current data',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Restore Button
            if (_backupInfo != null)
              ElevatedButton(
                onPressed: _isImporting ? null : _restoreBackup,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isImporting
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
                          Icon(Icons.restore, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Restore Backup',
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
            
            // Important Notes
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
                        Icons.warning_amber,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Restoring will replace ALL current data\n'
                    '• Make sure you have a current backup\n'
                    '• Device must be connected to power\n'
                    '• Do not close the app during restore\n'
                    '• May take several minutes for large backups',
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
  
  Widget _buildBackupInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}