import 'package:flutter/material.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/ui/widgets/slidable_link_item.dart'; 

class LinksListWidget extends StatelessWidget {
  final List<LinkModel> links;
  final void Function(LinkModel) onTap;
  final void Function(LinkModel) onDelete;
  final void Function(LinkModel) onToggleFavorite;
  final void Function(LinkModel) onShare;
  final void Function(LinkModel) onEdit;
  final Animation<double>? fadeAnimation;
  final bool hasMoreData;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const LinksListWidget({
    super.key,
    required this.links,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleFavorite,
    required this.onShare,
    this.fadeAnimation,
    required this.hasMoreData,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: links.length + (hasMoreData ? 1 : 0), // +1 for load more button
      itemBuilder: (context, index) {
        // If this is the last item and we have more data, show load more button
        if (index == links.length && hasMoreData) {
          return _buildLoadMoreButton(context);
        }

        // Otherwise, show the link item
        final link = links[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SlidableLinkItem(
            link: link,
            onEdit: () => onEdit(link),
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

  Widget _buildLoadMoreButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Center(
        child: isLoadingMore
            ? _buildLoadingIndicator()
            : _buildLoadMoreButtonWidget(context),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue[600] ?? Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading more links...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButtonWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLoadMore,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Load More Links',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}