import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

/// Utility class for showing awesome snackbars and material banners
class AwesomeSnackBarUtils {
  /// Show an awesome snackbar with customizable content
  static void showSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      action: action,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show an awesome material banner with customizable content
  static void showMaterialBanner({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
    List<Widget>? actions,
    bool forceActionsBelow = true,
  }) {
    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: forceActionsBelow,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: true,
      ),
      actions: actions ?? [const SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);
  }

  /// Show success snackbar
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.success,
      duration: duration,
      action: action,
    );
  }

  /// Show error snackbar
  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.failure,
      duration: duration,
      action: action,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Show help/info snackbar
  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.help,
      duration: duration,
      action: action,
    );
  }

  /// Hide current snackbar
  static void hideSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Hide current material banner
  static void hideMaterialBanner(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }
}

/// Reusable SnackBar Widget Component
class AwesomeSnackBarWidget extends StatelessWidget {
  final String title;
  final String message;
  final ContentType contentType;
  final bool inMaterialBanner;

  const AwesomeSnackBarWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.contentType,
    this.inMaterialBanner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType,
      inMaterialBanner: inMaterialBanner,
    );
  }
}

/// Extension method for easier access from any BuildContext
extension AwesomeSnackBarExtension on BuildContext {
  /// Show success message
  void showSuccessSnackBar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    AwesomeSnackBarUtils.showSuccess(
      context: this,
      title: title,
      message: message,
      duration: duration,
      action: action,
    );
  }

  /// Show error message
  void showErrorSnackBar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    AwesomeSnackBarUtils.showError(
      context: this,
      title: title,
      message: message,
      duration: duration,
      action: action,
    );
  }

  /// Show warning message
  void showWarningSnackBar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    AwesomeSnackBarUtils.showWarning(
      context: this,
      title: title,
      message: message,
      duration: duration,
      action: action,
    );
  }

  /// Show info message
  void showInfoSnackBar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    AwesomeSnackBarUtils.showInfo(
      context: this,
      title: title,
      message: message,
      duration: duration,
      action: action,
    );
  }

  /// Show custom snackbar
  void showAwesomeSnackBar({
    required String title,
    required String message,
    required ContentType contentType,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    AwesomeSnackBarUtils.showSnackBar(
      context: this,
      title: title,
      message: message,
      contentType: contentType,
      duration: duration,
      action: action,
    );
  }

  /// Show material banner
  void showAwesomeMaterialBanner({
    required String title,
    required String message,
    required ContentType contentType,
    List<Widget>? actions,
    bool forceActionsBelow = true,
  }) {
    AwesomeSnackBarUtils.showMaterialBanner(
      context: this,
      title: title,
      message: message,
      contentType: contentType,
      actions: actions,
      forceActionsBelow: forceActionsBelow,
    );
  }
}

