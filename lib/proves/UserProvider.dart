import 'package:flutter/foundation.dart';
import 'package:Aily/class/User.dart';

class UserProvider extends ChangeNotifier {
  late User _user;

  User get user => _user;

  UserProvider() {
    _user = User.withDefaultProfile(username: '홍길동');
  }

  void updateUsername(String newUsername) {
    final newUser = User(username: newUsername, profile: _user.profile);
    updateUser(newUser);
  }

  void updateProfile(Uint8List newProfile) {
    final User newUser = User(username: _user.username, profile: Future.value(newProfile));
    updateUser(newUser);
  }

  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }
}