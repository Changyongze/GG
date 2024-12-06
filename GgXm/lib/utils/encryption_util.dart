import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionUtil {
  // 加密密钥，实际应用中应该从安全的配置中获取
  static final _key = Key.fromUtf8('your32characterkey12345678901234');
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  // 加密数据
  static List<int> encrypt(List<int> data) {
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  // 解密数据
  static List<int> decrypt(List<int> encryptedData) {
    final encrypted = Encrypted(encryptedData as List<int>);
    return _encrypter.decryptBytes(encrypted, iv: _iv);
  }

  // 加密字符串
  static String encryptString(String text) {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  // 解密字符串
  static String decryptString(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // 生成密码哈希
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 验证密码
  static bool verifyPassword(String password, String hash) {
    final hashedInput = hashPassword(password);
    return hashedInput == hash;
  }
} 