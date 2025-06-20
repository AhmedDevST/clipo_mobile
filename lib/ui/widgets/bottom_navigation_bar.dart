import 'package:clipo_app/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/ui/screens/categories/categoires_screen.dart';
import 'package:clipo_app/ui/screens/links/serach_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:clipo_app/ui/screens/links/favorites.dart';
class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;

  const BottomNavigationBarWidget({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CategoriesScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
        break;
      // Add navigation for other indexes if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: selectedIndex,
      onTap: (i) => _handleNavigation(context, i),
      items: [
        /// Home
        SalomonBottomBarItem(
          icon: Icon(Icons.home),
          title: Text("Home"),
          selectedColor: Colors.purple,
        ),

        /// Categories
        SalomonBottomBarItem(
          icon: Icon(Icons.category),
          title: Text("Categories"),
          selectedColor: Colors.pink,
        ),

        /// favorites
        SalomonBottomBarItem(
          icon: Icon(Icons.favorite),
          title: Text("Favorites"),
          selectedColor: Colors.orange,
        ),

         /// settings
        SalomonBottomBarItem(
          icon: Icon(Icons.settings),
          title: Text("settings"),
          selectedColor: Colors.pink,
        ),

      ],
    );
  }
}
