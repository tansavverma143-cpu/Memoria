import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';

class ReminderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  
  const ReminderTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) => onToggle(),
          activeColor: AppConstants.royalBlue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}