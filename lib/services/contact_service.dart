import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/fit_preference.dart';
import '../models/wardrobe_item.dart';
import '../models/monthly_wish.dart';

class ContactService {
  /// Request permission to access contacts
  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// Get all contacts with properties (photo, accounts, etc.)
  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      return await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
        withAccounts: true,
      );
    }
    return [];
  }

  /// Map a Contact to a Member draft
  Member convertContactToMember(Contact contact, {String? defaultGroupId}) {
    // Try to find a birthday date from events if available
    DateTime? birthday;
    if (contact.events.isNotEmpty) {
      try {
        final birthdayEvent = contact.events.firstWhere(
            (e) => e.label == EventLabel.birthday,
            orElse: () => Event(label: EventLabel.custom, month: 1, day: 1, year: 1900));
        
        if (birthdayEvent.label == EventLabel.birthday) {
             birthday = DateTime(
                birthdayEvent.year ?? DateTime.now().year,
                birthdayEvent.month,
                birthdayEvent.day
             );
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    const uuid = Uuid();
    return Member(
      id: uuid.v4(),
      name: '${contact.name.first} ${contact.name.last}'.trim(),
      relationship: '',
      gradient: 'from-purple-400 to-purple-600',
      fitPreference: FitPreference.regular,
      isOwner: false,
      tops: const <WardrobeItem>[],
      bottoms: const <WardrobeItem>[],
      shoes: const <WardrobeItem>[],
      accessories: const <WardrobeItem>[],
      topBrands: '',
      bottomBrands: '',
      shoeBrands: '',
      wishlist: const <String>[],
      wishHistory: const <MonthlyWish>[],
      generalTopSize: '',
      generalBottomSize: '',
      generalShoeSize: '',
      birthday: birthday,
      avatarType: contact.photo != null ? 'image' : 'gradient',
      avatarValue: 'from-purple-400 to-purple-600', // We don't store the photo bytes directly yet
      lastUpdated: DateTime.now(),
    );
  }
}
