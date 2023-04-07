import 'package:flutter/services.dart';

class User {
  final String username;
  final Future<Uint8List> profile;

  User({required this.username, required this.profile});

  static Future<Uint8List> loadDefaultProfileImage() async {
    final ByteData imageData = await rootBundle.load('assets/images/default.png');
    return imageData.buffer.asUint8List();
  }

  factory User.withDefaultProfile({required String username}) {
    return User(username: username, profile: loadDefaultProfileImage());
  }
}
