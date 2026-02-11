import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../routes.dart';
import '../../../utils/auth_state.dart';
import '../../../utils/app_toast.dart';
import '../../auth/services/session_api.dart';

import '../state/profile_controller.dart';
import '../models/profile.model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen opens
    ProfileController.instance.load();
  }

  void _showEditSheet(ProfileModel? profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Added iconTheme to make the back arrow black
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder<ProfileModel?>(
        valueListenable: ProfileController.instance,
        builder: (context, profile, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---------------- USER HEADER CARD ----------------
              _buildUserHeader(profile),

              const SizedBox(height: 24),
              const Text("My Account", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),

              // ---------------- SAVED ADDRESSES ----------------
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
              ),

              // ---------------- ORDERS ----------------
              _ProfileTile(
                icon: Icons.shopping_bag_outlined,
                title: 'My Orders',
                onTap: () => Navigator.pushNamed(context, AppRoutes.myOrders),
              ),

              // ---------------- PAYMENTS ----------------
              _ProfileTile(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () => AppToast.info('Payments managed by Razorpay'),
              ),

              const SizedBox(height: 24),
              const Text("Settings", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),

              // ---------------- LOGOUT ----------------
              _ProfileTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                textColor: Colors.red.shade600,
                iconColor: Colors.red.shade600,
                showChevron: false,
                onTap: _handleLogout,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(ProfileModel? profile) {
    if (ProfileController.instance.isLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = profile?.fullName ?? "Guest User";
    final email = profile?.email ?? "Login to view details";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "G";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(initial, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditSheet(profile),
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    // 1. Clear Profile Data
    ProfileController.instance.clear();
    
    // 2. Call Logout API
    await SessionApi.logout();
    
    // 3. Reset Global Auth
    AuthState.reset();

    // 4. Navigate
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }
}

// =======================================================
// EDIT PROFILE SHEET
// =======================================================

class _EditProfileSheet extends StatefulWidget {
  final ProfileModel? profile;
  const _EditProfileSheet({this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String? _gender;
  DateTime? _dob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile?.fullName ?? "");
    _emailCtrl = TextEditingController(text: widget.profile?.email ?? "");
    _gender = widget.profile?.gender;
    _dob = widget.profile?.dob;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);
    try {
      await ProfileController.instance.saveProfile(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        gender: _gender,
        dob: _dob,
      );
      if (mounted) Navigator.pop(context); // Close sheet on success
      AppToast.success("Profile Updated!");
    } catch (e) {
      AppToast.error("Failed to update profile");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Name Field
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecor("Full Name", Icons.person_outline),
              validator: (v) => v!.isEmpty ? "Name required" : null,
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailCtrl,
              decoration: _inputDecor("Email", Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Gender & DOB Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: _inputDecor("Gender", Icons.wc),
                    items: const [
                      DropdownMenuItem(value: "MALE", child: Text("Male")),
                      DropdownMenuItem(value: "FEMALE", child: Text("Female")),
                      DropdownMenuItem(value: "OTHER", child: Text("Other")),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dob ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setState(() => _dob = d);
                    },
                    child: InputDecorator(
                      decoration: _inputDecor("Date of Birth", Icons.calendar_today),
                      child: Text(
                        _dob == null ? "Select" : DateFormat('yyyy-MM-dd').format(_dob!),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SAVE CHANGES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool showChevron;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (iconColor ?? Colors.black54).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? Colors.black54, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor ?? Colors.black87, fontSize: 15),
        ),
        trailing: showChevron ? const Icon(Icons.chevron_right, color: Colors.grey, size: 20) : null,
        onTap: onTap,
      ),
    );
  }
}