import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/config/arkesel_config.dart';
import '../../../../core/services/arkesel_otp_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class PhoneVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String fullName;
  final String? email;
  final DateTime? dob;

  const PhoneVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.fullName,
    this.email,
    this.dob,
  });

  @override
  ConsumerState<PhoneVerificationPage> createState() =>
      _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends ConsumerState<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  final ArkeselOTPService _otpService = ArkeselOTPService(
    apiKey: ArkeselConfig.apiKey,
    senderId: ArkeselConfig.senderId,
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    setState(() => _isLoading = true);

    final result = await _otpService.sendOTP(widget.phoneNumber);

    if (!mounted) return;

    if (result.success) {
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${widget.phoneNumber}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      // Show Arkesel's actual reason (e.g. bad sender ID, insufficient
      // balance, invalid number) instead of a generic failure message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Failed to send OTP. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _handleVerifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final otpCode = _otpController.text.trim();
    final result = await _otpService.verifyOTP(widget.phoneNumber, otpCode);

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      context.push(
        '/set-password',
        extra: {
          'phone': widget.phoneNumber,
          'mobile': widget.phoneNumber,
          'email': widget.email,
          'name': widget.fullName,
          'dob': widget.dob,
          'isPhoneVerified': true,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Invalid OTP. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleResendOTP() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);
    await _sendOTP();

    if (mounted) {
      setState(() => _isResending = false);
    }
  }

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryTurquoise,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Verify Phone'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.spacing40),

                // Phone icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTurquoise.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 50,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                Text(
                  'Verify Your Phone',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing16),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing16,
                  ),
                  child: Text(
                    'We\'ve sent a verification code to:',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),

                Text(
                  widget.phoneNumber,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTurquoise,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // OTP Input
                CustomTextField(
                  label: 'Enter OTP',
                  hint: '000000',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: _validateOTP,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Verify button
                CustomButton(
                  text: _isLoading ? 'Verifying...' : 'Verify OTP',
                  onPressed: _isLoading ? null : _handleVerifyOTP,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Resend button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: (_resendCooldown > 0 || _isResending)
                        ? null
                        : _handleResendOTP,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: (_resendCooldown > 0 || _isResending)
                            ? AppColors.textHint
                            : AppColors.primaryTurquoise,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _resendCooldown > 0
                                ? 'Resend in ${_resendCooldown}s'
                                : 'Resend OTP',
                            style: TextStyle(
                              color: (_resendCooldown > 0)
                                  ? AppColors.textHint
                                  : AppColors.primaryTurquoise,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Info box
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: Text(
                          'Didn\'t receive the code? Check your phone or try resending.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
