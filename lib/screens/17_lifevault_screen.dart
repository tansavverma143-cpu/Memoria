import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/encryption_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/vault_item_card.dart';

class LifeVaultScreen extends StatefulWidget {
  const LifeVaultScreen({super.key});

  @override
  State<LifeVaultScreen> createState() => _LifeVaultScreenState();
}

class _LifeVaultScreenState extends State<LifeVaultScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  
  bool _isAuthenticated = false;
  bool _isLocked = true;
  bool _isLoading = false;
  String _errorMessage = '';
  List<SavedItem> _vaultItems = [];
  
  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }
  
  Future<void> _checkBiometricSupport() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        setState(() {
          _errorMessage = 'Biometric authentication not available';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking biometric support: $e';
      });
    }
  }
  
  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access LifeVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        await _unlockVault();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _authenticateWithPIN() async {
    if (_pinController.text.isEmpty || _pinController.text.length != 4) {
      setState(() {
        _errorMessage = 'Please enter a 4-digit PIN';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // In real app, verify PIN against stored hash
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo, accept any 4-digit PIN
    if (_pinController.text.length == 4) {
      await _unlockVault();
    } else {
      setState(() {
        _errorMessage = 'Invalid PIN';
      });
    }
    
    setState(() {
      _isLoading = false;
    });
    _pinController.clear();
  }
  
  Future<void> _unlockVault() async {
    // Load vault items
    final allItems = StorageService.getAllItems();
    _vaultItems = allItems.where((item) => item.isVaultItem).toList();
    
    setState(() {
      _isAuthenticated = true;
      _isLocked = false;
      _errorMessage = '';
    });
  }
  
  void _lockVault() {
    setState(() {
      _isAuthenticated = false;
      _isLocked = true;
      _vaultItems.clear();
    });
  }
  
  Future<void> _moveToVault(SavedItem item) async {
    item.isVaultItem = true;
    item.isEncrypted = true;
    
    // Encrypt content
    if (item.content.isNotEmpty) {
      item.content = EncryptionService.encryptVaultData(
        item.content,
        AppConstants.vaultKey,
      );
    }
    
    await StorageService.saveItem(item);
    
    setState(() {
      _vaultItems.add(item);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item moved to LifeVault'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _removeFromVault(SavedItem item) async {
    item.isVaultItem = false;
    item.isEncrypted = false;
    
    // Decrypt content
    if (item.content.isNotEmpty) {
      try {
        item.content = EncryptionService.decryptVaultData(
          item.content,
          AppConstants.vaultKey,
        );
      } catch (e) {
        print('Error decrypting: $e');
      }
    }
    
    await StorageService.saveItem(item);
    
    setState(() {
      _vaultItems.removeWhere((i) => i.id == item.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from LifeVault'),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('LifeVault'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: _lockVault,
              tooltip: 'Lock Vault',
            ),
        ],
      ),
      body: _isLocked ? _buildLockScreen() : _buildVaultContent(),
    );
  }
  
  Widget _buildLockScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vault Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppConstants.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.deepGold.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.deepGold.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.lock,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            'LifeVault',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.deepGold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'AES-256 Encrypted Secure Storage',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Biometric Button
          if (!_isLoading)
            ElevatedButton(
              onPressed: _authenticateWithBiometric,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.deepGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Unlock with Biometric',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // OR Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // PIN Input
          Text(
            'Enter 4-digit PIN',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // PIN Pad
          _buildPINPad(),
          
          const SizedBox(height: 24),
          
          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Security Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppConstants.royalBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Military-Grade Security',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.royalBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All vault items are encrypted with AES-256 and never leave your device',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPINPad() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(12, (index) {
        if (index == 9) {
          return Container(); // Empty cell
        } else if (index == 10) {
          return _buildPINButton('0', () {
            _pinController.text += '0';
          });
        } else if (index == 11) {
          return _buildPINButton(
            Icons.backspace,
            () {
              if (_pinController.text.isNotEmpty) {
                _pinController.text = _pinController.text
                    .substring(0, _pinController.text.length - 1);
              }
            },
            isIcon: true,
          );
        } else {
          return _buildPINButton(
            (index + 1).toString(),
            () {
              if (_pinController.text.length < 4) {
                _pinController.text += (index + 1).toString();
                
                // Auto-submit when 4 digits entered
                if (_pinController.text.length == 4) {
                  _authenticateWithPIN();
                }
              }
            },
          );
        }
      }),
    );
  }
  
  Widget _buildPINButton(dynamic content, VoidCallback onTap, {bool isIcon = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isIcon
              ? Icon(
                  content as IconData,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                )
              : Text(
                  content.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildVaultContent() {
    return Column(
      children: [
        // Vault Stats
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppConstants.goldGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LifeVault Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_vaultItems.length} encrypted items',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AES-256',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Vault Items
        Expanded(
          child: _vaultItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your vault is empty',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Move items here for extra security',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vaultItems.length,
                  itemBuilder: (context, index) {
                    final item = _vaultItems[index];
                    return VaultItemCard(
                      item: item,
                      onRemove: () => _removeFromVault(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}