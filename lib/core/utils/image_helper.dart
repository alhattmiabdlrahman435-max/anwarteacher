import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

bool isNetworkUrl(String? url) =>
    url != null && url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));

bool isBase64Image(String? url) =>
    url != null && url.isNotEmpty && url.startsWith('data:image/') && url.contains('base64,');

Uint8List? bytesFromBase64(String? base64Str) {
  if (base64Str == null || base64Str.isEmpty) return null;
  try {
    final commaIndex = base64Str.indexOf(',');
    if (commaIndex != -1) {
      final data = base64Str.substring(commaIndex + 1);
      return base64Decode(data);
    }
  } catch (e) {
    debugPrint('Error decoding base64 image: $e');
  }
  return null;
}

ImageProvider? getImageProvider(String? photoUrl) {
  if (isNetworkUrl(photoUrl)) {
    return NetworkImage(photoUrl!);
  }
  if (isBase64Image(photoUrl)) {
    final bytes = bytesFromBase64(photoUrl);
    if (bytes != null) {
      return MemoryImage(bytes);
    }
  }
  return null;
}

String avatarLabel(String? photoUrl, String name) {
  if (photoUrl != null && photoUrl.isNotEmpty && !isNetworkUrl(photoUrl) && !isBase64Image(photoUrl)) {
    return photoUrl;
  }
  return name.isNotEmpty ? name[0] : '?';
}
