import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/custom_textfield.dart';
import 'package:memoria/widgets/reminder_tile.dart';

class ManualRemindersScreen extends StatefulWidget {
  const ManualRemindersScreen({super.key});

  @override
  State<ManualRemindersScreen> createState() => _ManualRemindersScreenState();
}

class _ManualRemindersScreenState extends State<ManualRemindersScreen> {
  final List<Map<String, dynamic>> _reminders = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<SavedItem> _items = [];
  SavedItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _loadItems();
  }

  void _loadReminders() {
    // Load existing reminders from items
    final allItems = StorageService.getAllItems();
    for (final item in allItems) {
      if (item.reminderDate != null) {
        _reminders.add({
          'id': item.id,
          'title': item.title,
          'description': item.detectedCategory ?? 'No category',
          'date': item.reminderDate!,
          'item': item,
        });
      }
    }
    
    // Sort by date
    _reminders.sort((a, b) => a['date'].compareTo(b['date']));
  }

  void _loadItems() {
    _items = StorageService.getAllItems();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createReminder() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reminderDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Create reminder
    final newReminder = {
      'id': 'reminder_${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleController.text,
      'description': _descriptionController.text,
      'date': reminderDate,
      'item': _selectedItem,
    };

    setState(() {
      _reminders.add(newReminder);
      _reminders.sort((a, b) => a['date'].compareTo(b['date']));
    });

    // If linked to item, save reminder to item
    if (_selectedItem != null) {
      _selectedItem!.reminderDate = reminderDate;
      await StorageService.saveItem(_selectedItem!);
    }

    // Clear form
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedItem = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    
    // Remove reminder from item if linked
    if (reminder['item'] != null) {
      final item = reminder['item'] as SavedItem;
      item.reminderDate = null;
      await StorageService.saveItem(item);
    }

    setState(() {
      _reminders.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manual Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Create Reminder Card
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _titleController,
                    label: 'Reminder Title',
                    hintText: 'Enter reminder title',
                    prefixIcon: Icons.notifications,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description (Optional)',
                    hintText: 'Enter reminder description',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date & Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectTime,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime == null
                                    ? 'Select Time'
                                    : _selectedTime!.format(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Link to Item (Optional)
                  DropdownButtonFormField<SavedItem>(
                    decoration: InputDecoration(
                      labelText: 'Link to Item (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    value: _selectedItem,
                    items: _items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedItem = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Create Button
                  ElevatedButton(
                    onPressed: _createReminder,
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
                        Icon(Icons.add_alert, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Create Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Reminders List
          Expanded(
            child: _reminders.isEmpty
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
                          'No Reminders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first reminder',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      return ReminderTile(
                        title: reminder['title'],
                        subtitle: reminder['description'],
                        date: reminder['date'],
                        isCompleted: false,
                        onToggle: () {
                          // Mark as completed
                        },
                        onDelete: () => _deleteReminder(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}