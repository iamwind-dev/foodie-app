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

  late final List<Widget> _pages = [
    const HomeScreen(),
    const ShoppingListScreen(),
    const AICaptureRecipeScreen(),
    const RecipeCreateScreen(),
    const AIRecipeScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        isFixed: true,
      ),
    );
  }
}

