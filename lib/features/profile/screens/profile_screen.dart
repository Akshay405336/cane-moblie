import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../routes.dart';
import '../../../utils/auth_state.dart';
import '../../../utils/app_toast.dart';
import '../../../core/network/url_helper.dart';
import '../../auth/services/session_api.dart';

import '../state/profile_controller.dart';
import '../models/profile.model.dart';

// --- STYLING CONSTANTS ---
const kPrimaryColor = Color(0xFF2E7D32);
const kAccentColor = Color(0xFFE8F5E9);
const kBackgroundColor = Color(0xFFF8FAFB);
const kCardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 5)),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder<ProfileModel?>(
        valueListenable: ProfileController.instance,
        builder: (context, profile, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              // ---------------- USER HEADER CARD ----------------
              _buildUserHeader(profile),

              const SizedBox(height: 32),
              _buildSectionTitle("MY ACCOUNT"),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.location_on_rounded,
                title: 'Saved Addresses',
                subtitle: 'Manage your delivery locations',
                onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
              ),
              _ProfileTile(
                icon: Icons.shopping_bag_rounded,
                title: 'My Orders',
                subtitle: 'Check status of your purchases',
                onTap: () => Navigator.pushNamed(context, AppRoutes.myOrders),
              ),
              _ProfileTile(
                icon: Icons.payment_rounded,
                title: 'Payment Methods',
                subtitle: 'Credit cards, UPI, and Wallets',
                onTap: () => Navigator.pushNamed(context, AppRoutes.paymentMethods),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("SETTINGS"),
              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account safely',
                textColor: Colors.red.shade700,
                iconColor: Colors.red.shade700,
                showChevron: false,
                onTap: _handleLogout,
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildUserHeader(ProfileModel? profile) {
    if (ProfileController.instance.isLoading && profile == null) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
    }

    final name = profile?.fullName ?? "Guest User";
    final email = profile?.email ?? "Login to view details";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "G";
    final avatarUrl = profile?.avatarUrl != null ? UrlHelper.full(profile!.avatarUrl!) : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green.shade50.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: kCardShadow,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(initial, style: const TextStyle(fontSize: 28, color: kPrimaryColor, fontWeight: FontWeight.w900))
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: kAccentColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(email, style: const TextStyle(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Material(
            color: kAccentColor,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => _showEditSheet(profile),
              icon: const Icon(Icons.edit_rounded, color: kPrimaryColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    ProfileController.instance.clear();
    await SessionApi.logout();
    AuthState.reset();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }
}

// =======================================================
// ENHANCED EDIT PROFILE SHEET
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
  File? _selectedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile?.fullName ?? "");
    _emailCtrl = TextEditingController(text: widget.profile?.email ?? "");
    _gender = widget.profile?.gender;
    _dob = widget.profile?.dob;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
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
        imageFile: _selectedImage,
      );
      if (mounted) Navigator.pop(context);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const Text("Update Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 2)),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (widget.profile?.avatarUrl != null ? NetworkImage(UrlHelper.full(widget.profile!.avatarUrl!)) : null) as ImageProvider?,
                        child: _selectedImage == null && widget.profile?.avatarUrl == null
                            ? const Icon(Icons.person_rounded, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, boxShadow: kCardShadow),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDecor("Full Name", Icons.person_outline_rounded),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDecor("Email Address", Icons.alternate_email_rounded),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Email required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecor("Gender", Icons.face_rounded),
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
                          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: kPrimaryColor)), child: child!),
                        );
                        if (d != null) setState(() => _dob = d);
                      },
                      child: InputDecorator(
                        decoration: _inputDecor("DOB", Icons.calendar_month_rounded),
                        child: Text(_dob == null ? "Select" : DateFormat('dd MMM yyyy').format(_dob!), style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text("SAVE CHANGES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: kPrimaryColor, size: 22),
      filled: true,
      fillColor: kBackgroundColor,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool showChevron;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.textColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (iconColor ?? kPrimaryColor).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor ?? kPrimaryColor, size: 24),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: textColor ?? const Color(0xFF1A1A1A), fontSize: 16)),
        subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)) : null,
        trailing: showChevron ? Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16) : null,
      ),
    );
  }
}