import 'package:test/test.dart';
import 'package:onclo_mobile/models/activity.dart';

void main() {
  group('Activity', () {
    test('constructor normalizes name', () {
      final activity = Activity(' words    separated\nin\t weird-looking ways \n\t');
      expect(activity.name, 'words separated in weird-looking ways');
    });

    test('.words works', () {
      final activity = Activity('three extra-cool words');
      expect(activity.words, ['three', 'extra-cool', 'words']);
    });

    test('.== returns true when names match', () {
      expect(Activity('a  b\t\nc'), Activity('a \t b   c'));
    });

    test('.== returns false when names differ', () {
      expect(Activity('ab c'), isNot(Activity('a bc')));
    });

    test('.== returns false when types differ', () {
      expect(Activity('a b c'), isNot('a b c'));
    });

    test('.hashCode is hashCode of name', () {
      final activity = Activity('\na \tb    \nc ');
      expect(activity.hashCode, activity.name.hashCode);
    });
  });
}

