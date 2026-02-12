import 'dart:io';
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_avatar.dart';
import '../widgets/avatar_picker_modal.dart';
import 'package:image_picker/image_picker.dart';

/// Avatar type selector and editor (custom, photo)
class AvatarEditorSection extends StatelessWidget {
  final Member member;
  final ValueChanged<Member> onMemberChanged;

  const AvatarEditorSection({
    super.key,
    required this.member,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar Type Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeOption(context, 'Avatar', 'custom', Icons.face),
            const SizedBox(width: 12),
            _buildTypeOption(context, 'Photo', 'image', Icons.photo_camera),
          ],
        ),
        const SizedBox(height: 16),

        // Avatar Editor Content
        if (member.avatarType == 'image')
          _buildImagePicker(context)
        else
          _buildCustomAvatarPicker(context),
      ],
    );
  }

  Widget _buildTypeOption(BuildContext context, String label, String type, IconData icon) {
    // Treat 'gradient' (legacy) as 'custom' for selection purposes
    final isSelected = member.avatarType == type || 
                      (type == 'custom' && member.avatarType == 'gradient');
                      
    return GestureDetector(
      onTap: () {
        var updated = member.copyWith(avatarType: type);
        
        if (type == 'image' && !member.avatarValue.contains('/')) {
          if (member.avatarValue.isEmpty) {
            _pickImage(context);
            return;
          }
        } else if (type == 'custom' && member.avatarType == 'image') {
           // Switch back to custom default if coming from image
           // Keep existing custom values if they exist, otherwise default
           if (member.avatarCharacterId == null) {
             updated = updated.copyWith(
               avatarType: 'custom',
               avatarCharacterId: 'avatar_1',
               avatarBackgroundColor: '#6366F1' // Indigo
             );
           }
        }
        
        onMemberChanged(updated);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.surfaceContainerHighest : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? context.colors.onSurface : context.colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? context.colors.onSurface : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAvatarPicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAvatarPicker(context),
      child: Column(
        children: [
          if (member.avatarCharacterId != null)
            CustomAvatar(
              characterId: member.avatarCharacterId!,
              backgroundColor: member.avatarBackgroundColor ?? '#6366F1',
              size: 100,
            )
          else
             // Fallback/Legacy gradient display or default avatar
             Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face,
                size: 50,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Modifier l\'avatar',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600,
                color: context.colors.primary
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: member.avatarValue.isNotEmpty && member.avatarValue.startsWith('/')
                ? FileImage(File(member.avatarValue))
                : null,
            backgroundColor: context.colors.surfaceContainerHighest,
            child: member.avatarValue.isEmpty || !member.avatarValue.startsWith('/')
                ? Icon(Icons.add_a_photo, size: 40, color: context.colors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            'Choisir une photo', 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              color: context.colors.primary
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAvatarPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarPickerModal(
        initialCharacterId: member.avatarCharacterId,
        initialBackgroundColor: member.avatarBackgroundColor,
        onConfirm: (characterId, backgroundColor) {
          onMemberChanged(member.copyWith(
            avatarType: 'custom',
            avatarCharacterId: characterId,
            avatarBackgroundColor: backgroundColor,
          ));
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onMemberChanged(member.copyWith(
        avatarType: 'image',
        avatarValue: image.path,
      ));
    }
  }
}
