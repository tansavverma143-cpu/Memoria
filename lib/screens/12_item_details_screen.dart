import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/ai_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';

class ItemDetailsScreen extends StatefulWidget {
  final SavedItem item;
  
  const ItemDetailsScreen({super.key, required this.item});
  
  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late SavedItem _item;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _titleController = TextEditingController(text: _item.title);
    _contentController = TextEditingController(text: _item.content);
  }
  
  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      _item.title = _titleController.text.trim();
      _item.content = _contentController.text.trim();
      _item.updatedAt = DateTime.now();
      
      // Re-run AI categorization
      _item.detectedCategory = AIService.detectCategory(_item.content, _item.type);
      _item.tags = AIService.extractTags(_item.content);
      
      await StorageService.saveItem(_item);
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  Future<void> _deleteItem() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.deleteItem(_item.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isEditing) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hintText: 'Enter title',
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contentController,
              label: 'Content',
              hintText: 'Enter content',
              maxLines: 10,
              minLines: 5,
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(_item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTypeColor(_item.type).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  _getTypeIcon(_item.type),
                  color: _getTypeColor(_item.type),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _item.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(_item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Category & Tags
          if (_item.detectedCategory != null || _item.tags.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_item.detectedCategory != null)
                  Row(
                    children: [
                      const Icon(Icons.category, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Category: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(_item.detectedCategory!),
                    ],
                  ),
                
                if (_item.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tags:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _item.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        backgroundColor: AppConstants.royalBlue.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          
          // Content
          Text(
            'Content',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              _item.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          // OCR Text
          if (_item.ocrText != null && _item.ocrText!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Extracted Text',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.deepGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstants.deepGold.withOpacity(0.2),
                ),
              ),
              child: Text(
                _item.ocrText!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          
          // AI Summary
          if (_item.aiSummary != null && _item.aiSummary!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'AI Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.royalBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstants.royalBlue.withOpacity(0.2),
                ),
              ),
              child: Text(
                _item.aiSummary!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          
          // Metadata
          if (_item.metadata != null && _item.metadata!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
                children: _item.metadata!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${entry.key}:',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Color _getTypeColor(ItemType type) {
    switch (type) {
      case ItemType.photo:
        return Colors.green;
      case ItemType.document:
        return Colors.orange;
      case ItemType.voice:
        return Colors.purple;
      case ItemType.link:
        return Colors.blue;
      default:
        return AppConstants.royalBlue;
    }
  }
  
  IconData _getTypeIcon(ItemType type) {
    switch (type) {
      case ItemType.text:
        return Icons.text_fields;
      case ItemType.photo:
        return Icons.photo;
      case ItemType.document:
        return Icons.description;
      case ItemType.voice:
        return Icons.mic;
      case ItemType.link:
        return Icons.link;
      default:
        return Icons.file_copy;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}