import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile.dart';

class PreferencesService {
  static const _keyBusinessName = 'business_name';
  static const _keyOwnerName = 'owner_name';
  static const _keyMobile = 'mobile';
  static const _keyAddress = 'address';
  static const _keyVillage = 'village';
  static const _keyLogoPath = 'logo_path';
  static const _keyDefaultRate = 'default_rate_per_ton';
  static const _keyLanguage = 'language_code';
  static const _keyDarkMode = 'is_dark_mode';

  Future<BusinessProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return BusinessProfile(
      businessName: prefs.getString(_keyBusinessName) ?? 'मुरघास कृषी सेवा',
      ownerName: prefs.getString(_keyOwnerName) ?? 'सोन्या',
      mobile: prefs.getString(_keyMobile) ?? '',
      address: prefs.getString(_keyAddress) ?? '',
      village: prefs.getString(_keyVillage) ?? '',
      logoPath: prefs.getString(_keyLogoPath),
      defaultRatePerTon: prefs.getDouble(_keyDefaultRate) ?? 1200.0,
      languageCode: 'mr',
      isDarkMode: prefs.getBool(_keyDarkMode) ?? false,
    );
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessName, profile.businessName);
    await prefs.setString(_keyOwnerName, profile.ownerName);
    await prefs.setString(_keyMobile, profile.mobile);
    await prefs.setString(_keyAddress, profile.address);
    await prefs.setString(_keyVillage, profile.village);
    if (profile.logoPath != null) {
      await prefs.setString(_keyLogoPath, profile.logoPath!);
    } else {
      await prefs.remove(_keyLogoPath);
    }
    await prefs.setDouble(_keyDefaultRate, profile.defaultRatePerTon);
    await prefs.setString(_keyLanguage, profile.languageCode);
    await prefs.setBool(_keyDarkMode, profile.isDarkMode);
  }
}
