import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  String? id;
  String? alias;
  String? photoUrl;
  String? role;
  bool? isBanned;

  AppUser({
    required this.id,
    required this.alias,
    required this.photoUrl,
    required this.role,
    required this.isBanned,
  });
}

class UserProvider {
  AppUser user =
      AppUser(alias: '', id: '', photoUrl: '', role: '', isBanned: false);

  String? get alias => user.alias;
  String? get id => user.id;
  String? get photoUrl => user.photoUrl;
  String? get role => user.role;
  bool? get isBanned => user.isBanned;

  void set setId(String? id) {
    user.id = id;
  }

  void set setAlias(String? alias) {
    user.alias = alias;
  }

  void set setPhotoUrl(String? photoUrl) {
    user.photoUrl = photoUrl;
  }

  void set setRole(String? role) {
    user.role = role;
  }

  void set setIsBanned(bool? isBanned) {
    user.isBanned = isBanned;
  }

  Future<void> initUser(SharedPreferences prefs) async {
    String? id = await prefs.getString('id');
    String? alias = await prefs.getString('alias');
    String? photoUrl = await prefs.getString('photoUrl');
    String? role = await prefs.getString('role');
    bool? isBanned = await prefs.getBool('isBanned');
    this.setId = id;
    this.setAlias = alias;
    this.setPhotoUrl = photoUrl;
    this.setRole = role;
    this.setIsBanned = isBanned;
  }
}
