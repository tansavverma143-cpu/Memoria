import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/providers/subscription_provider.dart';
import 'package:memoria/services/ai_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  XFile? _selectedImage;
  String? _ocrText;
  bool _isProcessing = false;
  bool _isUploading = false;
  
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _ocrText = null;
        });
        
        // Auto-generate title from filename
        final fileName = image.name.split('.').first;
        _titleController.text = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
        
        // Process OCR in background
        _processOCR(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _processOCR(String imagePath) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final text = await AIService().processImageWithOCR(imagePath);
      setState(() {
        _ocrText = text;
      });
      
      // Auto-fill description with OCR text
      if (text.isNotEmpty && _descriptionController.text.isEmpty) {
        _descriptionController.text = text.substring(0, 200);
      }
    } catch (e) {
      print('OCR Error: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  Future<void> _saveImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    
    // Get file size
    final file = await _selectedImage!.readAsBytes();
    final fileSize = file.length;
    
    // Check subscription limits
    if (!subscriptionProvider.canSaveItem(fileSize)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        type: ItemType.photo,
        title: _titleController.text.trim(),
        content: _descriptionController.text.trim(),
        filePath: _selectedImage!.path,
        fileExtension: '.jpg',
        fileSize: fileSize,
      );
      
      // Add OCR text
      if (_ocrText != null) {
        item.ocrText = _ocrText;
        item.content += '\n\nOCR Text:\n$_ocrText';
      }
      
      // Auto-categorize
      item.detectedCategory = AIService.detectCategory(
        item.content,
        ItemType.photo,
      );
      item.tags = AIService.extractTags(item.content);
      
      // Save to storage
      await StorageService.saveItem(item);
      subscriptionProvider.incrementSaves();
      subscriptionProvider.addStorageUsed(fileSize);
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upload Photo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Preview
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.dashed,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 80,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to select photo',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'or take a new one',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Capture Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.royalBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Take Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, color: AppConstants.royalBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: AppConstants.royalBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Title
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hintText: 'Enter a title for this photo',
              prefixIcon: Icons.title,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hintText: 'Describe what this photo is about',
              prefixIcon: Icons.description,
              maxLines: 4,
              minLines: 2,
            ),
            
            const SizedBox(height: 32),
            
            // OCR Processing
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppConstants.royalBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.royalBlue),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processing Image',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Extracting text with AI...',
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
            
            if (_ocrText != null && !_isProcessing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.deepGold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppConstants.deepGold.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          color: AppConstants.deepGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Text Detected',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.deepGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ocrText!.length > 200
                          ? '${_ocrText!.substring(0, 200)}...'
                          : _ocrText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // AI Features Info
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
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppConstants.deepGold,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI-Powered Features',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFeatureChip('Auto-Categorize'),
                      _buildFeatureChip('Text Extraction'),
                      _buildFeatureChip('Smart Tags'),
                      _buildFeatureChip('Date Detection'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _isUploading ? null : _saveImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppConstants.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isUploading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
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
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.royalBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.royalBlue.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppConstants.royalBlue,
        ),
      ),
    );
  }
}