import 'package:flutter/material.dart';
import '../models/business_profile.dart';
import '../repositories/business_repository.dart';
import '../utils/app_strings.dart';

class AppProvider extends ChangeNotifier {
  final BusinessRepository _repository;
  BusinessProfile _profile = const BusinessProfile();
  bool _isLoaded = false;

  AppProvider({BusinessRepository? repository})
      : _repository = repository ?? BusinessRepository();

  BusinessProfile get profile => _profile;
  bool get isLoaded => _isLoaded;
  ThemeMode get themeMode =>
      _profile.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String get languageCode => _profile.languageCode;
  AppStrings get strings => AppStrings(_profile.languageCode);

  Future<void> load() async {
    _profile = await _repository.loadProfile();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateProfile(BusinessProfile updated) async {
    _profile = updated;
    notifyListeners();
    await _repository.saveProfile(updated);
  }

  Future<void> toggleDarkMode(bool value) async {
    await updateProfile(_profile.copyWith(isDarkMode: value));
  }

  Future<void> setLanguage(String code) async {
    await updateProfile(_profile.copyWith(languageCode: code));
  }
}
