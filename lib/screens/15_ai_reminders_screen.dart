import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/reminder_tile.dart';

class AIRemindersScreen extends StatefulWidget {
  const AIRemindersScreen({super.key});

  @override
  State<AIRemindersScreen> createState() => _AIRemindersScreenState();
}

class _AIRemindersScreenState extends State<AIRemindersScreen> {
  List<SavedItem> _itemsWithReminders = [];
  List<Map<String, dynamic>> _aiDetectedReminders = [];
  
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }
  
  void _loadReminders() {
    final allItems = StorageService.getAllItems();
    _itemsWithReminders = allItems.where((item) => item.reminderDate != null).toList();
    
    // Simulate AI-detected reminders
    _aiDetectedReminders = [
      {
        'title': 'Passport Expiry',
        'date': DateTime.now().add(const Duration(days: 60)),
        'itemId': 'item_1',
        'detected': true,
      },
      {
        'title': 'Insurance Renewal',
        'date': DateTime.now().add(const Duration(days: 30)),
        'itemId': 'item_2',
        'detected': true,
      },
      {
        'title': 'Bill Payment Due',
        'date': DateTime.now().add(const Duration(days: 7)),
        'itemId': 'item_3',
        'detected': true,
      },
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Detection Card
          Container(
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
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Reminder Detection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Automatically detects due dates, expiry dates, and renewals',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Active Reminders'),
                      Tab(text: 'AI Detected'),
                    ],
                    indicatorColor: AppConstants.royalBlue,
                    labelColor: AppConstants.royalBlue,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Active Reminders
                        _itemsWithReminders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      size: 80,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Active Reminders',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add reminders to your items',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _itemsWithReminders.length,
                                itemBuilder: (context, index) {
                                  final item = _itemsWithReminders[index];
                                  return ReminderTile(
                                    title: item.title,
                                    subtitle: item.detectedCategory ?? 'No category',
                                    date: item.reminderDate!,
                                    isCompleted: false,
                                    onToggle: () {},
                                    onDelete: () {},
                                  );
                                },
                              ),
                        
                        // AI Detected
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ..._aiDetectedReminders.map((reminder) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppConstants.deepGold.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: AppConstants.deepGold,
                                    ),
                                  ),
                                  title: Text(reminder['title']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Detected from: Item #${reminder['itemId']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Due: ${_formatDate(reminder['date'])}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add_alert),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            
                            const SizedBox(height: 20),
                            
                            // AI Capabilities
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
                                        Icons.psychology,
                                        color: AppConstants.deepGold,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'AI Can Detect:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetectionCapability('Due dates in bills'),
                                  _buildDetectionCapability('Expiry dates in IDs'),
                                  _buildDetectionCapability('Renewal dates'),
                                  _buildDetectionCapability('Appointments in notes'),
                                  _buildDetectionCapability('Follow-up dates'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetectionCapability(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppConstants.deepGold,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}