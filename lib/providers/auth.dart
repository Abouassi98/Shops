import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exceptions.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Auth with ChangeNotifier {
  String _token;
  DateTime _expireyDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expireyDate != null &&
        _expireyDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } 
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB2wKkTNwHwHtW32t50db0GpqpJAgmguMc';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw Http_Exceptions(message: responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireyDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autologout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireyDate': _expireyDate.toIso8601String(),
       
      });
      prefs.setString('userData', userData);

    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractUserData =
        json.decode(prefs.get('userData')) as Map<String, dynamic>;

    final expiryData = DateTime.parse(extractUserData['expireyDate']);
    if (expiryData.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractUserData['token'];
    _userId = extractUserData['userId'];
    _expireyDate = expiryData;
    notifyListeners();
   _autologout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireyDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    FirebaseAuth.instance.signOut();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autologout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timerExpary = _expireyDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timerExpary), logout);
  }
}
