// mixins/link_actions_mixin.dart
import 'package:clipo_app/ui/screens/links/edit_link_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/ui/widgets/dialog/ConfirmationDialog.dart';
import 'package:clipo_app/ui/widgets/dialog/awesome_snackbar.dart';
import 'package:share_plus/share_plus.dart';
mixin LinkActionsMixin<T extends StatefulWidget> on State<T> {
  LinkRepo get linkRepo;
  List<LinkModel> get links;
  set links(List<LinkModel> value);

  Future<void> reloadLinks();

  // Simple pagination variables
  static const int _pageSize = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;

  // Pagination getters
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  // Reset pagination
  void resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;
  }

  // Update pagination state after loading
  void updatePaginationState(List<LinkModel> newLinks,
      {bool isLoadMore = false}) {
    if (isLoadMore) {
      _currentPage++;
      _hasMoreData = newLinks.length == _pageSize;
    } else {
      _currentPage = 0;
      _hasMoreData = newLinks.length == _pageSize;
    }
    _isLoadingMore = false;
  }

  // Generic load more method
  Future<void> loadMore({
    required Future<List<LinkModel>> Function(int limit, int offset)
        loadFunction,
  }) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final offset = (_currentPage + 1) * _pageSize;
      final newLinks = await loadFunction(_pageSize, offset);

      setState(() {
        links = [...links, ...newLinks];
        updatePaginationState(newLinks, isLoadMore: true);
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });

      if (mounted) {
        AwesomeSnackBarUtils.showError(
          context: context,
          title: 'Error',
          message: 'Error loading more links: $e',
        );
      }
    }
  }

  // Common link action methods
  Future<void> deleteLink(LinkModel link) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'confirmation',
        description: 'Are you sure you want to delete this?',
        lottieUrl:
            "https://lottie.host/728db5d2-c7eb-4150-bb0e-cc0cc1d1ad3e/0UrRRIVVSc.json",
        confirmText: 'Delete',
        cancelText: 'Cancel',
        color: Colors.red,
      ),
    );

    if (confirmed == true) {
      try {
        await linkRepo.deleteLink(link.id!);
        await reloadLinks();
        AwesomeSnackBarUtils.showSuccess(
            context: context,
            title: 'delete link',
            message: 'Link deleted successfully');
      } catch (e) {
        AwesomeSnackBarUtils.showError(
            context: context,
            title: 'delete link',
            message: 'Error deleting link: $e');
      }
    }
  }

  Future<void> toggleFavorite(LinkModel link) async {
    try {
      await linkRepo.toggleIsFavorite(link.id!);
      final updatedLink = link.copyWith(isFavorite: !link.isFavorite);

      setState(() {
        final index = links.indexWhere((l) => l.id == link.id);
        if (index != -1) {
          links[index] = updatedLink;
        }
      });
      AwesomeSnackBarUtils.showSuccess(
          context: context,
          title: 'Favorites',
          message: updatedLink.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites');
    } catch (e) {
      AwesomeSnackBarUtils.showError(
          context: context,
          title: 'Error',
          message: 'Error updating favorite: $e');
    }
  }

  Future<void> shareLink(LinkModel link) async {
    if (link.url != null) {
      Share.share(link.url);
    } else {
      AwesomeSnackBarUtils.showInfo(
          context: context, title: 'sharing', message: 'No URL to share');
    }
  }

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> updateLastVisite(LinkModel link) async {
    try {
      await linkRepo.updateLastVisite(link.id!);
      final updatedLink = link.copyWith(lastVisited: link.lastVisited);

      setState(() {
        final index = links.indexWhere((l) => l.id == link.id);
        if (index != -1) {
          links[index] = updatedLink;
        }
      });
    } catch (e) {
      AwesomeSnackBarUtils.showError(
          context: context, title: 'Error', message: 'Error updating link: $e');
    }
  }

  void handleLinkTap(LinkModel link) async {
    if (link.url != null) {
      await launchURL(link.url!);
      await updateLastVisite(link);
    }
  }

  void handleEditLink(LinkModel link) async {
    if (link != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditLinkScreen(
                  link: link,
                )),
      );
    }
  }
}
