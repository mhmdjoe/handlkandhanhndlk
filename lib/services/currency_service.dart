class CurrencyRate {
  final String code;
  final String nameEn;
  final String nameAr;
  final String flagSymbol;
  final double rateToEgp; // How many EGP is 1 unit of this currency

  const CurrencyRate({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.flagSymbol,
    required this.rateToEgp,
  });
}

class CurrencyService {
  static const List<CurrencyRate> currencies = [
    CurrencyRate(
      code: 'EGP',
      nameEn: 'Egyptian Pound',
      nameAr: 'جنيه مصري',
      flagSymbol: '🇪🇬',
      rateToEgp: 1.0,
    ),
    CurrencyRate(
      code: 'USD',
      nameEn: 'US Dollar',
      nameAr: 'دولار أمريكي',
      flagSymbol: '🇺🇸',
      rateToEgp: 49.5,
    ),
    CurrencyRate(
      code: 'EUR',
      nameEn: 'Euro',
      nameAr: 'يورو أوروبي',
      flagSymbol: '🇪🇺',
      rateToEgp: 54.0,
    ),
    CurrencyRate(
      code: 'GBP',
      nameEn: 'British Pound',
      nameAr: 'جنيه إسترليني',
      flagSymbol: '🇬🇧',
      rateToEgp: 64.5,
    ),
    CurrencyRate(
      code: 'SAR',
      nameEn: 'Saudi Riyal',
      nameAr: 'ريال سعودي',
      flagSymbol: '🇸🇦',
      rateToEgp: 13.2,
    ),
    CurrencyRate(
      code: 'AED',
      nameEn: 'UAE Dirham',
      nameAr: 'درهم إماراتي',
      flagSymbol: '🇦🇪',
      rateToEgp: 13.5,
    ),
  ];

  /// Convert an amount from one currency to another
  static double convert({
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    final fromRate = currencies.firstWhere(
      (c) => c.code == fromCode,
      orElse: () => currencies[0],
    ).rateToEgp;

    final toRate = currencies.firstWhere(
      (c) => c.code == toCode,
      orElse: () => currencies[0],
    ).rateToEgp;

    // Convert to EGP first, then to target currency
    final egpAmount = amount * fromRate;
    return egpAmount / toRate;
  }
}
