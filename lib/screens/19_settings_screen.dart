import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/providers/app_provider.dart';
import 'package:memoria/screens/backup_export_screen.dart';
import 'package:memoria/screens/lifevault_screen.dart';
import 'package:memoria/screens/recently_deleted_screen.dart';
import 'package:memoria/screens/subscription_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  bool _biometricLock = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System Default';

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDarkMode = appProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // User Profile
          _buildUserProfile(),
          
          // Account Settings
          _buildSection('Account'),
          _buildSettingTile(
            icon: Icons.workspace_premium,
            title: 'Subscription & Plans',
            subtitle: 'Upgrade your plan',
            onTap: () => Navigator.pushNamed(context, RouteConstants.subscription),
          ),
          _buildSettingTile(
            icon: Icons.lock,
            title: 'LifeVault',
            subtitle: 'Secure encrypted storage',
            onTap: () => Navigator.pushNamed(context, RouteConstants.lifeVault),
          ),
          _buildSettingTile(
            icon: Icons.delete_outline,
            title: 'Recently Deleted',
            subtitle: 'Restore deleted items',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecentlyDeletedScreen()),
            ),
          ),
          
          // App Settings
          _buildSection('App Settings'),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Theme',
            subtitle: _selectedTheme,
            onTap: _showThemeSelector,
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                appProvider.toggleDarkMode();
              },
              activeColor: AppConstants.royalBlue,
            ),
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: _showLanguageSelector,
          ),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Reminders & alerts',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppConstants.royalBlue,
            ),
          ),
          _buildSettingTile(
            icon: Icons.fingerprint,
            title: 'Biometric Lock',
            subtitle: 'Use fingerprint/Face ID',
            trailing: Switch(
              value: _biometricLock,
              onChanged: (value) {
                setState(() {
                  _biometricLock = value;
                });
              },
              activeColor: AppConstants.royalBlue,
            ),
          ),
          
          // Data Management
          _buildSection('Data Management'),
          _buildSettingTile(
            icon: Icons.backup,
            title: 'Backup & Export',
            subtitle: 'Create encrypted backup',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BackupExportScreen()),
            ),
          ),
          _buildSettingTile(
            icon: Icons.restore,
            title: 'Import & Restore',
            subtitle: 'Restore from backup',
            onTap: () => Navigator.pushNamed(context, RouteConstants.importRestore),
          ),
          _buildSettingTile(
            icon: Icons.sync,
            title: 'Auto Backup',
            subtitle: 'Backup every 7 days',
            trailing: Switch(
              value: _autoBackupEnabled,
              onChanged: (value) {
                setState(() {
                  _autoBackupEnabled = value;
                });
              },
              activeColor: AppConstants.royalBlue,
            ),
          ),
          _buildSettingTile(
            icon: Icons.storage,
            title: 'Storage Usage',
            subtitle: '1.2 GB of 10 GB used',
            onTap: _showStorageDetails,
          ),
          
          // Support & Legal
          _buildSection('Support & Legal'),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQ & contact us',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View privacy policy',
            onTap: () => Navigator.pushNamed(context, RouteConstants.privacyPolicy),
          ),
          _buildSettingTile(
            icon: Icons.description,
            title: 'Terms & Conditions',
            subtitle: 'View terms of service',
            onTap: () => Navigator.pushNamed(context, RouteConstants.terms),
          ),
          _buildSettingTile(
            icon: Icons.assignment_return,
            title: 'Refund Policy',
            subtitle: 'View refund policy',
            onTap: () => Navigator.pushNamed(context, RouteConstants.refundPolicy),
          ),
          _buildSettingTile(
            icon: Icons.cookie,
            title: 'Cookie Policy',
            subtitle: 'View cookie policy',
            onTap: () => Navigator.pushNamed(context, RouteConstants.cookiesPolicy),
          ),
          _buildSettingTile(
            icon: Icons.assignment,
            title: 'EULA',
            subtitle: 'End User License Agreement',
            onTap: () => Navigator.pushNamed(context, RouteConstants.eula),
          ),
          
          // About
          _buildSection('About'),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About MEMORIA',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.star,
            title: 'Rate This App',
            subtitle: 'Leave a review',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Share with friends',
            onTap: () {},
          ),
          
          // Danger Zone
          _buildSection('Danger Zone'),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Delete All Data',
            subtitle: 'Permanently delete everything',
            titleColor: Colors.red,
            onTap: _confirmDeleteAllData,
          ),
          _buildSettingTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: Colors.orange,
            onTap: _confirmLogout,
          ),
          
          const SizedBox(height: 32),
          
          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'MEMORIA v1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  '© 2024 MEMORIA. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppConstants.premiumGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppConstants.royalBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'john.doe@email.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PRO Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
  
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppConstants.royalBlue,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.brightness_auto),
              title: const Text('System Default'),
              onTap: () {
                setState(() {
                  _selectedTheme = 'System Default';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                setState(() {
                  _selectedTheme = 'Light';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                setState(() {
                  _selectedTheme = 'Dark';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: _selectedLanguage == 'English' 
                  ? Icon(Icons.check, color: AppConstants.royalBlue) 
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Hindi'),
              trailing: _selectedLanguage == 'Hindi' 
                  ? Icon(Icons.check, color: AppConstants.royalBlue) 
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Hindi';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              trailing: _selectedLanguage == 'Spanish' 
                  ? Icon(Icons.check, color: AppConstants.royalBlue) 
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Spanish';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStorageDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Documents'),
              subtitle: const Text('500 MB'),
              trailing: Text('50%'),
            ),
            ListTile(
              title: const Text('Photos'),
              subtitle: const Text('400 MB'),
              trailing: Text('40%'),
            ),
            ListTile(
              title: const Text('Audio'),
              subtitle: const Text('100 MB'),
              trailing: Text('10%'),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStroppedAnimation<Color>(AppConstants.royalBlue),
            ),
            const SizedBox(height: 8),
            const Text('1.2 GB of 10 GB used'),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text('This will permanently delete all your saved items, settings, and account. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete all data
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
  
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logout logic
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}