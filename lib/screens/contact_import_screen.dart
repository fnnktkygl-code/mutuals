import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../services/contact_service.dart';
import '../services/app_state.dart';

import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class ContactImportScreen extends StatefulWidget {
  const ContactImportScreen({super.key});

  @override
  State<ContactImportScreen> createState() => _ContactImportScreenState();
}

class _ContactImportScreenState extends State<ContactImportScreen> {
  final ContactService _contactService = ContactService();
  List<Contact> _contacts = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _contactService.getContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des contacts: $e')),
        );
      }
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        // Filter by search query if needed, or _contacts is already filtered?
                        // The search logic is not in _loadContacts.
                        // I should filter here or in a getter.
                        // Let's filter here for simplicity based on _searchQuery
                        if (_searchQuery.isNotEmpty) {
                           final full = "${contact.name.first} ${contact.name.last}".toLowerCase();
                           if (!full.contains(_searchQuery.toLowerCase())) return const SizedBox.shrink();
                        }
                        
                        return _buildContactTile(
                          contact, 
                          _selectedIds.contains(contact.id), 
                          isDark
                        );
                      },
                    ),
            ),
            if (_selectedIds.isNotEmpty)
              _buildInviteAction(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteAction(BuildContext context, bool isDark) {
    return GlassCard(
       margin: const EdgeInsets.all(16),
       padding: const EdgeInsets.all(16),
       child: Column(
         children: [
           _buildTargetSelector(context),
           const SizedBox(height: 16),
           SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendInvites,
                icon: const Icon(Icons.send_rounded, size: 18),
                style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: Text(
                  'Envoyer l\'invitation (${_selectedIds.length})', 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
           ),
         ],
       ),
    );
  }

  // Invitation Target Logic
  bool _inviteToGroup = true; // Default to group if available

  Widget _buildRadio(bool value) {
    final isSelected = _inviteToGroup == value;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 20, 
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
             color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
             width: 2
          ),
        ),
        child: isSelected 
             ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle))) 
             : null
      ),
    );
  }

  Widget _buildTargetSelector(BuildContext context) {
    final appState = context.read<AppState>();
    final currentGroup = appState.currentGroup;
    final canInviteToGroup = currentGroup != null && !currentGroup.isPersonal;

    if (!canInviteToGroup) {
       // Only "App/Contacts" option available
       return Row(
         children: [
            Icon(Icons.person_add, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Ajouter à mes contacts (Privé)",
                style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface),
              ),
            ),
         ],
       );
    }

    return Column(
      children: [
        // Option 1: Group
        InkWell(
          onTap: () => setState(() => _inviteToGroup = true),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
               color: _inviteToGroup ? context.colors.primary.withValues(alpha: 0.1) : null,
               borderRadius: BorderRadius.circular(12),
               border: _inviteToGroup ? Border.all(color: context.colors.primary) : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                _buildRadio(true),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Inviter dans \"${currentGroup.name}\"", style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                      Text("Visible par les membres de l'espace", style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Option 2: Contacts
        InkWell(
          onTap: () => setState(() => _inviteToGroup = false),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
               color: !_inviteToGroup ? context.colors.primary.withValues(alpha: 0.1) : null,
               borderRadius: BorderRadius.circular(12),
               border: !_inviteToGroup ? Border.all(color: context.colors.primary) : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                _buildRadio(false),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0), // Align text visually
                        child: Text("Ajouter à mes contacts", style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                      ),
                      Text("Visible seulement par vous (Tous)", style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendInvites() async {
    final separator = Theme.of(context).platform == TargetPlatform.android ? ';' : '&';
    final appState = context.read<AppState>();
    final selectedContacts = _contacts.where((c) => _selectedIds.contains(c.id)).toList();
    final currentGroup = appState.currentGroup;
    final canInviteToGroup = currentGroup != null && !currentGroup.isPersonal;

    String inviteCode;
    String message;

    if (canInviteToGroup && _inviteToGroup) {
       // Invite to Shared Group
       inviteCode = currentGroup.inviteCode;
       message = "Rejoins mon espace \"${currentGroup.name}\" sur Mutuals ! Télécharge l'app et utilise le code : $inviteCode";
    } else {
       // Invite to Personal Group (App)
       try {
         final personalGroup = await appState.createPersonalGroupIfNeeded();
         if (!mounted) return;
         inviteCode = personalGroup.inviteCode;
         message = "Rejoins-moi sur Mutuals ! Télécharge l'app et utilise le code : $inviteCode";
       } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur création groupe perso: $e")));
         }
         return;
       }
    }
    
    // Collect phone numbers
    List<String> recipients = [];
    for (var contact in selectedContacts) {
      if (contact.phones.isNotEmpty) {
        // Simple sanitization
        recipients.add(contact.phones.first.number);
      }
    }

    if (!mounted) return;

    if (recipients.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun numéro de téléphone trouvé pour les contacts sélectionnés.')),
      );
      return;
    }
    
    // ... SMS launch logic ...
    final phones = recipients.join(separator);
    
    final uriString = 'sms:$phones?body=${Uri.encodeComponent(message)}';

    try {
      if (await canLaunchUrlString(uriString)) {
        await launchUrlString(uriString);
         if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ouverture de l\'application SMS...')),
            );
         }
      } else {
        throw 'Impossible d\'ouvrir l\'application SMS';
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur ouverture SMS: $e')),
        );
      }
    }
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: context.colors.onSurface),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inviter des proches',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: context.colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher un contact...',
              prefixIcon: Icon(Icons.search, color: context.colors.onSurfaceVariant),
              filled: true,
              fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: context.colors.onSurfaceVariant),
            ),
            style: TextStyle(color: context.colors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(Contact contact, bool isSelected, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? context.colors.primary.withValues(alpha: 0.1) 
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: context.colors.primary) : null,
      ),
      child: ListTile(
        onTap: () => _toggleSelection(contact.id),
        leading: CircleAvatar(
          backgroundColor: isSelected ? context.colors.primary : context.colors.onSurfaceVariant.withValues(alpha: 0.2),
          foregroundColor: context.colors.onPrimary,
          backgroundImage: contact.photo != null ? MemoryImage(contact.photo!) : null,
          child: contact.photo == null 
              ? Text(
                  contact.name.first.isNotEmpty ? contact.name.first[0].toUpperCase() : '?',
                  style: TextStyle(color: isSelected ? context.colors.onPrimary : context.colors.onSurface),
                ) 
              : null,
        ),
        title: Text(
          '${contact.name.first} ${contact.name.last}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        subtitle: contact.phones.isNotEmpty 
            ? Text(contact.phones.first.number, style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)) 
            : null,
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: context.colors.primary)
            : Icon(Icons.circle_outlined, color: context.colors.onSurfaceVariant),
      ),
    );
  }
}
