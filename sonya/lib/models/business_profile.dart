class BusinessProfile {
  final String businessName;
  final String ownerName;
  final String mobile;
  final String address;
  final String village;
  final String? logoPath;
  final double defaultRatePerTon;
  final String languageCode;
  final bool isDarkMode;

  const BusinessProfile({
    this.businessName = 'मुरघास कृषी सेवा',
    this.ownerName = 'सोन्या',
    this.mobile = '',
    this.address = '',
    this.village = '',
    this.logoPath,
    this.defaultRatePerTon = 1200.0,
    this.languageCode = 'mr',
    this.isDarkMode = false,
  });

  BusinessProfile copyWith({
    String? businessName,
    String? ownerName,
    String? mobile,
    String? address,
    String? village,
    String? logoPath,
    double? defaultRatePerTon,
    String? languageCode,
    bool? isDarkMode,
    bool clearLogo = false,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      village: village ?? this.village,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      defaultRatePerTon: defaultRatePerTon ?? this.defaultRatePerTon,
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
