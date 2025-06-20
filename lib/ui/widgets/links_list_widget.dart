import 'package:flutter/material.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/ui/widgets/slidable_link_item.dart'; 

class LinksListWidget extends StatelessWidget {
  final List<LinkModel> links;
  final void Function(LinkModel) onTap;
  final void Function(LinkModel) onDelete;
  final void Function(LinkModel) onToggleFavorite;
  final void Function(LinkModel) onShare;
  final Animation<double>? fadeAnimation;

  const LinksListWidget({
    super.key,
    required this.links,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onShare,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SlidableLinkItem(
            link: link,
            onTap: () => onTap(link),
            onDelete: () => onDelete(link),
            onToggleFavorite: () => onToggleFavorite(link),
            onShare: () => onShare(link),
          ),
        );
      },
    );

    if (fadeAnimation != null) {
      return FadeTransition(opacity: fadeAnimation!, child: listView);
    } else {
      return listView;
    }
  }
}
