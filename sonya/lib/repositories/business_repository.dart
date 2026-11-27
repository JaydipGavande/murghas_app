import '../models/business_profile.dart';
import '../services/preferences_service.dart';

class BusinessRepository {
  final PreferencesService _prefsService;
  BusinessRepository({PreferencesService? prefsService})
      : _prefsService = prefsService ?? PreferencesService();

  Future<BusinessProfile> loadProfile() => _prefsService.loadProfile();
  Future<void> saveProfile(BusinessProfile profile) =>
      _prefsService.saveProfile(profile);
}
