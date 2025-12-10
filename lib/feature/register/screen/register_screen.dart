import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Đăng ký thành công!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
        } else if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DecorativeBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Back button
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: AppIconButton(
                                icon: Icons.arrow_back_rounded,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Logo
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/img/logo1.png',
                              width: 200,
                              height: 125,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Welcome text
                          const Text(
                            'Tạo tài khoản mới',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 26,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đăng ký để bắt đầu hành trình nấu ăn',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.8),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // First name
                          AppTextField(
                            hintText: 'Họ',
                            prefixIcon: Icons.badge_outlined,
                            onChanged: (v) => context.read<RegisterCubit>().updateFirstName(v),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          // Last name
                          AppTextField(
                            hintText: 'Tên',
                            prefixIcon: Icons.account_circle_outlined,
                            onChanged: (v) => context.read<RegisterCubit>().updateLastName(v),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          // Age
                          AppTextField(
                            hintText: 'Tuổi',
                            prefixIcon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (v) => context.read<RegisterCubit>().updateAge(v),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          // Gender
                          _GenderSelector(
                            onChanged: (v) => context.read<RegisterCubit>().updateGender(v),
                          ),
                          const SizedBox(height: 20),
                          // Email field
                          AppTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            focusNode: _emailFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => context.read<RegisterCubit>().updateEmail(value),
                            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 20),
                          // Password field
                          AppTextField(
                            controller: _passwordController,
                            hintText: 'Mật khẩu',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            focusNode: _passwordFocusNode,
                            textInputAction: TextInputAction.next,
                            maxLength: 72,
                            onChanged: (value) => context.read<RegisterCubit>().updatePassword(value),
                            onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 20),
                          // Confirm password field
                          AppTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Xác nhận mật khẩu',
                            prefixIcon: Icons.lock_rounded,
                            isPassword: true,
                            focusNode: _confirmPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            maxLength: 72,
                            onChanged: (value) => context.read<RegisterCubit>().updateConfirmPassword(value),
                            onSubmitted: (_) => context.read<RegisterCubit>().register(),
                          ),
                          const SizedBox(height: 32),
                          // Register button
                          BlocBuilder<RegisterCubit, RegisterState>(
                            builder: (context, state) {
                              return AppPrimaryButton(
                                text: 'Đăng ký',
                                icon: Icons.arrow_forward_rounded,
                                isLoading: state is RegisterLoading,
                                onPressed: () {
                                  context.read<RegisterCubit>().register();
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Divider with text
                          _buildDivider(),
                          const SizedBox(height: 24),
                          // Google register button
                          AppSecondaryButton(
                            text: 'Đăng ký với Google',
                            leadingIcon: Image.asset(
                              'assets/img/google_icon.png',
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              // TODO: Implement Google sign up
                            },
                          ),
                          const SizedBox(height: 32),
                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã có tài khoản? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.8),
                                  fontSize: 15,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.textHint.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'hoặc',
            style: TextStyle(
              color: AppColors.textHint.withOpacity(0.8),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textHint.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderSelector extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _GenderSelector({required this.onChanged});

  @override
  State<_GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<_GenderSelector> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 0,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _value,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Giới tính',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ),
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            if (value != null) widget.onChanged(value);
          },
          items: const [
            DropdownMenuItem(
              value: 'Nam',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Nam'),
              ),
            ),
            DropdownMenuItem(
              value: 'Nữ',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Nữ'),
              ),
            ),
            DropdownMenuItem(
              value: 'Khác',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Khác'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
