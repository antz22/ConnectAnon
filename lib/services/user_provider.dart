import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  String? id;
  String? alias;
  String? photoUrl;
  String? status;
  bool? isBanned;

  AppUser({
    required this.id,
    required this.alias,
    required this.photoUrl,
    required this.status,
    required this.isBanned,
  });
}

class UserProvider {
  AppUser user =
      AppUser(alias: '', id: '', photoUrl: '', status: '', isBanned: false);

  String? get alias => user.alias;
  String? get id => user.id;
  String? get photoUrl => user.photoUrl;
  String? get status => user.status;
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

  void set setStatus(String? status) {
    user.status = status;
  }

  void set setIsBanned(bool? isBanned) {
    user.isBanned = isBanned;
  }

  Future<void> initUser(SharedPreferences prefs) async {
    String? id = await prefs.getString('id');
    String? alias = await prefs.getString('alias');
    String? photoUrl = await prefs.getString('photoUrl');
    String? status = await prefs.getString('status');
    bool? isBanned = await prefs.getBool('isBanned');
    this.setId = id;
    this.setAlias = alias;
    this.setPhotoUrl = photoUrl;
    this.setStatus = status;
    this.setIsBanned = isBanned;
  }
}
