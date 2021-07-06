import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/data/store.dart';
import 'package:shop_app/exceptions/auth_exception.dart';
import 'package:shop_app/key/appKeys.dart';

class Auth with ChangeNotifier {
  String? _userId;
  String? _token;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()))
      return _token!;
    else
      return null;
  }

  Future<void> _autheticate(
      String email, String password, String urlSegment) async {
    final response = await http.post(
      urlSegment == 'login' ? AppKeys.singin() : AppKeys.singup(),
      body: json.encode(
        {
          "email": email,
          "password": password,
          "returnSecureToken": true,
        },
      ),
    );

    final responseBody = json.decode(response.body);
    if (responseBody["error"] != null) {
      throw AuthException(responseBody["error"]["message"]);
    } else {
      _token = responseBody["idToken"];
      _userId = responseBody["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody["expiresIn"]),
        ),
      );

      Store.saveMap('userData', {
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate?.toIso8601String()
      });
      _autoLogout();
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) return Future.value();

    final userData = await Store.getMap('userData');
    if (userData == null) return Future.value();

    final expiryData = DateTime.parse(userData['expiryDate']);
    if (expiryData.isBefore(DateTime.now())) return Future.value();

    _token = userData["token"];
    _userId = userData["userId"];
    _expiryDate = expiryData;

    _autoLogout();
    notifyListeners();
    return Future.value();
  }

  Future<void> singup(String email, String password) async {
    await _autheticate(email, password, "cadastro");
  }

  Future<void> login(String email, String password) async {
    await _autheticate(email, password, "login");
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_logoutTimer != null) {
      _logoutTimer?.cancel();
      _logoutTimer = null;
    }
    Store.remove('userData');
    notifyListeners();
  }

  void _autoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
    }
    final timeToLogout =
        _expiryDate?.difference(DateTime.now()).inSeconds ?? 500;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
