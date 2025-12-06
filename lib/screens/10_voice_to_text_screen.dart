import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/services/ai_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';

class VoiceToTextScreen extends StatefulWidget {
  const VoiceToTextScreen({super.key});

  @override
  State<VoiceToTextScreen> createState() => _VoiceToTextScreenState();
}

class _VoiceToTextScreenState extends State<VoiceToTextScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  
  final AIService _aiService = AIService();
  bool _isListening = false;
  bool _isProcessing = false;
  String _status = 'Tap microphone to start';
  
  @override
  void initState() {
    super.initState();
    _titleController.text = 'Voice Note ${DateTime.now().hour}:${DateTime.now().minute}';
  }
  
  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _status = 'Listening... Speak now';
    });
    
    final result = await _aiService.startListening();
    
    setState(() {
      _textController.text = result;
      _isListening = false;
      _status = 'Ready to save';
    });
  }
  
  Future<void> _stopListening() async {
    await _aiService.stopListening();
    setState(() {
      _isListening = false;
      _status = 'Stopped';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Voice to Text'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Title
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hintText: 'Enter title',
              prefixIcon: Icons.title,
            ),
            
            const SizedBox(height: 24),
            
            // Voice Controls
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
                children: [
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : AppConstants.royalBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : AppConstants.royalBlue).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    _status,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    _isListening ? 'Tap to stop' : 'Tap to start recording',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Text Output
            CustomTextField(
              controller: _textController,
              label: 'Transcribed Text',
              hintText: 'Voice text will appear here...',
              maxLines: 10,
              minLines: 5,
              prefixIcon: Icons.text_fields,
            ),
            
            const SizedBox(height: 32),
            
            // AI Features
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
                          'AI Will Process',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.deepGold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Auto-categorize, extract keywords, set reminders',
                          style: Theme.of(context).textTheme.bodySmall,
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
              onPressed: () {},
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
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Save Voice Note',
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
}