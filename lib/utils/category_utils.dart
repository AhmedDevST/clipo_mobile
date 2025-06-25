import 'package:flutter/material.dart';

class CategoryUtils {
  // Available colors with their string identifiers
  static const Map<String, Color> colors = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'pink': Colors.pink,
    'amber': Colors.amber,
    'deepOrange': Colors.deepOrange,
    'blueGrey': Colors.blueGrey,
    'cyan': Colors.cyan,
  };

  // Available icons with their string identifiers
  static const Map<String, IconData> icons = {
    'bookmark': Icons.bookmark_outline,
    'folder': Icons.folder_outlined,
    'file': Icons.insert_drive_file_outlined,
    'link': Icons.link,
    'globe': Icons.public,
    'star': Icons.star_outline,
    'category': Icons.category_outlined,
    'work': Icons.work_outline,
    'business': Icons.business,
    'school': Icons.school_outlined,
    'home': Icons.home_outlined,
    'shopping': Icons.shopping_cart_outlined,
    'sports': Icons.sports_soccer_outlined,
    'movie': Icons.movie_outlined,
    'music': Icons.music_note_outlined,
    'photo': Icons.photo_outlined,
    'book': Icons.book_outlined,
    'favorite': Icons.favorite_outline,
    'computer': Icons.computer,
    'phone': Icons.phone_outlined,
    'car': Icons.directions_car_outlined,
    'flight': Icons.flight_outlined,
    'restaurant': Icons.restaurant_outlined,
    'health': Icons.health_and_safety_outlined,
    'fitness': Icons.fitness_center_outlined,
    'games': Icons.games_outlined,
    'news': Icons.newspaper,
    'settings': Icons.settings_outlined,
    'palette': Icons.palette_outlined,
  };

  // Get color from string name
  static Color getColorFromName(String? colorName) {
    return colors[colorName] ?? Colors.blue;
  }

  // Get icon from string name
  static IconData getIconFromName(String? iconName) {
    return icons[iconName] ?? Icons.category_outlined;
  }

  // Get color name from Color object (useful for reverse lookup)
  static String getColorName(Color color) {
    for (final entry in colors.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return 'blue'; // default
  }

  // Get icon name from IconData object (useful for reverse lookup)
  static String getIconName(IconData icon) {
    for (final entry in icons.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return 'category'; // default
  }

  // Get all available colors as a list of maps for UI
  static List<Map<String, dynamic>> getAvailableColors() {
    return colors.entries
        .map((entry) => {
              'name': entry.key,
              'color': entry.value,
            })
        .toList();
  }

  // Get all available icons as a list of maps for UI
  static List<Map<String, dynamic>> getAvailableIcons() {
    return icons.entries
        .map((entry) => {
              'name': entry.key,
              'icon': entry.value,
            })
        .toList();
  }

  // Create a category chip widget for display
  static Widget buildCategoryChip({
    required String name,
    String? colorName,
    String? iconName,
    double? fontSize,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    final color = getColorFromName(colorName);
    final icon = getIconFromName(iconName);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: fontSize != null ? fontSize * 0.9 : 12,
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: fontSize ?? 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create a category avatar (circular icon with color background)
  static Widget buildCategoryAvatar({
    String? colorName,
    String? iconName,
    double size = 40,
  }) {
    final color = getColorFromName(colorName);
    final icon = getIconFromName(iconName);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  // Validate color name
  static bool isValidColorName(String? colorName) {
    return colorName != null && colors.containsKey(colorName);
  }

  // Validate icon name
  static bool isValidIconName(String? iconName) {
    return iconName != null && icons.containsKey(iconName);
  }

  // Get default category data
  static Map<String, String> getDefaultCategoryData() {
    return {
      'color': 'blue',
      'icon': 'category',
    };
  }
}