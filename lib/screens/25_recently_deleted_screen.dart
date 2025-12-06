import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/deleted_item_model.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/item_card.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  List<DeletedItem> _deletedItems = [];
  bool _isEmpty = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDeletedItems();
  }
  
  void _loadDeletedItems() {
    setState(() {
      _isLoading = true;
    });
    
    // Run cleanup first
    StorageService.cleanupExpiredDeletedItems();
    
    final items = StorageService.getDeletedItems();
    
    setState(() {
      _deletedItems = items;
      _isEmpty = items.isEmpty;
      _isLoading = false;
    });
  }
  
  Future<void> _restoreItem(DeletedItem deletedItem) async {
    await StorageService.restoreItem(deletedItem.item.id);
    
    setState(() {
      _deletedItems.removeWhere((item) => item.item.id == deletedItem.item.id);
      _isEmpty = _deletedItems.isEmpty;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item restored successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _permanentDeleteItem(DeletedItem deletedItem) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.permanentDeleteItem(deletedItem.item.id);
              setState(() {
                _deletedItems.removeWhere((item) => item.item.id == deletedItem.item.id);
                _isEmpty = _deletedItems.isEmpty;
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item permanently deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _emptyTrash() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text('Permanently delete all items in trash? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              for (final item in _deletedItems) {
                await StorageService.permanentDeleteItem(item.item.id);
              }
              
              setState(() {
                _deletedItems.clear();
                _isEmpty = true;
              });
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trash emptied'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _restoreAll() async {
    for (final item in _deletedItems) {
      await StorageService.restoreItem(item.item.id);
    }
    
    setState(() {
      _deletedItems.clear();
      _isEmpty = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_deletedItems.length} items restored'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Widget _buildRetentionInfo() {
    final retentionDays = StorageService._getRetentionDays();
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.royalBlue.withOpacity(0.1),
            AppConstants.deepGold.withOpacity(0.05),
          ],
        ),
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
                Icons.delete_outline,
                color: AppConstants.royalBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recently Deleted',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Items are kept for $retentionDays days based on your plan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Retention periods by plan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Retention Periods:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildPlanRetention('Free Plan', '30 days'),
              _buildPlanRetention('Basic Plan', '60 days'),
              _buildPlanRetention('Pro & Vault+', '1 year'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanRetention(String plan, String retention) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppConstants.royalBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(plan),
          const Spacer(),
          Text(
            retention,
            style: TextStyle(
              color: AppConstants.deepGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Recently Deleted'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_deletedItems.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'restore_all') {
                  _restoreAll();
                } else if (value == 'empty_trash') {
                  _emptyTrash();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'restore_all',
                  child: Row(
                    children: [
                      Icon(Icons.restore, size: 20),
                      SizedBox(width: 8),
                      Text('Restore All'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'empty_trash',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Empty Trash'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConstants.royalBlue,
              ),
            )
          : _isEmpty
              ? Column(
                  children: [
                    _buildRetentionInfo(),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 80,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Trash is Empty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Deleted items will appear here',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildRetentionInfo(),
                    
                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_deletedItems.length} items',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Auto-deletes in ${_deletedItems.first.daysUntilPermanentDelete} days',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.deepGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Deleted Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _deletedItems.length,
                        itemBuilder: (context, index) {
                          final deletedItem = _deletedItems[index];
                          final item = deletedItem.item;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Item Preview
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deleted: ${_formatDate(deletedItem.deletedAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                      Text(
                                        'Auto-deletes in: ${deletedItem.daysUntilPermanentDelete} days',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppConstants.deepGold,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Action Buttons
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _restoreItem(deletedItem),
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            side: BorderSide(
                                              color: AppConstants.royalBlue,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.restore,
                                                size: 16,
                                                color: AppConstants.royalBlue,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Restore',
                                                style: TextStyle(
                                                  color: AppConstants.royalBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _permanentDeleteItem(deletedItem),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.withOpacity(0.1),
                                            foregroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.delete_forever,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('Delete Forever'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}