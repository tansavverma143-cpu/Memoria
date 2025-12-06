import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;
  
  const FolderCard({
    super.key,
    required this.folder,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Folder Icon
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (folder.color != null 
                          ? Color(int.parse('0xFF${folder.color!.substring(1)}'))
                          : AppConstants.royalBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (folder.color != null 
                            ? Color(int.parse('0xFF${folder.color!.substring(1)}'))
                            : AppConstants.royalBlue).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      folder.isSmartFolder ? Icons.auto_awesome : Icons.folder,
                      size: 20,
                      color: folder.color != null 
                          ? Color(int.parse('0xFF${folder.color!.substring(1)}'))
                          : AppConstants.royalBlue,
                    ),
                  ),
                  const Spacer(),
                  if (folder.isSmartFolder)
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppConstants.deepGold,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Folder Name
              Text(
                folder.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              
              if (folder.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  folder.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Item Count
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${folder.itemCount} items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(folder.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${date.day}/${date.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return 'Now';
    }
  }
}