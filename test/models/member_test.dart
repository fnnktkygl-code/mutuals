import 'package:flutter_test/flutter_test.dart';
import 'package:famille_io/models/member.dart';
import 'package:famille_io/models/fit_preference.dart';

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
  });
}
