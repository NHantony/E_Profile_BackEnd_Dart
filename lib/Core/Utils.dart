import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:quiz_backend/Constraints.dart';

String generateToken(String subject) {
  final jwt = JWT(
    {'iat': DateTime.now().millisecondsSinceEpoch},
    subject: subject,
  );
  return jwt.sign(SecretKey(secretKey));
}

JWT? verityToken(String token) => JWT.tryVerify(token, SecretKey(secretKey));

String generateSalt([int length = 32]) {
  final random = Random.secure();
  final bytes = List.generate(length, (index) => random.nextInt(256));
  return base64.encode(bytes);
}

String hashPassword(String password, String salt) {
  const codec = Utf8Codec();
  final key = codec.encode(password);
  final saltBytes = codec.encode(salt);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(saltBytes);
  return digest.toString();
}
