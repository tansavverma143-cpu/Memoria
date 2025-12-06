import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final List<ActivityLog> _activities = [];
  final Map<String, List<ActivityLog>> _groupedActivities = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadActivities();
  }
  
  void _loadActivities() {
    // Sample activity data
    final now = DateTime.now();
    
    _activities.addAll([
      ActivityLog(
        id: '1',
        type: ActivityType.save,
        title: 'Saved Passport',
        description: 'Added new ID document',
        timestamp: now.subtract(const Duration(minutes: 5)),
        itemId: 'item_1',
        metadata: {'category': 'ID'},
      ),
      ActivityLog(
        id: '2',
        type: ActivityType.category,
        title: 'Auto-Categorized',
        description: 'Bill categorized as "Financial"',
        timestamp: now.subtract(const Duration(minutes: 30)),
        itemId: 'item_2',
        metadata: {'category': 'Financial'},
      ),
      ActivityLog(
        id: '3',
        type: ActivityType.delete,
        title: 'Moved to Trash',
        description: 'Old receipt deleted',
        timestamp: now.subtract(const Duration(hours: 2)),
        itemId: 'item_3',
        metadata: {'restore_days': 30},
      ),
      ActivityLog(
        id: '4',
        type: ActivityType.restore,
        title: 'Item Restored',
        description: 'Restored from Recently Deleted',
        timestamp: now.subtract(const Duration(hours: 3)),
        itemId: 'item_4',
      ),
      ActivityLog(
        id: '5',
        type: ActivityType.ai,
        title: 'AI Reminder Created',
        description: 'Detected passport expiry date',
        timestamp: now.subtract(const Duration(days: 1)),
        itemId: 'item_5',
        metadata: {'reminder_date': '2024-12-31'},
      ),
      ActivityLog(
        id: '6',
        type: ActivityType.backup,
        title: 'Backup Created',
        description: 'Encrypted backup saved',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      ActivityLog(
        id: '7',
        type: ActivityType.upgrade,
        title: 'Plan Upgraded',
        description: 'Upgraded to PRO plan',
        timestamp: now.subtract(const Duration(days: 3)),
        metadata: {'plan': 'PRO', 'amount': '\$4.99'},
      ),
      ActivityLog(
        id: '8',
        type: ActivityType.share,
        title: 'Item Shared',
        description: 'Shared document via email',
        timestamp: now.subtract(const Duration(days: 4)),
        itemId: 'item_6',
      ),
    ]);
    
    // Group by date
    _groupActivities();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _groupActivities() {
    _groupedActivities.clear();
    
    for (final activity in _activities) {
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.timestamp);
      _groupedActivities.putIfAbsent(dateKey, () => []);
      _groupedActivities[dateKey]!.add(activity);
    }
    
    // Sort groups by date (newest first)
    final sortedKeys = _groupedActivities.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    final sortedMap = <String, List<ActivityLog>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = _groupedActivities[key]!;
    }
    
    _groupedActivities.clear();
    _groupedActivities.addAll(sortedMap);
  }
  
  String _formatGroupDate(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Activity Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConstants.royalBlue,
              ),
            )
          : _activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Activity Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your activities will appear here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Card
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
                          _buildStat('Total', _activities.length.toString()),
                          _buildStat('This Week', '12'),
                          _buildStat('AI Actions', '3'),
                        ],
                      ),
                    ),
                    
                    // Activities List
                    Expanded(
                      child: ListView(
                        children: _groupedActivities.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  _formatGroupDate(entry.key),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ...entry.value.map((activity) {
                                return _buildActivityItem(activity);
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(ActivityLog activity) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getActivityColor(activity.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getActivityColor(activity.type).withOpacity(0.3),
            ),
          ),
          child: Icon(
            _getActivityIcon(activity.type),
            color: _getActivityColor(activity.type),
            size: 20,
          ),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description),
            const SizedBox(height: 4),
            Text(
              _formatTime(activity.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        onTap: () {
          _showActivityDetails(activity);
        },
      ),
    );
  }
  
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.save:
        return Colors.green;
      case ActivityType.delete:
        return Colors.red;
      case ActivityType.restore:
        return Colors.orange;
      case ActivityType.category:
        return Colors.blue;
      case ActivityType.ai:
        return AppConstants.deepGold;
      case ActivityType.backup:
        return Colors.purple;
      case ActivityType.upgrade:
        return AppConstants.royalBlue;
      case ActivityType.share:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.save:
        return Icons.save;
      case ActivityType.delete:
        return Icons.delete;
      case ActivityType.restore:
        return Icons.restore;
      case ActivityType.category:
        return Icons.category;
      case ActivityType.ai:
        return Icons.auto_awesome;
      case ActivityType.backup:
        return Icons.backup;
      case ActivityType.upgrade:
        return Icons.workspace_premium;
      case ActivityType.share:
        return Icons.share;
      default:
        return Icons.history;
    }
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
  
  void _showActivityDetails(ActivityLog activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description),
            const SizedBox(height: 16),
            Text(
              'Time: ${DateFormat('MMM d, yyyy • hh:mm a').format(activity.timestamp)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (activity.itemId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Item ID: ${activity.itemId}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Activities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Activities', true),
            _buildFilterOption('Saves', false),
            _buildFilterOption('Deletions', false),
            _buildFilterOption('AI Actions', false),
            _buildFilterOption('Backups', false),
            _buildFilterOption('Upgrades', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterOption(String label, bool selected) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: AppConstants.royalBlue)
          : null,
      onTap: () {},
    );
  }
}

class ActivityLog {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? itemId;
  final Map<String, dynamic>? metadata;
  
  ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.itemId,
    this.metadata,
  });
}

enum ActivityType {
  save,
  delete,
  restore,
  category,
  ai,
  backup,
  upgrade,
  share,
}