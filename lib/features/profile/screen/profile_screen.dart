import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../app/router.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: user?.avatar != null
                              ? null
                              : Text(
                                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                  style: context.headlineStyle.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.surfaceColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      user?.name ?? 'User',
                      style: context.headlineStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user?.email ?? '',
                      style: context.bodyStyle.copyWith(
                        color: context.textColor.withOpacity(0.6),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Edit Profile Button
                    OutlinedButton.icon(
                      onPressed: () {
                        context.pushNamed(AppRouter.editProfile);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Menu Items
              _buildMenuSection(
                title: 'Akun',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Informasi Pribadi',
                    subtitle: 'Ubah data pribadi Anda',
                    onTap: () => context.pushNamed(AppRouter.editProfile),
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline,
                    title: 'Ganti Password',
                    subtitle: 'Ubah password akun Anda',
                    onTap: () => context.pushNamed(AppRouter.changePassword),
                  ),
                ],
              ),
              
              _buildMenuSection(
                title: 'Pengaturan',
                items: [
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Umum',
                    subtitle: 'Tema, bahasa, mata uang',
                    onTap: () => context.pushNamed(AppRouter.settings),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    subtitle: 'Atur pengingat dan notifikasi',
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                ],
              ),
              
              _buildMenuSection(
                title: 'Lainnya',
                items: [
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Dukungan',
                    subtitle: 'FAQ dan hubungi kami',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi 1.0.0',
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: 'Keluar',
                  onPressed: () => _showLogoutConfirmation(context),
                  backgroundColor: AppColors.expense,
                  icon: Icons.logout_rounded,
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            title,
            style: context.labelStyle.copyWith(
              color: context.textColor.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.zero,
          child: Column(
            children: items
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.icon,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: context.bodyBoldStyle,
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: context.labelSmallStyle.copyWith(
                                  color: context.textColor.withOpacity(0.6),
                                ),
                              )
                            : null,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                        ),
                        onTap: item.onTap,
                      ),
                      if (index < items.length - 1)
                        Divider(
                          height: 1,
                          indent: 68,
                          color: context.textColor.withOpacity(0.1),
                        ),
                    ],
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      await _authService.logout();
      if (mounted) {
        context.pushNamedAndRemoveUntil(AppRouter.login);
      }
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
