import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class EnhancedEncryptionUtil {
  // 使用PBKDF2生成密钥
  static Key deriveKey(String password, Uint8List salt) {
    final generator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    generator.init(Pbkdf2Parameters(salt, 10000, 32)); // 10000次迭代
    final key = generator.process(utf8.encode(password));
    return Key(key);
  }

  // 生成随机盐值
  static Uint8List generateSalt() {
    final secureRandom = SecureRandom('Fortuna');
    final salt = Uint8List(16);
    secureRandom.nextBytes(salt);
    return salt;
  }

  // 加密数据
  static EncryptedData encryptData(List<int> data, String password) {
    final salt = generateSalt();
    final key = deriveKey(password, salt);
    final iv = IV.fromSecureRandom(16);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encryptBytes(data, iv: iv);

    // 计算MAC
    final mac = _calculateMac(encrypted.bytes, key.bytes);

    return EncryptedData(
      data: encrypted.bytes,
      iv: iv.bytes,
      salt: salt,
      mac: mac,
    );
  }

  // 解密数据
  static List<int> decryptData(EncryptedData encryptedData, String password) {
    final key = deriveKey(password, encryptedData.salt);
    
    // 验证MAC
    final calculatedMac = _calculateMac(encryptedData.data, key.bytes);
    if (!_compareMacs(calculatedMac, encryptedData.mac)) {
      throw Exception('数据完整性验证失败');
    }

    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final decrypted = encrypter.decryptBytes(
      Encrypted(encryptedData.data),
      iv: IV(encryptedData.iv),
    );

    return decrypted;
  }

  // 计算MAC
  static List<int> _calculateMac(List<int> data, List<int> key) {
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(data);
    return digest.bytes;
  }

  // 安全比较MAC
  static bool _compareMacs(List<int> mac1, List<int> mac2) {
    if (mac1.length != mac2.length) return false;
    
    var result = 0;
    for (var i = 0; i < mac1.length; i++) {
      result |= mac1[i] ^ mac2[i];
    }
    return result == 0;
  }
}

class EncryptedData {
  final List<int> data;
  final List<int> iv;
  final List<int> salt;
  final List<int> mac;

  EncryptedData({
    required this.data,
    required this.iv,
    required this.salt,
    required this.mac,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': base64Encode(data),
      'iv': base64Encode(iv),
      'salt': base64Encode(salt),
      'mac': base64Encode(mac),
    };
  }

  factory EncryptedData.fromJson(Map<String, dynamic> json) {
    return EncryptedData(
      data: base64Decode(json['data']),
      iv: base64Decode(json['iv']),
      salt: base64Decode(json['salt']),
      mac: base64Decode(json['mac']),
    );
  }
} 