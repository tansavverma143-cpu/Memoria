import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/deleted_item_model.dart';

class DeletedItemCard extends StatelessWidget {
  final DeletedItem deletedItem;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;
  
  const DeletedItemCard({
    super.key,
    required this.deletedItem,
    required this.onRestore,
    required this.onPermanentDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final item = deletedItem.item;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: deletedItem.isExpired ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: deletedItem.isExpired 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    deletedItem.isExpired ? Icons.warning : Icons.delete_outline,
                    color: deletedItem.isExpired ? Colors.red : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Type: ${item.type.toString().split('.').last}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Retention Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: deletedItem.isExpired 
                    ? Colors.red.withOpacity(0.05) 
                    : Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    deletedItem.isExpired ? Icons.warning_amber : Icons.access_time,
                    size: 16,
                    color: deletedItem.isExpired ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deletedItem.isExpired
                          ? 'Expired - Will be permanently deleted soon'
                          : 'Auto-deletes in ${deletedItem.daysUntilPermanentDelete} days',
                      style: TextStyle(
                        fontSize: 12,
                        color: deletedItem.isExpired ? Colors.red : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRestore,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: AppConstants.royalBlue,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restore,
                          size: 16,
                          color: AppConstants.royalBlue,
                        ),
                        const SizedBox(width: 8),
                        const Text('Restore'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPermanentDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_forever,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}