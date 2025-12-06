import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/providers/app_provider.dart';
import 'package:memoria/screens/save_anything_screen.dart';
import 'package:memoria/screens/smart_search_screen.dart';
import 'package:memoria/screens/subscription_screen.dart';
import 'package:memoria/screens/recently_deleted_screen.dart';
import 'package:memoria/services/ads_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/ai_widget.dart';
import 'package:memoria/widgets/floating_save_button.dart';
import 'package:memoria/widgets/folder_card.dart';
import 'package:memoria/widgets/item_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }
  
  void _loadBannerAd() {
    if (AdsService.shouldShowAds) {
      _bannerAd = AdsService.createBannerAd(AdSize.banner);
      _bannerAd.load().then((_) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final items = StorageService.getAllItems();
    final folders = StorageService.getAllFolders();
    final deletedCount = StorageService.getDeletedItemsCount();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              snap: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${appProvider.userName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Welcome to your second brain',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.smartSearch);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.aiReminders);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.settings);
                  },
                ),
              ],
            ),
            
            // AI Widgets Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AIWidget(),
              ),
            ),
            
            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildQuickStats(context, items.length, deletedCount),
              ),
            ),
            
            // Folders Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Folders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteConstants.smartFolders);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: AppConstants.royalBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Folders Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < folders.length) {
                      return FolderCard(folder: folders[index]);
                    } else if (index == folders.length) {
                      return _buildAddFolderCard(context);
                    }
                    return null;
                  },
                  childCount: folders.length + 1,
                ),
              ),
            ),
            
            // Recent Items Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all items
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: AppConstants.royalBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Recent Items List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < items.length && index < 5) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ItemCard(item: items[index]),
                      );
                    }
                    return null;
                  },
                  childCount: items.length < 5 ? items.length : 5,
                ),
              ),
            ),
            
            // Recently Deleted Section
            if (deletedCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildRecentlyDeletedSection(context, deletedCount),
                ),
              ),
            
            // Ad Banner (if free plan)
            if (_isBannerAdLoaded && AdsService.shouldShowAds)
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      
      // Floating Save Button
      floatingActionButton: FloatingSaveButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstants.saveAnything);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
  
  Widget _buildQuickStats(BuildContext context, int itemCount, int deletedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.save,
            '$itemCount',
            'Total Saves',
            AppConstants.royalBlue,
          ),
          _buildStatItem(
            context,
            Icons.folder,
            '${folders.length}',
            'Folders',
            AppConstants.deepGold,
          ),
          _buildStatItem(
            context,
            Icons.delete_outline,
            '$deletedCount',
            'In Trash',
            deletedCount > 0 ? Colors.orange : Colors.grey,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentlyDeletedSection(BuildContext context, int deletedCount) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteConstants.recentlyDeleted);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recently Deleted',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$deletedCount items in trash',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddFolderCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showAddFolderDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppConstants.royalBlue,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Folder',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConstants.royalBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String folderName = '';
        return AlertDialog(
          title: Text(
            'Create New Folder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => folderName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (folderName.isNotEmpty) {
                  // Create folder logic
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', true),
              _buildNavItem(Icons.folder, 'Folders', false, onTap: () {
                Navigator.pushNamed(context, RouteConstants.smartFolders);
              }),
              _buildNavItem(Icons.lock, 'Vault', false, onTap: () {
                Navigator.pushNamed(context, RouteConstants.lifeVault);
              }),
              _buildNavItem(Icons.workspace_premium, 'Upgrade', false, onTap: () {
                Navigator.pushNamed(context, RouteConstants.subscription);
              }),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppConstants.royalBlue : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? AppConstants.royalBlue : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    if (_isBannerAdLoaded) {
      _bannerAd.dispose();
    }
    super.dispose();
  }
}