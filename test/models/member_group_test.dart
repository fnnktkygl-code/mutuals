import 'package:flutter_test/flutter_test.dart';
import 'package:famille_io/models/member_group.dart';

void main() {
  group('MemberGroup', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'group-1',
        'name': 'Family',
        'icon': '❤️',
        'color': '#FF0000',
        'order': 1,
        'isDefault': true,
      };

      final group = MemberGroup.fromJson(json);

      expect(group.id, 'group-1');
      expect(group.name, 'Family');
      expect(group.icon, '❤️');
      expect(group.color, '#FF0000');
      expect(group.order, 1);
      expect(group.isDefault, true);
    });

    test('toJson produces correct map', () {
      const group = MemberGroup(
        id: 'group-2',
        name: 'Friends',
        icon: '👥',
        color: '#00FF00',
        order: 2,
      );

      final json = group.toJson();

      expect(json['id'], 'group-2');
      expect(json['name'], 'Friends');
      expect(json['icon'], '👥');
      expect(json['color'], '#00FF00');
      expect(json['order'], 2);
    });

    test('equality works based on ID', () {
      const group1 = MemberGroup(
        id: '1',
        name: 'A',
        icon: 'A',
        color: 'A',
        order: 1,
      );
      const group2 = MemberGroup(
        id: '1',
        name: 'B', // Name diff shouldn't matter for equality if ID is same
        icon: 'B',
        color: 'B',
        order: 2,
      );
      const group3 = MemberGroup(
        id: '2',
        name: 'A',
        icon: 'A',
        color: 'A',
        order: 1,
      );

      expect(group1, group2);
      expect(group1, isNot(group3));
    });
  });
}
