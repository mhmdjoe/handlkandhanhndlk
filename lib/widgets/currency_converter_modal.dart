import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import '../widgets/apple_touchable.dart';

void showCurrencyConverterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const CurrencyPickerModal(),
  );
}

class CurrencyPickerModal extends StatelessWidget {
  const CurrencyPickerModal({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAr = provider.isArabic;
    final currentCurrency = provider.currency;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              const Icon(Icons.currency_exchange_rounded, color: AppColors.primaryOrange, size: 28),
              const SizedBox(width: 10),
              Text(
                isAr ? 'عملة عرض الأسعار بالتطبيق' : 'Select App Currency',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? 'اختر العملة المفضلة لعرض تكاليف الرحلات والتذاكر والفنادق' : 'Choose your preferred currency for trips, tickets & hotels.',
            style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Currency Options List
          ...CurrencyService.currencies.map((currency) {
            final isSelected = currentCurrency == currency.code;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: AppleTouchable(
                pressedScale: 0.97,
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  provider.setCurrency(currency.code);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.darkGray,
                      content: Text(
                        isAr
                            ? 'تم اعتماد ${currency.flagSymbol} ${currency.nameAr} (${currency.code}) كعملة العرض!'
                            : 'App display currency set to ${currency.flagSymbol} ${currency.nameEn} (${currency.code})!',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightOrange : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryOrange : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        currency.flagSymbol,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? currency.nameAr : currency.nameEn,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected ? AppColors.primaryOrange : AppColors.darkGray,
                              ),
                            ),
                            Text(
                              currency.code == 'EGP'
                                  ? (isAr ? 'العملة الأساسية (جم)' : 'Base Currency (EGP)')
                                  : '1 ${currency.code} ≈ ${currency.rateToEgp.toStringAsFixed(1)} EGP',
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryOrange : AppColors.mediumGray,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryOrange,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
