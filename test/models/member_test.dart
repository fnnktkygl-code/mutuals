import 'package:flutter_test/flutter_test.dart';
import 'package:famille_io/models/member.dart';
import 'package:famille_io/models/fit_preference.dart';
import 'package:famille_io/models/monthly_wish.dart';

void main() {
  group('Member', () {
    test('fromJson handles String ID correctly', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'name': 'Test User',
        'gradient': 'blue',
        'isOwner': true,
      };

      final member = Member.fromJson(json);

      expect(member.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(member.name, 'Test User');
      expect(member.isOwner, true);
    });

    test('fromJson converts int ID to String (Migration)', () {
      final json = {
        'id': 12345,
        'name': 'Legacy User',
        'gradient': 'red',
      };

      final member = Member.fromJson(json);

      expect(member.id, '12345');
      expect(member.name, 'Legacy User');
    });

    test('toJson produces correct map', () {
      final member = Member(
        id: 'uuid-123',
        name: 'Json User',
        gradient: 'green',
        fitPreference: FitPreference.oversize,
      );

      final json = member.toJson();

      expect(json['id'], 'uuid-123');
      expect(json['name'], 'Json User');
      expect(json['fitPreference'], 'oversize');
    });

    test('toJson serializes sharedWith field', () {
      final member = Member(
        id: 'uuid-456',
        name: 'Shared User',
        gradient: 'blue',
        ownerId: 'owner-1',
        sharedWith: ['user-a', 'user-b'],
      );

      final json = member.toJson();

      expect(json['sharedWith'], ['user-a', 'user-b']);
      expect(json['ownerId'], 'owner-1');
    });

    test('toJson serializes empty sharedWith list', () {
      final member = Member(
        id: 'uuid-789',
        name: 'Solo User',
        gradient: 'red',
      );

      final json = member.toJson();

      expect(json['sharedWith'], isEmpty);
    });

    test('copyWith updates fields correctly', () {
      final member = Member(
        id: '1',
        name: 'Original',
        gradient: 'blue',
      );

      final updated = member.copyWith(name: 'Updated');

      expect(updated.id, '1');
      expect(updated.name, 'Updated');
      expect(updated.gradient, 'blue');
    });

    test('age calculation is correct', () {
      final today = DateTime.now();
      // Birthday yesterday, 10 years ago -> 10 years old
      final birthdayPassed = DateTime(today.year - 10, today.month, today.day - 1);
      final memberPassed = Member(
        id: '1',
        name: 'Kid',
        gradient: 'blue',
        birthday: birthdayPassed,
      );
      expect(memberPassed.age, 10);

      // Birthday tomorrow, 10 years ago -> 9 years old
      final birthdayUpcoming = DateTime(today.year - 10, today.month, today.day + 1);
      final memberUpcoming = Member(
        id: '2',
        name: 'Kid',
        gradient: 'blue',
        birthday: birthdayUpcoming,
      );
      expect(memberUpcoming.age, 9);
    });

    test('daysUntilBirthday calculation is correct', () {
       // Simple check: birthday tomorrow = 1 day
       final today = DateTime.now();
       final tomorrow = today.add(const Duration(days: 1));
       
       // Handle year wrap if today is Dec 31
       final member = Member(
         id: '1', 
         name: 'Test', 
         gradient: 'x', 
         birthday: DateTime(2000, tomorrow.month, tomorrow.day)
       );

       expect(member.daysUntilBirthday, 1);
    });

    test('missingFields includes Avatar when default gradient is used', () {
      final member = Member(
        id: '1',
        name: 'Test',
        gradient: 'from-purple-400 to-purple-600',
        avatarType: 'gradient',
        avatarValue: 'from-purple-400 to-purple-600',
      );

      expect(member.missingFields, contains('Avatar'));
    });

    test('missingFields excludes Avatar when custom avatar is set', () {
      final member = Member(
        id: '1',
        name: 'Test',
        gradient: 'from-purple-400 to-purple-600',
        avatarType: 'custom',
        avatarValue: 'custom',
        avatarCharacterId: 'char_1',
      );

      expect(member.missingFields, isNot(contains('Avatar')));
    });

    test('completionPercentage includes avatar check correctly', () {
      final defaultMember = Member(
        id: '1',
        name: 'Test',
        gradient: 'from-purple-400 to-purple-600',
        avatarType: 'gradient',
        avatarValue: 'from-purple-400 to-purple-600',
      );

      final customMember = defaultMember.copyWith(
        avatarType: 'custom',
        avatarValue: 'custom',
      );

      // Custom avatar should have higher completion
      expect(customMember.completionPercentage, greaterThan(defaultMember.completionPercentage));
    });

    test('completionPercentage is 1.0 for fully filled member', () {
      final member = Member(
        id: '1',
        name: 'Complete User',
        gradient: 'from-blue-400 to-blue-600',
        relationship: 'Frère',
        birthday: DateTime(1995, 6, 15),
        avatarType: 'custom',
        avatarValue: 'custom',
        generalTopSize: 'M',
        generalBottomSize: '40',
        generalShoeSize: '42',
        wishHistory: [MonthlyWish(monthKey: '2026-02', text: 'PS5')],
      );

      expect(member.completionPercentage, 1.0);
      expect(member.missingFields, isEmpty);
    });

    test('fromJson and toJson roundtrip preserves sharedWith', () {
      final original = Member(
        id: 'rt-1',
        name: 'Roundtrip',
        gradient: 'blue',
        ownerId: 'owner-x',
        sharedWith: ['u1', 'u2', 'u3'],
      );

      final json = original.toJson();
      final restored = Member.fromJson(json);

      expect(restored.sharedWith, ['u1', 'u2', 'u3']);
      expect(restored.ownerId, 'owner-x');
    });
  });
}
