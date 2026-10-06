import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart';
import 'config.dart';

final AesGcm _aesGcm = AesGcm.with256bits();

String searchHash(String value) {
  final mac = c.Hmac(c.sha256, utf8.encode(ServerConfig.encryptionKey));
  return base64Url.encode(mac.convert(utf8.encode(value.trim())).bytes);
}

Future<String> encryptField(String plaintext, {required String aad}) async {
  final salt = _randomBytes(16);
  final box = await _aesGcm.encrypt(
    utf8.encode(plaintext),
    secretKey: SecretKey(_deriveKey(salt, aad)),
    nonce: _randomBytes(12),
    aad: utf8.encode(aad),
  );
  final packed = BytesBuilder()..add(salt)..add(box.nonce)..add(box.cipherText)..add(box.mac.bytes);
  return 'v1.' + base64Url.encode(packed.takeBytes()).replaceAll('=', '');
}

Future<String?> decryptField(String encoded, {required String aad}) async {
  try {
    if (!encoded.startsWith('v1.')) return null;
    final body = encoded.substring(3);
    final padded = body + '=' * ((4 - body.length % 4) % 4);
    final packed = base64Url.decode(padded);
    if (packed.length < 44) return null;
    final salt = packed.sublist(0, 16);
    final iv = packed.sublist(16, 28);
    final tag = packed.sublist(packed.length - 16);
    final ct = packed.sublist(28, packed.length - 16);
    final clear = await _aesGcm.decrypt(
      SecretBox(ct, nonce: iv, mac: Mac(tag)),
      secretKey: SecretKey(_deriveKey(salt, aad)),
      aad: utf8.encode(aad),
    );
    return utf8.decode(clear);
  } catch (_) { return null; }
}

Uint8List _deriveKey(Uint8List salt, String aad) => Uint8List.fromList(
    c.sha256.convert([
      ...utf8.encode(ServerConfig.encryptionKey),
      ...salt,
      ...utf8.encode(aad),
    ]).bytes,
  );

Uint8List _randomBytes(int n) {
  final rand = Random.secure();
  return Uint8List.fromList(List<int>.generate(n, (_) => rand.nextInt(256)));
}

