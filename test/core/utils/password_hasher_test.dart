import 'package:flutter_test/flutter_test.dart';
import 'package:opengps_nmea/core/utils/password_hasher.dart';

void main() {
  group('hashPassword', () {
    test('returns a 64-char hex string (SHA-256)', () {
      final hash = hashPassword('hello');
      expect(hash.length, 64);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
    });

    test('same input always produces same hash (deterministic)', () {
      expect(hashPassword('password123'), hashPassword('password123'));
    });

    test('different inputs produce different hashes', () {
      expect(hashPassword('abc'), isNot(hashPassword('xyz')));
    });

    test('empty string is hashable without crash', () {
      final hash = hashPassword('');
      expect(hash.length, 64);
    });

    test('matches known SHA-256 of "hello"', () {
      // SHA-256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
      expect(hashPassword('hello'),
          '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824');
    });

    test('unicode input is handled', () {
      final hash = hashPassword('héllo');
      expect(hash.length, 64);
    });
  });

  group('verifyPassword', () {
    test('returns true for matching plain and hash', () {
      final hash = hashPassword('mypassword');
      expect(verifyPassword('mypassword', hash), isTrue);
    });

    test('returns false for wrong password', () {
      final hash = hashPassword('mypassword');
      expect(verifyPassword('wrongpassword', hash), isFalse);
    });

    test('returns false for empty vs non-empty', () {
      final hash = hashPassword('notempty');
      expect(verifyPassword('', hash), isFalse);
    });
  });
}
