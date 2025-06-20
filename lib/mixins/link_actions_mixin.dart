// mixins/link_actions_mixin.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/ui/widgets/dialog/ConfirmationDialog.dart';

mixin LinkActionsMixin<T extends StatefulWidget> on State<T> {
  LinkRepo get linkRepo;
  List<LinkModel> get links;
  set links(List<LinkModel> value);
  
  Future<void> reloadLinks();

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
        showSuccessSnackBar('Link deleted successfully', Colors.red[600]!);
      } catch (e) {
        showErrorSnackBar('Error deleting link: $e');
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
      
      showSuccessSnackBar(
        updatedLink.isFavorite
            ? 'Added to favorites'
            : 'Removed from favorites',
        updatedLink.isFavorite ? Colors.pink[600]! : Colors.grey[600]!,
      );
    } catch (e) {
      showErrorSnackBar('Error updating favorite: $e');
    }
  }

  Future<void> shareLink(LinkModel link) async {
    showSuccessSnackBar('Sharing: ${link.title}', Colors.blue[600]!);
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
      showErrorSnackBar('Error updating link: $e');
    }
  }

  void handleLinkTap(LinkModel link) async {
    if (link.url != null) {
      await launchURL(link.url!);
      await updateLastVisite(link);
    }
  }

  // UI feedback methods
  void showSuccessSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}