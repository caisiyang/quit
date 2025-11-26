import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../resources/theme.dart';

class UserProfileCard extends StatefulWidget {
  const UserProfileCard({super.key});

  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  bool _isEditing = false;
  late TextEditingController _nicknameController;
  late TextEditingController _yearsController;
  late TextEditingController _dailyController;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppProvider>(context, listen: false).userProfile;
    _nicknameController = TextEditingController(text: profile.nickname);
    _yearsController = TextEditingController(text: profile.smokingYears.toString());
    _dailyController = TextEditingController(text: profile.dailyCigarettes.toString());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _yearsController.dispose();
    _dailyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final newProfile = provider.userProfile;
      newProfile.avatarPath = image.path;
      provider.updateUserProfile(newProfile);
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Save changes
      final provider = Provider.of<AppProvider>(context, listen: false);
      final newProfile = provider.userProfile;
      newProfile.nickname = _nicknameController.text;
      newProfile.smokingYears = int.tryParse(_yearsController.text) ?? 0;
      newProfile.dailyCigarettes = int.tryParse(_dailyController.text) ?? 0;
      provider.updateUserProfile(newProfile);
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.userProfile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profile.avatarPath != null 
                          ? FileImage(File(profile.avatarPath!)) 
                          : null,
                      child: profile.avatarPath == null 
                          ? const Icon(Icons.person, size: 30, color: Colors.grey) 
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing)
                      TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          labelText: '昵称',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    else
                      Text(
                        profile.nickname,
                        style: AppTheme.heading2,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '戒烟勇士',
                      style: AppTheme.body.copyWith(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit, color: AppTheme.primary),
                onPressed: _toggleEdit,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatField('烟龄 (年)', _yearsController, _isEditing),
              _buildStatField('日均 (根)', _dailyController, _isEditing),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatField(String label, TextEditingController controller, bool isEditing) {
    return Column(
      children: [
        if (isEditing)
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          )
        else
          Text(
            controller.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
