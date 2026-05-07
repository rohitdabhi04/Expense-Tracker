import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/theme.dart';

class SettingsProvider extends ChangeNotifier {
  bool _appLockEnabled = false;
  bool _hideBalance = false;
  bool _isUnlocked = false; // Used at runtime
  String _currency = '₹';

  bool get appLockEnabled => _appLockEnabled;
  bool get hideBalance => _hideBalance;
  bool get isUnlocked => !_appLockEnabled || _isUnlocked;
  String get currency => _currency;

  final LocalAuthentication _auth = LocalAuthentication();

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _appLockEnabled = prefs.getBool('appLockEnabled') ?? false;
    _hideBalance = prefs.getBool('hideBalance') ?? false;
    _currency = prefs.getString('currency') ?? '₹';
    AppConstants.currencySymbol = _currency;
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
    _currency = value;
    AppConstants.currencySymbol = value;
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool value) async {
    if (value) {
      // Trying to enable, check if device supports it
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) {
        // Cannot enable if device doesn't support it
        return;
      }
      
      // Prompt user to authenticate once to enable
      try {
        final didAuthenticate = await _auth.authenticate(
          localizedReason: 'Please authenticate to enable App Lock',
        );
        if (!didAuthenticate) return;
      } catch (e) {
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('appLockEnabled', value);
    _appLockEnabled = value;
    _isUnlocked = true; // Automatically unlocked since they just verified or disabled it
    notifyListeners();
  }

  Future<void> setHideBalance(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hideBalance', value);
    _hideBalance = value;
    notifyListeners();
  }

  Future<bool> authenticate() async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to open Expense Tracker',
      );
      if (didAuthenticate) {
        _isUnlocked = true;
        notifyListeners();
      }
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  void lockApp() {
    if (_appLockEnabled) {
      _isUnlocked = false;
      notifyListeners();
    }
  }
}
