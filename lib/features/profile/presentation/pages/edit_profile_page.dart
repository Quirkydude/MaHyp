import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../auth/providers/user_profile_provider.dart';

/// Edit Profile Page - Beautiful, accessible form for editing user profile
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // Load current profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Load current profile data into the form
  Future<void> _loadProfileData() async {
    try {
      final profileService = UserProfileService();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final profile = await profileService.getUserProfile(userId);
        if (profile != null && mounted) {
          setState(() {
            _fullNameController.text = profile.fullName;
            _mobileController.text = profile.mobile ?? '';
            if (profile.dob != null) {
              _dobController.text =
                  '${profile.dob!.day.toString().padLeft(2, '0')} / '
                  '${profile.dob!.month.toString().padLeft(2, '0')} / '
                  '${profile.dob!.year}';
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile');
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress for faster upload
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selected. Save to upload.')),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (photo != null && mounted) {
        setState(() {
          _selectedImage = photo;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo taken. Save to upload.')),
        );
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to take photo. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show image source selection dialog - Senior-friendly design
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Choose Photo Source',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // Subtitle
              Text(
                'Where would you like to get your profile picture?',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing32),

              // Camera Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                  icon: const Icon(Icons.camera_alt, size: 32),
                  label: Text(
                    'Take Photo with Camera',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTurquoise,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing20,
                      vertical: AppDimensions.spacing20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Gallery Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                  icon: const Icon(Icons.image, size: 32),
                  label: Text(
                    'Choose from Gallery',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTurquoise,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing20,
                      vertical: AppDimensions.spacing20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing20),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryTurquoise,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing20,
                      vertical: AppDimensions.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parse DOB string to DateTime
  DateTime? _parseDob() {
    if (_dobController.text.isEmpty) return null;
    try {
      final parts = _dobController.text.split(' / ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  /// Validate full name
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  /// Validate mobile
  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length < 10) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  /// Handle save profile
  Future<void> _handleSaveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not logged in');
        }

        final profileService = UserProfileService();
        String? avatarUrl;

        // Upload image if selected
        if (_selectedImage != null) {
          setState(() => _isUploadingImage = true);
          final imageService = ImageUploadService();
          try {
            avatarUrl = await imageService.uploadUserAvatar(
              userId: userId,
              imageFile: _selectedImage!,
            );
          } finally {
            setState(() => _isUploadingImage = false);
          }
        }

        // Update profile
        await profileService.updateUserProfile(
          uid: userId,
          fullName: _fullNameController.text.trim(),
          mobile: _mobileController.text.trim(),
          dob: _parseDob(),
          avatarUrl: avatarUrl,
        );

        if (mounted) {
          // Invalidate the cache so the profile data reloads
          ref.refresh(userProfileProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Go back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.pop();
            }
          });
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          debugPrint('Firebase error updating profile: ${e.code} - ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          debugPrint('Unexpected error updating profile: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong. Please check your connection and try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _parseDob() ??
          DateTime.now().subtract(const Duration(days: 365 * 60)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTurquoise,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')} / '
            '${picked.month.toString().padLeft(2, '0')} / '
            '${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Edit Profile', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacing16),

              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    // Avatar Container
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryTurquoise,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? (kIsWeb
                                ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                            : userProfileAsync.when(
                                data: (profile) {
                                  if (profile?.avatarUrl != null &&
                                      profile!.avatarUrl!.isNotEmpty) {
                                    return Image.network(
                                      profile.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.inputBackground,
                                        child: Icon(
                                          Icons.person,
                                          size: 70,
                                          color: AppColors.primaryTurquoise,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    color: AppColors.inputBackground,
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                      color: AppColors.primaryTurquoise,
                                    ),
                                  );
                                },
                                loading: () => Container(
                                  color: AppColors.inputBackground,
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.primaryTurquoise,
                                    ),
                                  ),
                                ),
                                error: (_, __) => Container(
                                  color: AppColors.inputBackground,
                                  child: Icon(
                                    Icons.person,
                                    size: 70,
                                    color: AppColors.primaryTurquoise,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacing20),

                    // Change Photo Button
                    if (!_isUploadingImage)
                      ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Change Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTurquoise,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing24,
                            vertical: AppDimensions.spacing12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.spacing8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primaryTurquoise,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacing8),
                            const Text('Uploading...'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacing40),

              // Form Fields
              Text('Profile Information', style: AppTextStyles.h4),
              const SizedBox(height: AppDimensions.spacing16),

              // Full Name
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _fullNameController,
                validator: _validateFullName,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryTurquoise,
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Mobile Number
              CustomTextField(
                label: 'Mobile Number',
                hint: 'Enter your mobile number',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: _validateMobile,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.primaryTurquoise,
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Date of Birth
              CustomTextField(
                label: 'Date of Birth',
                hint: 'DD / MM / YYYY',
                controller: _dobController,
                readOnly: true,
                onTap: _selectDate,
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primaryTurquoise,
                ),
              ),

              const SizedBox(height: AppDimensions.spacing40),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _handleSaveProfile,
                isLoading: _isLoading,
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryTurquoise,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryTurquoise,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}
