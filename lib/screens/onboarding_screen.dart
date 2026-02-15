import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../theme/filou_state.dart';
import 'home_screen.dart';
import 'group_settings_screen.dart';
import '../widgets/custom_avatar.dart';
import '../widgets/avatar_picker_modal.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _name = '';
  // Avatar state
  String _avatarType = 'custom'; // custom by default
  String? _avatarCharacterId;
  String? _avatarBackgroundColor;

  void _handleNext() {
    if (_step == 1 && _name.trim().isEmpty) {
      return;
    }
    
    if (_step == 2) {
      // Save profile, then move to family step
      String avatarValue = 'custom';
      if (_avatarType == 'image') {
        // We'll need to store the path if we implement image handling here, 
        // but for now we only support 'custom' avatar builder in onboarding as per requirements 
        // or simple "custom" type.
        // If image picker was added to onboarding, we'd handle it. 
        // For this refactor, we stick to custom avatar builder.
        avatarValue = 'custom'; 
      }

      context.read<AppState>().initializeOwnerProfile(
        ownerName: _name,
        avatarType: _avatarType,
        avatarValue: avatarValue,
        avatarCharacterId: _avatarCharacterId,
        avatarBackgroundColor: _avatarBackgroundColor,
      ).then((_) {
        if (mounted) {
          setState(() => _step++);
        }
      });
    } else if (_step == 3) {
      // Complete onboarding — go to home
      _finishOnboarding();
    } else {
      setState(() => _step++);
    }
  }

  void _finishOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.3),
              const Color(0xFFF0F2F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: index <= _step ? 32 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _step 
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 60),
                Expanded(child: _buildStepContent()),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _step == 3 ? "C'est parti !" : (_step == 2 ? 'Continuer' : 'Continuer'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildNameStep();
      case 2:
        return _buildAvatarStep();
      case 3:
        return _buildFamilyStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Filou mascot greeting
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.mascotColors.background,
                context.mascotColors.background.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            boxShadow: [
              BoxShadow(
                color: context.mascotColors.fur.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              FilouState.waving.assetPath,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                const Text('🐼', style: TextStyle(fontSize: 64)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Salut, moi c\'est Filou !',
          style: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Je vais t\'aider à garder les tailles\net les envies de tes proches. 🎁',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: context.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Comment vous appelez-vous ?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        TextField(
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Votre prénom',
            hintStyle: TextStyle(
              color: Colors.grey[300],
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9333EA), width: 2),
            ),
          ),
          onChanged: (value) => setState(() => _name = value),
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      children: [
        const Text(
          'Choisissez votre avatar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        
        // Avatar Preview
        GestureDetector(
          onTap: _openAvatarPicker,
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              children: [
                if (_avatarType == 'custom' && _avatarCharacterId != null)
                  Center(
                    child: CustomAvatar(
                      characterId: _avatarCharacterId!,
                      backgroundColor: _avatarBackgroundColor ?? '#6366F1',
                      size: 140,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _name.substring(0, _name.length >= 2 ? 2 : _name.length).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, size: 20, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        const Text(
          'Appuyez pour personnaliser',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          onPressed: _openAvatarPicker,
          icon: const Icon(Icons.face),
          label: const Text('Choisir un avatar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _openAvatarPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarPickerModal(
        initialCharacterId: _avatarCharacterId,
        initialBackgroundColor: _avatarBackgroundColor,
        onConfirm: (characterId, backgroundColor) {
          setState(() {
            _avatarType = 'custom';
            _avatarCharacterId = characterId;
            _avatarBackgroundColor = backgroundColor;
          });
        },
      ),
    );
  }

  Widget _buildFamilyStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_sync_rounded,
            size: 40,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Synchronisation',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Partagez vos données avec vos proches\nen temps réel sur tous les appareils',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),
        // Create family button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroupSettingsScreen(),
                ),
              );
              if (mounted) {
                 // The user might have joined/created a family or just explored. 
                 // We can check AppState or just finish onboarding if they return.
                 // For now, let's check if they have a family:
                 if (context.read<AppState>().hasFamily) {
                    _finishOnboarding();
                 }
              }
            },
            icon: const Icon(Icons.group_add),
            label: const Text('Créer ou rejoindre un espace'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFF1E293B), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _finishOnboarding,
          child: Text(
            'Plus tard',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }
}
