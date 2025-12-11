import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/setting_cubit.dart';
import '../cubit/setting_state.dart';
import '../../../core/constants/app_routes.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingCubit(),
      child: const SettingView(),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingCubit, SettingState>(
      listener: (context, state) {
        if (state is SettingLogoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng xuất thành công')),
          );
          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else if (state is SettingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<SettingCubit, SettingState>(
                  builder: (context, state) {
                    if (state is SettingLogoutLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2BEE4B),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAccountSection(context, state),
                          // const SizedBox(height: 24),
                          // _buildGeneralSection(context, state),
                          // const SizedBox(height: 24),
                          // _buildSupportSection(context),
                          // const SizedBox(height: 24),
                          // _buildAboutSection(context),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6).withOpacity(0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: SvgPicture.asset(
              'assets/img/setting_back_button.svg',
              width: 40,
              height: 40,
            ),
          ),
          const Text(
            'Cài đặt',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.015 * 18,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, SettingState state) {
    return _buildSection(
      title: 'TÀI KHOẢN',
      children: [
        // _buildSettingItem(
        //   icon: 'assets/img/setting_icon_profile.svg',
        //   title: 'Chỉnh sửa hồ sơ',
        //   trailing: SvgPicture.asset(
        //     'assets/img/setting_chevron_right.svg',
        //     width: 28,
        //     height: 28,
        //   ),
        //   onTap: () => context.read<SettingCubit>().navigateToEditProfile(),
        // ),
        // _buildDivider(),
        // _buildSettingItem(
        //   icon: 'assets/img/setting_icon_password.svg',
        //   title: 'Thay đổi mật khẩu',
        //   trailing: SvgPicture.asset(
        //     'assets/img/setting_chevron_right2.svg',
        //     width: 28,
        //     height: 28,
        //   ),
        //   onTap: () => context.read<SettingCubit>().navigateToChangePassword(),
        // ),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_password.svg',
          title: 'Change Password',
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
          onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_logout.svg',
          title: 'Đăng xuất',
          titleColor: const Color(0xFFEF4444),
          iconBackgroundColor: const Color(0xFFEF4444).withOpacity(0.2),
          onTap: () => context.read<SettingCubit>().logout(),
        ),
      ],
    );
  }

  Widget _buildGeneralSection(BuildContext context, SettingState state) {
    final isDarkMode = state is SettingLoaded ? state.isDarkMode : false;
    final language = state is SettingLoaded ? state.language : 'Tiếng Việt';

    return _buildSection(
      title: 'CHUNG',
      children: [
        _buildSettingItem(
          icon: 'assets/img/setting_icon_notification.svg',
          title: 'Thông báo',
          trailing: SvgPicture.asset(
            'assets/img/setting_chevron_right3.svg',
            width: 28,
            height: 28,
          ),
          onTap: () => context.read<SettingCubit>().navigateToNotifications(),
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_language.svg',
          title: 'Ngôn ngữ',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/img/setting_chevron_right4.svg',
                width: 28,
                height: 28,
              ),
            ],
          ),
          onTap: () {
            // Show language picker dialog
            _showLanguagePicker(context);
          },
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_dark_mode.svg',
          title: 'Chế độ tối',
          trailing: GestureDetector(
            onTap: () => context.read<SettingCubit>().toggleDarkMode(),
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2BEE4B) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(2),
              child: Align(
                alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      title: 'HỖ TRỢ',
      children: [
        _buildSettingItem(
          icon: 'assets/img/setting_icon_faq.svg',
          title: 'Câu hỏi thường gặp',
          trailing: SvgPicture.asset(
            'assets/img/setting_chevron_right5.svg',
            width: 28,
            height: 28,
          ),
          onTap: () => context.read<SettingCubit>().navigateToFAQ(),
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_contact.svg',
          title: 'Liên hệ hỗ trợ',
          trailing: SvgPicture.asset(
            'assets/img/setting_chevron_right6.svg',
            width: 28,
            height: 28,
          ),
          onTap: () => context.read<SettingCubit>().navigateToContactSupport(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: 'VỀ ỨNG DỤNG',
      children: [
        _buildSettingItem(
          icon: 'assets/img/setting_icon_about.svg',
          title: 'Giới thiệu',
          trailing: SvgPicture.asset(
            'assets/img/setting_chevron_right7.svg',
            width: 28,
            height: 28,
          ),
          onTap: () => context.read<SettingCubit>().navigateToAbout(),
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_terms.svg',
          title: 'Điều khoản dịch vụ',
          trailing: SvgPicture.asset(
            'assets/img/setting_chevron_right8.svg',
            width: 28,
            height: 28,
          ),
          onTap: () => context.read<SettingCubit>().navigateToTerms(),
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: 'assets/img/setting_icon_version.svg',
          title: 'Phiên bản ứng dụng',
          trailing: const Text(
            '1.0.0',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.05 * 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B7280).withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    Color? iconBackgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? const Color(0xFF2BEE4B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: titleColor != null ? 16 : 14,
                    fontWeight: titleColor != null ? FontWeight.w500 : FontWeight.w400,
                    color: titleColor ?? const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE5E7EB),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Chọn ngôn ngữ',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tiếng Việt'),
              onTap: () {
                context.read<SettingCubit>().changeLanguage('Tiếng Việt');
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<SettingCubit>().changeLanguage('English');
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
