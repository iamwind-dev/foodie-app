import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/login_cubit.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.error)),
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
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: AppIconButton(
                                icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                          SizedBox(height: screenHeight * 0.03),
                      // Logo
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                        'assets/img/logo1.png',
                              width: 240,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Welcome text
                          const Text(
                            'Chào mừng trở lại!',
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
                            'Đăng nhập để tiếp tục khám phá công thức',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.8),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                      // Email field
                          AppTextField(
                        controller: _emailController,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            focusNode: _emailFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
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
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                                    context.read<LoginCubit>().login(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                  },
                          ),
                          const SizedBox(height: 24),
                          // Login button
                          BlocBuilder<LoginCubit, LoginState>(
                            builder: (context, state) {
                              return AppPrimaryButton(
                                text: 'Đăng nhập',
                                icon: Icons.arrow_forward_rounded,
                                isLoading: state is LoginLoading,
                                onPressed: () {
                                  context.read<LoginCubit>().login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                },
                          );
                        },
                      ),
                          const SizedBox(height: 32),
                          // Divider with text
                          _buildDivider(),
                          const SizedBox(height: 24),
                      // Google login button
                      BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                              return AppSecondaryButton(
                                text: 'Tiếp tục với Google',
                                leadingIcon: Image.asset(
                                  'assets/img/google_icon.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: state is LoginLoading
                                ? null
                                : () {
                                    context.read<LoginCubit>().loginWithGoogle();
                                  },
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Register text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Text(
                                'Chưa có tài khoản? ',
                                    style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.8),
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(
                                  'Đăng ký ngay',
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
