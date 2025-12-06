import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/providers/subscription_provider.dart';
import 'package:memoria/screens/doc_upload_screen.dart';
import 'package:memoria/screens/photo_upload_screen.dart';
import 'package:memoria/screens/voice_to_text_screen.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class SaveAnythingScreen extends StatefulWidget {
  const SaveAnythingScreen({super.key});

  @override
  State<SaveAnythingScreen> createState() => _SaveAnythingScreenState();
}

class _SaveAnythingScreenState extends State<SaveAnythingScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  
  SaveMode _currentMode = SaveMode.text;
  
  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Save Anything'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Save Mode Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: SaveMode.values.map((mode) {
                  final isSelected = _currentMode == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMode = mode;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppConstants.royalBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getModeIcon(mode),
                              size: 20,
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getModeLabel(mode),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title Field
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hintText: 'Enter a title for this item',
              prefixIcon: Icons.title,
            ),
            
            const SizedBox(height: 24),
            
            // Content based on mode
            _buildContentSection(context),
            
            const SizedBox(height: 32),
            
            // Quick Save Options
            Text(
              'Quick Save',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildQuickOption(
                  icon: Icons.photo_camera,
                  label: 'Take Photo',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.photoUpload);
                  },
                ),
                _buildQuickOption(
                  icon: Icons.image,
                  label: 'Gallery',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.photoUpload);
                  },
                ),
                _buildQuickOption(
                  icon: Icons.picture_as_pdf,
                  label: 'Document',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.docUpload);
                  },
                ),
                _buildQuickOption(
                  icon: Icons.mic,
                  label: 'Voice Note',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.voiceToText);
                  },
                ),
                _buildQuickOption(
                  icon: Icons.link,
                  label: 'URL/Link',
                  color: Colors.blueAccent,
                  onTap: () {
                    setState(() {
                      _currentMode = SaveMode.link;
                    });
                  },
                ),
                _buildQuickOption(
                  icon: Icons.receipt_long,
                  label: 'Bill/Receipt',
                  color: Colors.red,
                  onTap: () {
                    // TODO: Implement bill/receipt capture
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // AI Suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.deepGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstants.deepGold.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppConstants.deepGold,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Will Help Organize',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.deepGold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This item will be automatically categorized and tagged',
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
            
            const SizedBox(height: 24),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Save to Memory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContentSection(BuildContext context) {
    switch (_currentMode) {
      case SaveMode.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _textController,
              label: '',
              hintText: 'Type or paste anything here...',
              maxLines: 8,
              minLines: 4,
              prefixIcon: null,
            ),
          ],
        );
        
      case SaveMode.link:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'URL/Link',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _linkController,
              label: '',
              hintText: 'https://example.com',
              prefixIcon: Icons.link,
              keyboardType: TextInputType.url,
            ),
          ],
        );
        
      case SaveMode.note:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _textController,
              label: '',
              hintText: 'Write your note here...',
              maxLines: 8,
              minLines: 4,
              prefixIcon: Icons.note,
            ),
          ],
        );
        
      case SaveMode.task:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _textController,
              label: '',
              hintText: 'Describe your task...',
              maxLines: 4,
              minLines: 2,
              prefixIcon: Icons.task,
            ),
          ],
        );
    }
  }
  
  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveItem() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final content = _currentMode == SaveMode.link 
        ? _linkController.text.trim()
        : _textController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check subscription limits
    if (!subscriptionProvider.canSaveItem(0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save limit reached. Upgrade your plan or watch an ad for more saves.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Create item
    final item = SavedItem.create(
      type: _getItemType(_currentMode),
      title: _titleController.text.trim(),
      content: content,
    );
    
    // Auto-categorize
    item.detectedCategory = AIService.detectCategory(content, item.type);
    item.tags = AIService.extractTags(content);
    
    // Save to storage
    await StorageService.saveItem(item);
    subscriptionProvider.incrementSaves();
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back
    Navigator.pop(context);
  }
  
  ItemType _getItemType(SaveMode mode) {
    switch (mode) {
      case SaveMode.text:
        return ItemType.text;
      case SaveMode.link:
        return ItemType.link;
      case SaveMode.note:
        return ItemType.note;
      case SaveMode.task:
        return ItemType.task;
    }
  }
  
  IconData _getModeIcon(SaveMode mode) {
    switch (mode) {
      case SaveMode.text:
        return Icons.text_fields;
      case SaveMode.link:
        return Icons.link;
      case SaveMode.note:
        return Icons.note;
      case SaveMode.task:
        return Icons.task;
    }
  }
  
  String _getModeLabel(SaveMode mode) {
    switch (mode) {
      case SaveMode.text:
        return 'Text';
      case SaveMode.link:
        return 'Link';
      case SaveMode.note:
        return 'Note';
      case SaveMode.task:
        return 'Task';
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}

enum SaveMode {
  text,
  link,
  note,
  task,
}