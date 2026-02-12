import 'package:flutter/material.dart';
import '../models/member.dart';
import '../screens/mondial_relay_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AddressSection extends StatefulWidget {
  final Member member;
  final bool isEditing;
  final Function(Member) onMemberChanged;

  const AddressSection({
    super.key,
    required this.member,
    required this.isEditing,
    required this.onMemberChanged,
  });

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  
  bool _isPickupPointMode = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.member.addressStreet);
    _cityController = TextEditingController(text: widget.member.addressCity);
    _countryController = TextEditingController(text: widget.member.addressCountry);

    if (widget.member.pickupPointId != null && widget.member.pickupPointId!.isNotEmpty) {
      _isPickupPointMode = true;
    }
  }

  @override
  void didUpdateWidget(AddressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.member.addressStreet != widget.member.addressStreet && _streetController.text != widget.member.addressStreet) {
      _streetController.text = widget.member.addressStreet;
    }
    if (oldWidget.member.addressCity != widget.member.addressCity && _cityController.text != widget.member.addressCity) {
      _cityController.text = widget.member.addressCity;
    }
    if (oldWidget.member.addressCountry != widget.member.addressCountry && _countryController.text != widget.member.addressCountry) {
      _countryController.text = widget.member.addressCountry;
    }
    
    // Check if mode needs to toggle based on data changes (e.g. if pickup point was cleared externally)
    // For now, we trust local state unless purely contradictory, but let's keep it simple.
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _updateAddressFields() {
    widget.onMemberChanged(widget.member.copyWith(
      addressStreet: _streetController.text,
      addressCity: _cityController.text,
      addressCountry: _countryController.text,
      // Clear pickup point if we are effectively typing in address manually (optional logic, 
      // but maybe we want to keep them separate. Let's keep them separate in the UI but data model has both?
      // actually if we are in Address mode, we might want to clear pickup point data or just ignore it.
      // Let's just update the address fields here.
    ));
  }

  Future<void> _pickRelayPoint() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MondialRelayPicker()),
    );

    if (result != null) {
      final pickupName = result['Name'];
      final pickupAddress = "${result['Address1']}, ${result['ZipCode']} ${result['City']}";
      
      setState(() {
        _isPickupPointMode = true;
      });

      widget.onMemberChanged(widget.member.copyWith(
        pickupPointId: result['ID'],
        pickupPointName: pickupName,
        pickupPointAddress: pickupAddress,
        // Optional: Autofill specific address fields from the point?
        // Let's keep addressStreet separate as "Home Address" vs "Pickup Point Address"
      ));
    }
  }

  String _getVisibleAddress() {
    if (_isPickupPointMode && widget.member.pickupPointId != null) {
      return "${widget.member.pickupPointName}\n${widget.member.pickupPointAddress}";
    }

    switch (widget.member.addressVisibility) {
      case 'hidden':
        return '';
      case 'country':
        return widget.member.addressCountry;
      case 'city':
        return [widget.member.addressCity, widget.member.addressCountry].where((s) => s.isNotEmpty).join(', ');
      default: // 'full'
        return [widget.member.addressStreet, widget.member.addressCity, widget.member.addressCountry].where((s) => s.isNotEmpty).join('\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditing) {
      return _buildViewMode();
    }
    return _buildEditMode();
  }

  Widget _buildViewMode() {
    // If not owner and hidden, show hidden message
    if (!widget.member.isOwner && widget.member.addressVisibility == 'hidden') {
       return GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.lock, color: context.textTertiary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Adresse masquée',
              style: TextStyle(color: context.textTertiary, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    final hasAddress = widget.member.addressStreet.isNotEmpty || 
                       widget.member.addressCity.isNotEmpty || 
                       widget.member.addressCountry.isNotEmpty ||
                       (widget.member.pickupPointId != null);

    if (!hasAddress) {
      if (!_isExpanded) {
        return Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _isExpanded = true),
            icon: const Icon(Icons.add_location_alt),
            label: const Text("Ajouter une adresse"),
          ),
        );
      }
    }

    final isPickup = widget.member.pickupPointId != null;

    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
           InkWell(
             onTap: () => setState(() => _isExpanded = !_isExpanded),
             child: Padding(
               padding: const EdgeInsets.all(20),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       Icon(
                         isPickup ? Icons.store : Icons.local_shipping,
                         color: context.accent,
                         size: 20,
                       ),
                       const SizedBox(width: 8),
                       Text(
                         isPickup ? 'Point Relais' : 'Adresse de livraison',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           color: context.textColor,
                         ),
                       ),
                     ],
                   ),
                   Icon(
                     _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                     color: context.textTertiary,
                   ),
                 ],
               ),
             ),
           ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: context.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPickup 
                                  ? "${widget.member.pickupPointName}\n${widget.member.pickupPointAddress}"
                                  : (widget.member.isOwner 
                                      ? [widget.member.addressStreet, widget.member.addressCity, widget.member.addressCountry].where((s) => s.isNotEmpty).join('\n')
                                      : _getVisibleAddress()),
                                style: TextStyle(
                                  color: context.textColor,
                                  height: 1.4,
                                ),
                              ),
                              if (widget.member.isOwner && !isPickup && widget.member.addressVisibility != 'full') ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.member.addressVisibility == 'hidden' ? '🔒 Masqué' 
                                        : widget.member.addressVisibility == 'country' ? '🌍 Pays visible'
                                        : '🏙️ Ville visible',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresse de livraison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Toggle Mode
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildToggleOption('Domicile', !_isPickupPointMode, () {
                  setState(() => _isPickupPointMode = false);
                  // Optionally clear pickup point from model or just keep it there
                  if (widget.member.pickupPointId != null) {
                     widget.onMemberChanged(widget.member.copyWith(pickupPointId: null, pickupPointName: null, pickupPointAddress: null));
                  }
                })),
                Expanded(child: _buildToggleOption('Point Relais', _isPickupPointMode, () {
                   setState(() => _isPickupPointMode = true);
                   // Optionally we can't switch to it if no data, users need to pick one
                })),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isPickupPointMode) ...[
            if (widget.member.pickupPointId != null) ...[
               Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.member.pickupPointName ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, color: context.textColor),
                          ),
                          Text(
                            widget.member.pickupPointAddress ?? '',
                            style: TextStyle(color: context.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
               ),
               const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickRelayPoint,
                icon: const Icon(Icons.map),
                label: Text(widget.member.pickupPointId != null ? 'Changer de point' : 'Choisir un point'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            // Address Fields
            _buildTextField('Rue', _streetController, Icons.home),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Ville', _cityController, Icons.location_city)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Pays', _countryController, Icons.public)),
              ],
            ),
            const SizedBox(height: 16),
             // Visibility selector
            Text(
              'Qui peut voir cette adresse ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildVisibilityChip('full', '📍 Adresse complète'),
                _buildVisibilityChip('city', '🏙️ Ville seule'),
                _buildVisibilityChip('country', '🌍 Pays seul'),
                _buildVisibilityChip('hidden', '🔒 Masquer'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? context.textColor : context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      onChanged: (_) => _updateAddressFields(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildVisibilityChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: widget.member.addressVisibility == value,
      onSelected: (_) {
         widget.onMemberChanged(widget.member.copyWith(addressVisibility: value));
      },
      showCheckmark: false,
      backgroundColor: context.surfaceVariant,
      selectedColor: context.accent.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: widget.member.addressVisibility == value ? context.accent : context.textColor,
        fontWeight: widget.member.addressVisibility == value ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
