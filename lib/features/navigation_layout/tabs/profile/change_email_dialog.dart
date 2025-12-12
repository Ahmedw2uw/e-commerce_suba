import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/navigation_layout/tabs/profile/text_feald.dart';
import 'package:flutter/material.dart' hide TextField;

class ChangeEmailDialog extends StatefulWidget {
  final String currentEmail;

  const ChangeEmailDialog({super.key, required this.currentEmail});

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _requirePassword = true ;

  Future<void> _changeEmail(BuildContext context) async {
    if (_newEmailController.text.isEmpty) {
      _showErrorSnackBar(context, 'Please enter a new email address');
      return;
    }

    if (_newEmailController.text == widget.currentEmail) {
      _showErrorSnackBar(context, 'New email must be different from current email');
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(_newEmailController.text)) {
      _showErrorSnackBar(context, 'Please enter a valid email address');
      return;
    }

    if (_requirePassword && _passwordController.text.isEmpty) {
      _showErrorSnackBar(context, 'Please enter your current password for verification');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.changeEmail(newEmail: _newEmailController.text.trim());
      
      _showSuccessSnackBar(
        context, 
        'Email change requested. Please check your new email for confirmation.'
      );
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to change email: $e');
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
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Email'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Email: ${widget.currentEmail}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            
            if (_requirePassword)
              Column(
                children: [
                  TextField(
                    title: 'Current Password',
                    hintText: 'Enter your current password for verification',
                    controller: _passwordController,
                    obscureText: true,
                    showObscureTextToggle: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            TextField(
              title: 'New Email Address',
              hintText: 'Enter new email address',
              controller: _newEmailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Note: You will receive a confirmation email at the new address.',
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
          onPressed: _isLoading ? null : () => _changeEmail(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Change Email'),
        ),
      ],
    );
  }
}