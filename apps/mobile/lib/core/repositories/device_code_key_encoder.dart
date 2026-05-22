import 'dart:convert';

import 'package:crypto/crypto.dart';

class DeviceCodeKeyEncoder {
  const DeviceCodeKeyEncoder();

  String normalize(String code) {
    return code.trim().replaceAll(RegExp(r'[\s-]+'), '').toUpperCase();
  }

  String encode(String code) {
    final normalized = normalize(code);
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
