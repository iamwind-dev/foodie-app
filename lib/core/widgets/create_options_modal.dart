import 'package:flutter/material.dart';

class CreateOptionsModal extends StatelessWidget {
  final VoidCallback onCreateRecipe;
  final VoidCallback onGenerateRecipe;
  final VoidCallback onScanRecipe;

  const CreateOptionsModal({
    super.key,
    required this.onCreateRecipe,
    required this.onGenerateRecipe,
    required this.onScanRecipe,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onCreateRecipe,
    required VoidCallback onGenerateRecipe,
    required VoidCallback onScanRecipe,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0.9),
      builder: (context) => CreateOptionsModal(
        onCreateRecipe: onCreateRecipe,
        onGenerateRecipe: onGenerateRecipe,
        onScanRecipe: onScanRecipe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 200,
        height: 163,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              icon: 'assets/img/create_icon.png',
              text: 'Create your own recipe',
              onTap: () {
                Navigator.of(context).pop();
                onCreateRecipe();
              },
            ),
            const SizedBox(height: 34),
            _buildOption(
              icon: 'assets/img/generate_icon.png',
              text: 'Generate a recipe',
              onTap: () {
                Navigator.of(context).pop();
                onGenerateRecipe();
              },
            ),
            const SizedBox(height: 39),
            _buildOption(
              icon: 'assets/img/scan_icon.png',
              text: 'Scan a recipe',
              onTap: () {
                Navigator.of(context).pop();
                onScanRecipe();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
