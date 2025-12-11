import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/AIcaprecipe_cubit.dart';
import '../cubit/AIcaprecipe_state.dart';
import '../../../../core/constants/app_routes.dart';

class AICaptureRecipeScreen extends StatelessWidget {
  const AICaptureRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AICaptureRecipeCubit(),
      child: const AICaptureRecipeView(),
    );
  }
}

class AICaptureRecipeView extends StatefulWidget {
  const AICaptureRecipeView({super.key});

  @override
  State<AICaptureRecipeView> createState() => _AICaptureRecipeViewState();
}

class _AICaptureRecipeViewState extends State<AICaptureRecipeView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  String? _previewPath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );

    _initCamera();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isCameraError = true;
        });
        return;
      }
      if (_selectedCameraIndex >= _cameras.length) {
        _selectedCameraIndex = 0;
      }
      final camera = _cameras[_selectedCameraIndex];
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _isCameraError = false;
        _isFlashOn = false;
      });
    } catch (_) {
      setState(() {
        _isCameraError = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _cameraController == null || _isCameraError) {
      return;
    }
    try {
      final file = await _cameraController!.takePicture();
      context.read<AICaptureRecipeCubit>().onImageCaptured(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chụp ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _isCameraInitialized = false;
    await _cameraController?.dispose();
    setState(() {});
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không bật được đèn flash: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AICaptureRecipeCubit, AICaptureRecipeState>(
      listener: (context, state) {
        if (state is AICaptureRecipeCaptured) {
          setState(() {
            _previewPath = state.imagePath;
          });
          context.read<AICaptureRecipeCubit>().processImage(state.imagePath);
        } else if (state is AICaptureRecipeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message.isNotEmpty ? state.message : 'Quét công thức thành công!')),
                ],
              ),
              backgroundColor: const Color(0xFF2ECC71),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Future.delayed(const Duration(milliseconds: 600), () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.recipe,
              arguments: {
                'recipe': state.recipe != null
                    ? {
                        ...state.recipe!,
                        'mode': 'image',
                      }
                    : null,
                'mode': 'image',
                'imagePath': _previewPath,
              },
            );
          });
        } else if (state is AICaptureRecipeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: const Color(0xFFE74C3C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Stack(
          children: [
            // Background with animated gradient blurs
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),

                  // Camera viewfinder
                  Expanded(
                    child: BlocBuilder<AICaptureRecipeCubit, AICaptureRecipeState>(
                      builder: (context, state) {
                        return _buildCameraViewfinder(context, state);
                      },
                    ),
                  ),

                  // Bottom actions
                  _buildBottomActions(context),
                  
                  const SizedBox(height: 8),

                  // Bottom Navigation
                  // BottomNavigation(
                  //   currentIndex: _currentNavIndex,
                  //   onTap: _onNavTap,
                  //   onShoppingList: () => Navigator.pushNamed(context, AppRoutes.shoppingList),
                  //   onScanRecipe: () {}, // Already here
                  //   onCreateRecipe: () => Navigator.pushNamed(context, AppRoutes.recipeCreate),
                  //   onGenerateRecipe: () => Navigator.pushNamed(context, AppRoutes.aiRecipe),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1117),
            Color(0xFF161B22),
            Color(0xFF0D1117),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Purple-Teal blur (bottom-left)
          Positioned(
            left: -80,
            bottom: 150,
            child: _buildGlowOrb(
              size: 180,
              colors: [Color(0xFF6C58E6), Color(0xFF32D3C0)],
            ),
          ),
          // Red-Yellow blur (top-left)
          Positioned(
            left: -30,
            top: 50,
            child: _buildGlowOrb(
              size: 140,
              colors: [Color(0xFFE04242), Color(0xFFCAA41C)],
            ),
          ),
          // Red-Yellow blur (right-middle)
          Positioned(
            right: -20,
            top: MediaQuery.of(context).size.height * 0.5,
            child: _buildGlowOrb(
              size: 130,
              colors: [Color(0xFFE04242), Color(0xFFCAA41C)],
            ),
          ),
          // Green-Teal blur (top-right)
          Positioned(
            right: -10,
            top: 30,
            child: _buildGlowOrb(
              size: 150,
              colors: [Color(0xFF2ECC71), Color(0xFF108696)],
            ),
          ),
          // Green-Teal blur (center-left)
          Positioned(
            left: 30,
            top: MediaQuery.of(context).size.height * 0.35,
            child: _buildGlowOrb(
              size: 120,
              colors: [Color(0xFF23E21F), Color(0xFF108696)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          const SizedBox(width: 44),
          const Spacer(),
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2ECC71).withOpacity(0.3),
                  const Color(0xFF27AE60).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFF2ECC71).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.document_scanner_rounded,
                  color: Color(0xFF2ECC71),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Quét công thức',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Flash button
          Material(
            color: Colors.transparent,
            child: InkWell(
                  onTap: _toggleFlash,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewfinder(BuildContext context, AICaptureRecipeState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Instruction text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Đặt nguyên liệu trong khung hình',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Camera frame
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // Camera preview
                    Positioned.fill(
                      child: _buildCameraPreview(state),
                    ),

                    // Corner brackets
                    _buildCornerBrackets(),

                    // Scanning line animation
                    if (state is AICaptureRecipeInitial)
                      _buildScanningLine(),

                    // Processing overlay
                    if (state is AICaptureRecipeProcessing)
                      _buildProcessingOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(AICaptureRecipeState state) {
    String? displayPath;
    if (state is AICaptureRecipeCaptured) {
      displayPath = state.imagePath;
    } else if ((state is AICaptureRecipeProcessing || state is AICaptureRecipeError || state is AICaptureRecipeInitial) && _previewPath != null) {
      displayPath = _previewPath;
    }

    if (displayPath != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(displayPath),
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.25),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_isCameraError) {
      return Container(
        color: Colors.black.withOpacity(0.7),
        alignment: Alignment.center,
        child: const Text(
          'Không thể mở camera',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF2ECC71)),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildCornerBrackets() {
    const bracketSize = 40.0;
    const bracketThickness = 4.0;
    const bracketColor = Color(0xFF2ECC71);
    const margin = 16.0;

    return Stack(
      children: [
        // Top-left corner
        Positioned(
          left: margin,
          top: margin,
          child: _buildCorner(
            bracketSize: bracketSize,
            bracketThickness: bracketThickness,
            bracketColor: bracketColor,
            topLeft: true,
          ),
        ),
        // Top-right corner
        Positioned(
          right: margin,
          top: margin,
          child: _buildCorner(
            bracketSize: bracketSize,
            bracketThickness: bracketThickness,
            bracketColor: bracketColor,
            topRight: true,
          ),
        ),
        // Bottom-left corner
        Positioned(
          left: margin,
          bottom: margin,
          child: _buildCorner(
            bracketSize: bracketSize,
            bracketThickness: bracketThickness,
            bracketColor: bracketColor,
            bottomLeft: true,
          ),
        ),
        // Bottom-right corner
        Positioned(
          right: margin,
          bottom: margin,
          child: _buildCorner(
            bracketSize: bracketSize,
            bracketThickness: bracketThickness,
            bracketColor: bracketColor,
            bottomRight: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({
    required double bracketSize,
    required double bracketThickness,
    required Color bracketColor,
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: bracketSize,
      height: bracketSize,
      child: CustomPaint(
        painter: CornerBracketPainter(
          color: bracketColor,
          thickness: bracketThickness,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }

  Widget _buildScanningLine() {
    final scanRange = MediaQuery.of(context).size.height * 0.4;
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        final value = _scanAnimation.value;
        return Positioned(
          left: 20,
          right: 20,
          top: 20 + (value * scanRange),
          child: child!,
        );
      },
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF2ECC71).withOpacity(0.8),
              const Color(0xFF2ECC71),
              const Color(0xFF2ECC71).withOpacity(0.8),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF2ECC71).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withOpacity(0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF2ECC71),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Đang xử lý ảnh...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI đang nhận diện nguyên liệu',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return BlocBuilder<AICaptureRecipeCubit, AICaptureRecipeState>(
      builder: (context, state) {
        if (state is AICaptureRecipeProcessing) {
          return const SizedBox(height: 16);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              _buildActionButton(
                icon: Icons.photo_library_rounded,
                label: 'Thư viện',
                onTap: () => context.read<AICaptureRecipeCubit>().pickFromGallery(),
              ),
              
              // Capture button
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2ECC71),
                          Color(0xFF27AE60),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Switch camera button
              _buildActionButton(
                icon: Icons.flip_camera_ios_rounded,
                label: 'Xoay',
                onTap: _switchCamera,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for corner brackets
class CornerBracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  CornerBracketPainter({
    required this.color,
    required this.thickness,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (topLeft) {
      path.moveTo(0, size.height * 0.6);
      path.lineTo(0, 0);
      path.lineTo(size.width * 0.6, 0);
    } else if (topRight) {
      path.moveTo(size.width * 0.4, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.6);
    } else if (bottomLeft) {
      path.moveTo(0, size.height * 0.4);
      path.lineTo(0, size.height);
      path.lineTo(size.width * 0.6, size.height);
    } else if (bottomRight) {
      path.moveTo(size.width * 0.4, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height * 0.4);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
