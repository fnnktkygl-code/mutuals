import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
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

  Future<void> _importSelected() async {
    final appState = context.read<AppState>();
    final selectedContacts = _contacts.where((c) => _selectedIds.contains(c.id)).toList();
    
    int addedCount = 0;
    for (var contact in selectedContacts) {
        // ID generated internally
        final member = _contactService.convertContactToMember(contact);
        await appState.addMember(member);
        addedCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$addedCount membres importés avec succès !')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredContacts = _contacts.where((c) {
      final fullName = '${c.name.first} ${c.name.last}'.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_contacts.isEmpty)
              const Expanded(child: Center(child: Text('Aucun contact trouvé')))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    final isSelected = _selectedIds.contains(contact.id);
                    return _buildContactTile(contact, isSelected, isDark);
                  },
                ),
              ),
            if (_selectedIds.isNotEmpty)
              GlassCard(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                    onPressed: _importSelected,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: context.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Importer ${_selectedIds.length} contacts', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ),
              ),
          ],
        ),
      ),
    );
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
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                'Importer des contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher un contact...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
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
            ? context.accent.withValues(alpha: 0.1) 
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: context.accent) : null,
      ),
      child: ListTile(
        onTap: () => _toggleSelection(contact.id),
        leading: CircleAvatar(
          backgroundColor: isSelected ? context.accent : Colors.grey.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          backgroundImage: contact.photo != null ? MemoryImage(contact.photo!) : null,
          child: contact.photo == null ? Text(contact.name.first.isNotEmpty ? contact.name.first[0] : '?') : null,
        ),
        title: Text(
          '${contact.name.first} ${contact.name.last}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        subtitle: contact.phones.isNotEmpty 
            ? Text(contact.phones.first.number, style: const TextStyle(fontSize: 12)) 
            : null,
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: context.accent)
            : const Icon(Icons.circle_outlined, color: Colors.grey),
      ),
    );
  }
}
