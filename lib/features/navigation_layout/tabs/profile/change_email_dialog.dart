import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/navigation_layout/tabs/profile/text_feald.dart';
import 'package:flutter/material.dart' hide TextField;
import 'package:lottie/lottie.dart';

class ChangeEmailDialog extends StatefulWidget {
  final String currentEmail;
  const ChangeEmailDialog({super.key, required this.currentEmail});
  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}
class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _changeEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Check if new email is same as current
    if (_newEmailController.text.trim().toLowerCase() == 
        widget.currentEmail.toLowerCase()) {
      _showErrorSnackBar(context, 'New email must be different from current email');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseService.changeEmail(
        newEmail: _newEmailController.text.trim(),
        currentPassword: _passwordController.text,
      );
      if (!context.mounted) return;
      _showSuccessSnackBar(
        context, 
        'Email change requested. Please check both your old and new email for confirmation links.'
      );
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!context.mounted) return;
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showErrorSnackBar(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.email, color: AppColors.blue),
          const SizedBox(width: 8),
          const Text('Change Email'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Email Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, 
                      color: Colors.grey[600], 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.currentEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Current Password Field
              TextField(
                title: 'Current Password *',
                hintText: 'Enter your current password',
                controller: _passwordController,
                obscureText: true,
                showObscureTextToggle: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required for verification';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // New Email Field
              TextField(
                title: 'New Email Address *',
                hintText: 'Enter new email address',
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New email is required';
                  }
                  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  if (value.toLowerCase() == widget.currentEmail.toLowerCase()) {
                    return 'New email must be different';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.blue),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will receive confirmation emails at both your old and new email addresses. Please verify the change by clicking the links.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          height: 1.4,
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _changeEmail(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ?  SizedBox(
                  height: 20,
                  width: 20,
                  child:Lottie.asset(AppLottie.loading),
                )
              : const Text(
                  'Change Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}