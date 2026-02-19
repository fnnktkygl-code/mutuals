import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
import '../services/app_state.dart';
import '../models/member.dart';
import '../models/monthly_wish.dart';
import '../models/fit_preference.dart';
import '../theme/app_theme.dart';
import '../theme/filou_state.dart';
import '../widgets/fit_preference_selector.dart';
import '../widgets/avatar_editor_section.dart';
import '../widgets/size_widgets.dart';
import '../widgets/monthly_wish_section.dart';
import '../widgets/address_section.dart';
import '../widgets/birthday_section.dart';
import '../widgets/wardrobe_section.dart';
import '../widgets/glass_card.dart';
import '../widgets/share_profile_sheet.dart';
import '../widgets/restricted_access_sheet.dart';
import '../widgets/member_avatar.dart';
import '../utils/date_utils.dart' as date_utils;

import '../utils/sizing_constants.dart';

class MemberDetailScreen extends StatefulWidget {
  final String? memberId;

  const MemberDetailScreen({super.key, this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Member _member;
  bool _isEditing = false;

  // Controllers
  late ConfettiController _confettiController;
  late PageController _pageController;
  int _currentPage = 0;

  // Tutorial Keys
  final GlobalKey _sizesKey = GlobalKey();

  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _emojiController;
  late TextEditingController _wishController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _pageController = PageController();

    final appState = context.read<AppState>();

    if (widget.memberId == null) {
      // New member
      _member = Member(
        id: '', // Will be assigned on save
        name: '',
        gradient: 'from-purple-400 to-purple-600',
        fitPreference: FitPreference.regular,
      );
      _isEditing = true;
    } else {
      final existingMember = appState.getMember(widget.memberId!);
      if (existingMember == null) {
        // Member not found (deleted or sync issue) - Close screen safely
        _member = Member(
          id: '',
          name: '',
          gradient: 'from-purple-400 to-purple-600',
          fitPreference: FitPreference.regular,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _member = existingMember;
        // Only show tutorial if we are viewing an existing member
        WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
      }
    }

    _nameController = TextEditingController(text: _member.name);
    _relationshipController = TextEditingController(text: _member.relationship);
    _emojiController = TextEditingController(text: _member.avatarValue);

    // Find current wish text
    final currentKey = date_utils.DateUtils.getCurrentMonthKey();
    final wishText = _member.wishHistory.where((w) => w.monthKey == currentKey).firstOrNull?.text ?? '';
    _wishController = TextEditingController(text: wishText);

    // Listeners to update _member state without rebuilding controllers
    _nameController.addListener(() {
      if (_member.name != _nameController.text) {
        setState(() => _member = _member.copyWith(name: _nameController.text));
      }
    });
    _relationshipController.addListener(() {
      if (_member.relationship != _relationshipController.text) {
        setState(() => _member = _member.copyWith(relationship: _relationshipController.text));
      }
    });
    _emojiController.addListener(() {
       if (_member.avatarValue != _emojiController.text) {
        setState(() => _member = _member.copyWith(avatarValue: _emojiController.text));
      }
    });

    // Check permissions
    final currentUser = appState.authService.currentUser;
    final canEditProfile = _member.isOwner || (currentUser != null && _member.ownerId == currentUser.uid);
    
    // Force read-only if not allowed
    if (!canEditProfile && _isEditing) {
      setState(() => _isEditing = false);
    }
  }

  void _showTutorial() async {
    if (await StorageService.hasShownMemberTutorial()) return;
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final targets = [
      TutorialService.createTarget(
        key: _sizesKey,
        title: "Mode Story \u{1F4CF}",
        description: "Swipe vers la droite pour découvrir les tailles, les envies et l'historique de ce membre !",
        align: ContentAlign.bottom,
        filou: FilouState.measuring,
        stepNumber: 1,
        totalSteps: 1,
        isLast: true,
      ),
    ];

    TutorialService.showTutorial(
      context: context,
      targets: targets,
      onFinish: () => StorageService.setShownMemberTutorial(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _emojiController.dispose();
    _wishController.dispose();
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    final appState = context.read<AppState>();
    
    // Permission Check
    final currentUser = appState.authService.currentUser;
    final canEditProfile = _member.isOwner || (currentUser != null && _member.ownerId == currentUser.uid);

    if (!canEditProfile) {
       if (mounted) {
         Navigator.of(context).pop();
       }
       return;
    }

    if (_member.name.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le prénom est requis')),
        );
      }
      return;
    }

    HapticFeedback.heavyImpact();
    _confettiController.play();

    // Update wish if changed
    final currentKey = date_utils.DateUtils.getCurrentMonthKey();
    final wishText = _wishController.text.trim();
    final updatedHistory = List<MonthlyWish>.from(_member.wishHistory);
    final existingIndex = updatedHistory.indexWhere((w) => w.monthKey == currentKey);

    if (wishText.isNotEmpty) {
       if (existingIndex >= 0) {
         updatedHistory[existingIndex] = updatedHistory[existingIndex].copyWith(text: wishText);
       } else {
         updatedHistory.add(MonthlyWish(monthKey: currentKey, text: wishText));
       }
    } else {
      if (existingIndex >= 0) {
        updatedHistory.removeAt(existingIndex);
      }
    }
    _member = _member.copyWith(wishHistory: updatedHistory);

    if (widget.memberId == null) {
      // Adding new member
      await appState.addMember(_member);
      // Give time for confetti
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();
    } else {
      final updatedMember = _member.copyWith(
        lastUpdated: DateTime.now(),
      );
      await appState.updateMember(updatedMember);
      if (mounted) {
        setState(() {
          _isEditing = false;
          _member = updatedMember;
        });
      }
    }
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le profil'),
        content: Text('Voulez-vous vraiment supprimer ${_member.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AppState>().deleteMember(widget.memberId!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _updateMember(Member updated) {
    setState(() => _member = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildPage1Profile(),
                      _buildPage2Style(),
                      _buildPage3Logistics(),
                    ],
                  ),
                ),
                _buildPageIndicator(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isSelected = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPage2Style() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("STYLE & SIZES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: context.colors.outline)),
          const SizedBox(height: 16),
          Container(key: _sizesKey, child: FitPreferenceSelector(
            member: _member,
            isEditing: _isEditing,
            onMemberChanged: _updateMember,
          )),
          const SizedBox(height: 24),
           WardrobeSection(
            member: _member,
            isEditing: _isEditing,
            onMemberChanged: _updateMember,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3Logistics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GIFTING & LOGISTICS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: context.colors.outline)),
          const SizedBox(height: 16),
          MonthlyWishSection(
            member: _member,
            isEditing: _isEditing,
            wishController: _wishController,
          ),
          const SizedBox(height: 24),
          _buildAddressSection(),
        ],
      ),
    );
  }

  Widget _buildPage1Profile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          BirthdaySection(
            member: _member,
            isEditing: _isEditing,
            onMemberChanged: _updateMember,
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 24),
            MonthlyWishSection(
              member: _member,
              isEditing: false,
              wishController: _wishController,
            ),
          ],
          const SizedBox(height: 24),
          if (!_isEditing) ...[
             if (_member.lastContacted != null)
              Text(
                "Dernier contact: ${date_utils.DateUtils.timeAgo(_member.lastContacted!)}",
                style: TextStyle(
                  color: context.colors.outline,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
           if (_isEditing && widget.memberId != null && !_member.isOwner) ...[
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: _delete,
              icon: Icon(Icons.delete_forever, color: context.colors.error),
              label: Text('Supprimer ce profil', style: TextStyle(color: context.colors.error)),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    final appState = context.read<AppState>();
    final currentUser = appState.authService.currentUser;
    final canEditProfile = _member.isOwner || (currentUser != null && _member.ownerId == currentUser.uid);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (_isEditing && widget.memberId != null) {
                setState(() => _isEditing = false);
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Retour',
          ),
          
          Row(
            children: [
              if (widget.memberId != null)
                IconButton(
                  onPressed: () => ShareProfileSheet.show(context, _member),
                  icon: const Icon(Icons.share),
                  tooltip: 'Partager le profil',
                ),
                
              if (widget.memberId != null && currentUser != null && _member.ownerId == currentUser.uid)
                IconButton(
                  onPressed: () => RestrictedAccessSheet.show(context, _member),
                  icon: const Icon(Icons.security_rounded),
                  tooltip: 'Gérer l\'accès',
                ),
                
              const SizedBox(width: 8),

              if (!_isEditing && canEditProfile)
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Modifier',
                ),

              if (_isEditing || !canEditProfile)
                IconButton(
                  onPressed: _saveMember, 
                  icon: Icon(canEditProfile ? Icons.save : Icons.check),
                  tooltip: canEditProfile ? 'Sauver' : 'OK',
                  style: IconButton.styleFrom(
                    backgroundColor: canEditProfile ? context.colors.primary : null,
                    foregroundColor: canEditProfile ? context.colors.onPrimary : context.colors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    if (_isEditing) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AvatarEditorSection(
              member: _member,
              onMemberChanged: _updateMember,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Prénom',
                hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
                border: const UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relationshipController,
              enabled: !_member.isOwner,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Lien (ex: Frère, Ami...)',
                hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  children: [
                    SizeInputWidget(label: 'Haut', value: _member.generalTopSize, options: SizingConstants.topSizes, onChanged: (v) => setState(() => _member = _member.copyWith(generalTopSize: v))),
                    const SizedBox(width: 12),
                    SizeInputWidget(label: 'Bas', value: _member.generalBottomSize, options: SizingConstants.bottomSizes, onChanged: (v) => setState(() => _member = _member.copyWith(generalBottomSize: v))),
                    const SizedBox(width: 12),
                    SizeInputWidget(label: 'Pointure', value: _member.generalShoeSize, options: SizingConstants.shoeSizes, onChanged: (v) => setState(() => _member = _member.copyWith(generalShoeSize: v))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            // GroupSelector Was Here
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Confidentialité',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.colors.outline),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text('Afficher l\'âge', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.onSurface)),
                subtitle: Text('Visible par le Cercle', style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                value: _member.shareAccess['age'] ?? true,
                onChanged: (bool value) {
                  final newAccess = Map<String, bool>.from(_member.shareAccess);
                  newAccess['age'] = value;
                  setState(() => _member = _member.copyWith(shareAccess: newAccess));
                },
                activeTrackColor: context.colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text('Afficher les tailles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.onSurface)),
                subtitle: Text('Visible par le Cercle', style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                value: _member.shareAccess['sizes'] ?? true,
                onChanged: (bool value) {
                  final newAccess = Map<String, bool>.from(_member.shareAccess);
                  newAccess['sizes'] = value;
                  setState(() => _member = _member.copyWith(shareAccess: newAccess));
                },
                activeTrackColor: context.colors.tertiary,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          MemberAvatar(
            member: _member,
            size: 112,
            showBorder: true,
          ),
          const SizedBox(height: 12),
          Text(
            _member.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (_member.relationship.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (_member.relationship.toLowerCase() == 'moi' && !_member.isOwner)
                    ? 'PARTAGÉ'
                    : _member.relationship.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_member.isOwner || (_member.shareAccess['sizes'] ?? true))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizeBadgeWidget(
                  label: 'Haut', 
                  value: _member.generalTopSize,
                  accentColor: const Color(0xFF60A5FA), // Blue
                ),
                const SizedBox(width: 20),
                SizeBadgeWidget(
                  label: 'Bas', 
                  value: _member.generalBottomSize,
                  accentColor: const Color(0xFF34D399), // Green
                ),
                const SizedBox(width: 20),
                SizeBadgeWidget(
                  label: 'Pointure', 
                  value: _member.generalShoeSize,
                  accentColor: const Color(0xFFF472B6), // Pink
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          if (_member.lastUpdated != null)
            Text(
              'Mis à jour ${date_utils.DateUtils.timeAgo(_member.lastUpdated!)}',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (_member.lastUpdated != null && DateTime.now().difference(_member.lastUpdated!).inDays > 180) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demande de mise à jour envoyée ! (Simulation)')),
                );
              },
              icon: const Icon(Icons.update, size: 16),
              label: const Text('Demander une mise à jour'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ],
      );
    }
  }

  Widget _buildAddressSection() {
    return AddressSection(
      member: _member,
      isEditing: _isEditing,
      onMemberChanged: _updateMember,
    );
  }
}
