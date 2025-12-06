import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/screens/item_details_screen.dart';

class ItemCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback? onTap;
  final bool showMenu;
  
  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.showMenu = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.pushNamed(
          context,
          RouteConstants.itemDetails,
          arguments: item,
        );
      },
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
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Type Icon
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getTypeColor(item.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTypeColor(item.type).withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          _getTypeIcon(item.type),
                          size: 20,
                          color: _getTypeColor(item.type),
                        ),
                      ),
                      const Spacer(),
                      if (item.isVaultItem)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.deepGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppConstants.deepGold.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: AppConstants.deepGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Vault',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.deepGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Content Preview
                  Text(
                    _getContentPreview(item.content),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Tags & Date
                  Row(
                    children: [
                      // Tags
                      if (item.tags.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: item.tags.take(2).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppConstants.royalBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppConstants.royalBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      
                      // Date
                      Text(
                        _formatDate(item.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Category Badge
            if (item.detectedCategory != null)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    item.detectedCategory!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Color _getTypeColor(ItemType type) {
    switch (type) {
      case ItemType.photo:
      case ItemType.screenshot:
        return Colors.green;
      case ItemType.document:
      case ItemType.bill:
      case ItemType.receipt:
        return Colors.orange;
      case ItemType.voice:
        return Colors.purple;
      case ItemType.link:
        return Colors.blue;
      case ItemType.id:
      case ItemType.certificate:
        return Colors.red;
      case ItemType.note:
      case ItemType.task:
        return AppConstants.deepGold;
      default:
        return AppConstants.royalBlue;
    }
  }
  
  IconData _getTypeIcon(ItemType type) {
    switch (type) {
      case ItemType.text:
        return Icons.text_fields;
      case ItemType.photo:
      case ItemType.screenshot:
        return Icons.photo;
      case ItemType.document:
        return Icons.description;
      case ItemType.voice:
        return Icons.mic;
      case ItemType.link:
        return Icons.link;
      case ItemType.bill:
        return Icons.receipt_long;
      case ItemType.receipt:
        return Icons.receipt;
      case ItemType.id:
        return Icons.badge;
      case ItemType.certificate:
        return Icons.verified;
      case ItemType.note:
        return Icons.note;
      case ItemType.task:
        return Icons.task;
      default:
        return Icons.file_copy;
    }
  }
  
  String _getContentPreview(String content) {
    if (content.length > 100) {
      return '${content.substring(0, 100)}...';
    }
    return content;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}