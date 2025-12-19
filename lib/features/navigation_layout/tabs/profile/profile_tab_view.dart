import 'package:e_commerce/features/auth/login/login.dart';
import 'package:e_commerce/core/models/address_model.dart';
import 'package:e_commerce/features/navigation_layout/tabs/profile/text_feald.dart';
import 'package:e_commerce/features/navigation_layout/tabs/profile/change_password_dialog.dart';
import 'package:e_commerce/features/navigation_layout/tabs/profile/change_email_dialog.dart';
import 'package:flutter/material.dart' hide TextField;
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/core/models/user_model.dart' hide Address;

class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  UserModel? _currentUser;
  List<Address> _addresses = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _showAddressForm = false;
  Address? _defaultAddress;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isDefaultAddress = false;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await SupabaseService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
        });
        await _loadUserAddresses();
      }
    } catch (e) {
      print('Error loading user data: $e');
      _showErrorSnackBar('Failed to load user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _loadUserAddresses() async {
    try {
      final addresses = await SupabaseService.getUserAddresses();
      setState(() {
        _addresses = addresses;
        _defaultAddress = addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => addresses.isNotEmpty
              ? addresses.first
              : Address(
                  id: 0,
                  street: '',
                  city: '',
                  state: '',
                  zipCode: '',
                  country: 'Egypt',
                  isDefault: false,
                  createdAt: DateTime.now(),
                ),
        );
      });
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }
  Future<void> _updateProfile({FocusNode? nodeToFocus}) async {
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
      if (nodeToFocus != null) {
        nodeToFocus.requestFocus();
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = await SupabaseService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
      });

      _showSuccessSnackBar('Profile updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _addAddress() async {
    if (_streetController.text.isEmpty || _cityController.text.isEmpty) {
      _showErrorSnackBar('Please fill in street and city');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseService.addAddress(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        isDefault: _isDefaultAddress || _addresses.isEmpty,
      );
      _streetController.clear();
      _cityController.clear();
      _stateController.clear();
      _zipCodeController.clear();
      _isDefaultAddress = false;
      await _loadUserAddresses();
      setState(() {
        _showAddressForm = false;
      });
      _showSuccessSnackBar('Address added successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to add address: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _deleteAddress(int addressId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await SupabaseService.deleteAddress(addressId);
                await _loadUserAddresses();
                _showSuccessSnackBar('Address deleted successfully');
              } catch (e) {
                _showErrorSnackBar('Failed to delete address: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> _setDefaultAddress(int addressId) async {
    try {
      await SupabaseService.setDefaultAddress(addressId);
      await _loadUserAddresses();
      _showSuccessSnackBar('Default address updated');
    } catch (e) {
      _showErrorSnackBar('Failed to update default address: $e');
    }
  }
  void _showAddAddressForm() {
    setState(() {
      _showAddressForm = true;
    });
  }
  void _hideAddAddressForm() {
    setState(() {
      _showAddressForm = false;
      _streetController.clear();
      _cityController.clear();
      _stateController.clear();
      _zipCodeController.clear();
      _isDefaultAddress = false;
    });
  }
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                const SizedBox(height: 30),
                // Personal Information
                _buildPersonalInfoSection(),
                if (_isEditing) _buildActionButtons(),
                const SizedBox(height: 24),
                // Security Section
                _buildSecuritySection(),
                // Addresses Section
                _buildAddressesSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome ${_currentUser?.name ?? "User"}',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.blue,
              ),
            ),
            Text(
              _currentUser?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.red),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        // Name Field
        TextField(
          title: "Your Name",
          hintText: 'Enter your name',
          controller: _nameController,
          focusNode: _nameFocusNode,
          suffixIcon: _isEditing ? null : Icons.edit,
          onIconPressed: _isEditing ? null : () => _updateProfile(nodeToFocus: _nameFocusNode),
          readOnly: !_isEditing,
        ),
        const SizedBox(height: 24),

        // Email Field
        TextField(
          title: 'Your E-mail',
          hintText: 'Email',
          controller: _emailController,
          readOnly: true,
          suffixIcon: Icons.lock,
        ),
        const SizedBox(height: 24),

        // Phone Field
        TextField(
          title: 'Your mobile number',
          hintText: 'Enter your mobile number',
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          suffixIcon: _isEditing ? null : Icons.edit,
          onIconPressed: _isEditing ? null : () => _updateProfile(nodeToFocus: _phoneFocusNode),
          readOnly: !_isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security',
          style: TextStyle(
            color: AppColors.blue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.lock, color: AppColors.blue),
                title: Text('Change Password'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangePasswordDialog(),
                  );
                },
              ),
              Divider(height: 1, thickness: 1),
              ListTile(
                leading: Icon(Icons.email, color: AppColors.blue),
                title: Text('Change Email'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ChangeEmailDialog(
                      currentEmail: _currentUser?.email ?? '',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Addresses',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_showAddressForm)
              IconButton(
                onPressed: _showAddAddressForm,
                icon: const Icon(Icons.add, color: AppColors.blue),
                tooltip: 'Add New Address',
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_showAddressForm) _buildAddressForm(),

        // Default Address
        if (_defaultAddress != null && _defaultAddress!.street.isNotEmpty)
          _buildAddressCard(_defaultAddress!, isDefault: true),

        ..._addresses
            .where((address) => !address.isDefault)
            .map((address) => _buildAddressCard(address)),

        if (_addresses.isEmpty && !_showAddressForm)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No addresses added yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Address',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              title: 'Street',
              hintText: 'Enter street address',
              controller: _streetController,
            ),
            const SizedBox(height: 16),

            TextField(
              title: 'City',
              hintText: 'Enter city',
              controller: _cityController,
            ),
            const SizedBox(height: 16),

            TextField(
              title: 'State',
              hintText: 'Enter state',
              controller: _stateController,
            ),
            const SizedBox(height: 16),

            TextField(
              title: 'ZIP Code',
              hintText: 'Enter ZIP code',
              controller: _zipCodeController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: _isDefaultAddress,
                  onChanged: (value) {
                    setState(() {
                      _isDefaultAddress = value ?? false;
                    });
                  },
                ),
                const Text('Set as default address'),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addAddress,
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
                        : const Text('Save Address'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hideAddAddressForm,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.blue),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address, {bool isDefault = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Default Address',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isDefault) const SizedBox(height: 8),

            Text(address.fullAddress, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),

            Row(
              children: [
                if (!isDefault)
                  TextButton(
                    onPressed: () => _setDefaultAddress(address.id),
                    child: const Text('Set as Default'),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteAddress(address.id),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  tooltip: 'Delete Address',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
                // Reset controllers to original values
                _nameController.text = _currentUser?.name ?? '';
                _phoneController.text = _currentUser?.phone ?? '';
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.blue),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await SupabaseService.signOut();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Login.routeName,
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                _showErrorSnackBar('Logout failed: $e');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}