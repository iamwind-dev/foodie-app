import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'feature/splash/screen/splash_screen.dart';
import 'feature/login/screen/login_screen.dart';
import 'feature/register/screen/register_screen.dart';
import 'feature/main/shell.dart';
import 'feature/recipe/screen/recipe_screen.dart';
import 'feature/recipecreate/screen/recipecreate_screen.dart';
import 'feature/setting/screen/setting_screen.dart';
import 'feature/changepassword/screen/changepassword_screen.dart';
import 'feature/AI/form/screen/AIrecipe_screen.dart';
import 'feature/AI/capture/screen/AIcaprecipe_screen.dart';
import 'feature/shoppinglist/screen/shoppinglist_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Foodie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCAFCDF)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const MainShell(),
        AppRoutes.recipe: (context) => const RecipeScreen(),
        AppRoutes.recipeCreate: (context) => const RecipeCreateScreen(),
        AppRoutes.setting: (context) => const SettingScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.aiRecipe: (context) => const AIRecipeScreen(),
        AppRoutes.aiCaptureRecipe: (context) => const AICaptureRecipeScreen(),
        AppRoutes.shoppingList: (context) => const ShoppingListScreen(),
      },
    );
  }
}
