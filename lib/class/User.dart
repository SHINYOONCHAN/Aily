class User {
  final String username;
  final String profile;

  User({required this.username, required this.profile});

  factory User.withDefaultProfile({required String username}) {
    return User(username: username, profile: 'http://211.201.93.173:8080/static/images/default/image.png');
  }
}
