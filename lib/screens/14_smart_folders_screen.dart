import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/folder_card.dart';

class SmartFoldersScreen extends StatefulWidget {
  const SmartFoldersScreen({super.key});

  @override
  State<SmartFoldersScreen> createState() => _SmartFoldersScreenState();
}

class _SmartFoldersScreenState extends State<SmartFoldersScreen> {
  List<Folder> _folders = [];
  List<Folder> _smartFolders = [];
  
  @override
  void initState() {
    super.initState();
    _loadFolders();
  }
  
  void _loadFolders() {
    _folders = StorageService.getAllFolders();
    _smartFolders = _folders.where((f) => f.isSmartFolder).toList();
  }
  
  void _createSmartFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Smart Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Folder Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Smart folders auto-organize items based on rules'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create folder
              Navigator.pop(context);
            },
            child: const Text('Create'),
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
        title: const Text('Smart Folders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createSmartFolder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Folders Header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppConstants.deepGold,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Smart Folders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Auto-organized folders that update based on rules',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Smart Folders Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _smartFolders.length + 1,
              itemBuilder: (context, index) {
                if (index < _smartFolders.length) {
                  return FolderCard(folder: _smartFolders[index]);
                }
                return GestureDetector(
                  onTap: _createSmartFolder,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        style: BorderStyle.dashed,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 32),
                        SizedBox(height: 8),
                        Text('Create Smart Folder'),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Rules Examples
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.royalBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstants.royalBlue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Folder Rules Examples:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRuleExample('Bills from last month', 'Type: Bill, Date: Last 30 days'),
                  _buildRuleExample('All travel documents', 'Category: Travel OR Tags: travel'),
                  _buildRuleExample('Important IDs', 'Type: ID AND isVault: true'),
                  _buildRuleExample('Work documents', 'Category: Work OR Title contains: work'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // All Folders
            const Text(
              'All Folders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: folder.isSmartFolder
                          ? AppConstants.deepGold.withOpacity(0.1)
                          : AppConstants.royalBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      folder.isSmartFolder ? Icons.auto_awesome : Icons.folder,
                      color: folder.isSmartFolder ? AppConstants.deepGold : AppConstants.royalBlue,
                    ),
                  ),
                  title: Text(folder.name),
                  subtitle: Text('${folder.itemCount} items'),
                  trailing: folder.isSmartFolder
                      ? Chip(
                          label: const Text('Smart'),
                          backgroundColor: AppConstants.deepGold.withOpacity(0.1),
                          labelStyle: TextStyle(color: AppConstants.deepGold),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRuleExample(String title, String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chevron_right, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  rule,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}