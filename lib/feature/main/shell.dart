import 'package:flutter/material.dart';
import '../home/screen/home_screen.dart';
import '../shoppinglist/screen/shoppinglist_screen.dart';
import '../AI/capture/screen/AIcaprecipe_screen.dart';
import '../recipecreate/screen/recipecreate_screen.dart';
import '../AI/form/screen/AIrecipe_screen.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../../core/constants/navigation_constants.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = NavigationIndex.home;
  // Lazily create pages so heavy screens (camera) aren't built on app start.
  final List<Widget?> _pages = List.filled(5, null);

  Widget _pageAt(int index) {
    if (_pages[index] != null) return _pages[index]!;
    switch (index) {
      case NavigationIndex.home:
        _pages[index] = const HomeScreen();
        break;
      case NavigationIndex.shoppingList:
        _pages[index] = const ShoppingListScreen();
        break;
      case NavigationIndex.scan:
        _pages[index] = const AICaptureRecipeScreen();
        break;
      case NavigationIndex.recipeCreate:
        _pages[index] = const RecipeCreateScreen();
        break;
      case NavigationIndex.aiRecipe:
        _pages[index] = const AIRecipeScreen();
        break;
      default:
        _pages[index] = const SizedBox.shrink();
    }
    return _pages[index]!;
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_pages.length, (i) {
          // Only build the currently selected page; keep others as placeholders until needed.
          if (i == _currentIndex) return _pageAt(i);
          return _pages[i] ?? const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        isFixed: true,
      ),
    );
  }
}

