import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/providers/subscription_provider.dart';
import 'package:memoria/services/ai_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class DocUploadScreen extends StatefulWidget {
  const DocUploadScreen({super.key});

  @override
  State<DocUploadScreen> createState() => _DocUploadScreenState();
}

class _DocUploadScreenState extends State<DocUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  PlatformFile? _selectedFile;
  String? _ocrText;
  bool _isProcessing = false;
  bool _isUploading = false;
  
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.documentExtensions.map((e) => e.substring(1)).toList(),
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _ocrText = null;
        });
        
        // Auto-generate title from filename
        final fileName = _selectedFile!.name.split('.').first;
        _titleController.text = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
        
        // Process OCR for PDFs and images
        if (_selectedFile!.path != null && _selectedFile!.path!.endsWith('.pdf')) {
          // For PDFs, we would use a PDF text extraction library
          // This is simplified for demo
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _ocrText = 'PDF content extracted (simulated)';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _saveDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    
    // Check subscription limits
    if (!subscriptionProvider.canSaveItem(_selectedFile!.size)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage limit reached. Upgrade your plan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Create item
      final item = SavedItem.create(
        type: _getItemType(_selectedFile!.extension!),
        title: _titleController.text.trim(),
        content: _descriptionController.text.trim(),
        filePath: _selectedFile!.path,
        fileExtension: _selectedFile!.extension,
        fileSize: _selectedFile!.size,
      );
      
      // Add OCR text if available
      if (_ocrText != null) {
        item.ocrText = _ocrText;
        item.content += '\n\nExtracted Text:\n$_ocrText';
      }
      
      // Auto-categorize
      item.detectedCategory = AIService.detectCategory(
        item.content,
        item.type,
      );
      item.tags = AIService.extractTags(item.content);
      
      // Detect if it's a bill or receipt
      if (_selectedFile!.name.toLowerCase().contains('bill') ||
          _selectedFile!.name.toLowerCase().contains('invoice')) {
        item.type = ItemType.bill;
      } else if (_selectedFile!.name.toLowerCase().contains('receipt')) {
        item.type = ItemType.receipt;
      }
      
      // Save to storage
      await StorageService.saveItem(item);
      subscriptionProvider.incrementSaves();
      subscriptionProvider.addStorageUsed(_selectedFile!.size);
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  ItemType _getItemType(String extension) {
    if (AppConstants.imageExtensions.contains('.$extension')) {
      return ItemType.photo;
    } else if (AppConstants.documentExtensions.contains('.$extension')) {
      return ItemType.document;
    }
    return ItemType.document;
  }
  
  String _getFileIcon(String? extension) {
    if (extension == null) return '📄';
    
    if (extension.contains('pdf')) return '📕';
    if (extension.contains('doc')) return '📘';
    if (extension.contains('xls')) return '📗';
    if (extension.contains('ppt')) return '📙';
    if (extension.contains('txt')) return '📝';
    return '📄';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upload Document'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // File Picker
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.dashed,
                  ),
                ),
                child: _selectedFile != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getFileIcon(_selectedFile!.extension),
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile!.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 80,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to select document',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PDF, DOC, XLS, PPT, TXT',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Upload Button
            ElevatedButton(
              onPressed: _pickDocument,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Select Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hintText: 'Enter document title',
              prefixIcon: Icons.title,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hintText: 'Describe this document',
              prefixIcon: Icons.description,
              maxLines: 4,
              minLines: 2,
            ),
            
            const SizedBox(height: 32),
            
            // Document Type Detection
            if (_selectedFile != null)
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
                            'AI Document Detection',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppConstants.deepGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedFile!.name.toLowerCase().contains('bill') ||
                                    _selectedFile!.name.toLowerCase().contains('invoice')
                                ? 'Detected as: Bill/Invoice'
                                : _selectedFile!.name.toLowerCase().contains('receipt')
                                    ? 'Detected as: Receipt'
                                    : 'Will auto-categorize based on content',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _isUploading ? null : _saveDocument,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isUploading
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
                        Icon(Icons.save, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Save Document',
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
          ],
        ),
      ),
    );
  }
}