import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/ui/widgets/link_card.dart';

class SlidableLinkItem extends StatelessWidget {
  final LinkModel link;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;

  const SlidableLinkItem({
    super.key,
    required this.link,
    this.onTap,
    this.onDelete,
    this.onToggleFavorite,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(link.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onTap?.call(),
            backgroundColor: Colors.teal[400]!,
            foregroundColor: Colors.white,
            icon: Icons.open_in_browser,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onShare?.call(),
            backgroundColor: Colors.blue[600]!,
            foregroundColor: Colors.white,
            icon: Icons.share_outlined,
          ),
          SlidableAction(
            onPressed: (context) => onDelete?.call(),
            backgroundColor: Colors.red[600]!,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child:  Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LinkCard(link: link, onToggleFavorite: onToggleFavorite),
        ),
    );
  }
}
