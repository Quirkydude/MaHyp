import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// My Profile Page - displays user profile info and menu options
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'My Profile', showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(context, userProfileAsync, user),

            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () => context.push('/edit-profile'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.emergency,
              title: 'Emergency Contacts',
              onTap: () => context.push('/emergency-contacts'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock_outline,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Navigate to privacy policy
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push('/settings'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () => context.push('/support'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              showDivider: false,
              isLogout: true,
              onTap: () async {
                final confirmed = await _showLogoutDialog(context);
                if (confirmed == true) {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AsyncValue userProfileAsync,
    User? user,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                  color: AppColors.white,
                ),
                child: ClipOval(
                  child: userProfileAsync.when(
                    data: (profile) {
                      if (profile?.avatarUrl != null &&
                          profile!.avatarUrl!.isNotEmpty) {
                        return Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primaryTurquoise,
                          ),
                        );
                      }
                      return Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryTurquoise,
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => context.push('/edit-profile'),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryTurquoise,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Name
          userProfileAsync.when(
            data: (profile) => Text(
              profile?.fullName ?? 'User',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const Text(
              'Loading...',
              style: TextStyle(color: AppColors.white, fontSize: 22),
            ),
            error: (_, __) => const Text(
              'User',
              style: TextStyle(color: AppColors.white, fontSize: 22),
            ),
          ),

          const SizedBox(height: 4),

          // Mobile Number
          userProfileAsync.when(
            data: (profile) => Text(
              profile?.mobile ?? '',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(height: 2),

          // Email
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
    bool isLogout = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLogout
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primaryTurquoise.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLogout
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.primaryTurquoise.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout
                        ? AppColors.error
                        : AppColors.primaryTurquoise,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLogout ? AppColors.error : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Arrow (only for non-logout items)
                if (!isLogout)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryTurquoise,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 88,
            endIndent: 24,
            color: AppColors.inputBorder,
          ),
      ],
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
