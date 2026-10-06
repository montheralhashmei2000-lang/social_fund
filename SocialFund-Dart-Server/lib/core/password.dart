import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

const int kPbkdf2Iterations = 200000;

Future<String> hashPassword(String password) async {
  final salt = _randomBytes(16);
  final hash = await _derive(password, salt, kPbkdf2Iterations);
  return ['pbkdf2_sha256', kPbkdf2Iterations, base64Url.encode(salt), base64Url.encode(hash)].join(r'$');
}

Future<bool> verifyPassword(String password, String stored) async {
  try {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != 'pbkdf2_sha256') return false;
    final iterations = int.parse(parts[1]);
    final salt = base64Url.decode(parts[2]);
    final expected = base64Url.decode(parts[3]);
    final actual = await _derive(password, salt, iterations);
    return constantTimeEquals(expected, actual);
  } catch (_) { return false; }
}

bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) { diff |= a[i] ^ b[i]; }
  return diff == 0;
}

Future<List<int>> _derive(String password, List<int> salt, int iterations) async {
  final algo = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
  final key = await algo.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  return key.extractBytes();
}

List<int> _randomBytes(int n) {
  final rand = Random.secure();
  return List<int>.generate(n, (_) => rand.nextInt(256));
}
