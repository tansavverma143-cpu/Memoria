import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';

class VaultItemCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback onRemove;
  
  const VaultItemCard({
    super.key,
    required this.item,
    required this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppConstants.goldGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.type.toString().split('.').last} • ${_formatDate(item.createdAt)}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.lock_open),
          onPressed: onRemove,
          color: AppConstants.deepGold,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}