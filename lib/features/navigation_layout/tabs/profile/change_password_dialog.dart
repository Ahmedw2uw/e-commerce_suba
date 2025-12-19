// ignore_for_file: use_build_context_synchronously

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/navigation_layout/tabs/profile/text_feald.dart';
import 'package:flutter/material.dart' hide TextField;
import 'package:lottie/lottie.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword(BuildContext context) async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar(context, 'Please fill in all password fields');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar(context, 'New password and confirmation do not match');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar(context, 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.changePassword(newPassword: _newPasswordController.text.trim());
      
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      _showSuccessSnackBar(context, 'Password changed successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to change password: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              title: 'Current Password',
              hintText: 'Enter current password',
              controller: _currentPasswordController,
              obscureText: true,
              showObscureTextToggle: true,
            ),
            const SizedBox(height: 16),
            
            TextField(
              title: 'New Password',
              hintText: 'Enter new password',
              controller: _newPasswordController,
              obscureText: true,
              showObscureTextToggle: true,
            ),
            const SizedBox(height: 16),
            
            TextField(
              title: 'Confirm New Password',
              hintText: 'Confirm new password',
              controller: _confirmPasswordController,
              obscureText: true,
              showObscureTextToggle: true,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Password must be at least 6 characters long',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _changePassword(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
          ),
          child: _isLoading
              ?  SizedBox(
                  height: 20,
                  width: 20,
                  child:Lottie.asset(AppLottie.loading),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}