import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import '../widgets/apple_touchable.dart';

void showCurrencyConverterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CurrencyConverterModal(),
  );
}

class CurrencyConverterModal extends StatefulWidget {
  const CurrencyConverterModal({super.key});

  @override
  State<CurrencyConverterModal> createState() => _CurrencyConverterModalState();
}

class _CurrencyConverterModalState extends State<CurrencyConverterModal> {
  final TextEditingController _amountController = TextEditingController(text: '1000');
  String _fromCode = 'EGP';
  String _toCode = 'USD';
  double _convertedValue = 0.0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _convertedValue = CurrencyService.convert(
        amount: amount,
        fromCode: _fromCode,
        toCode: _toCode,
      );
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCode;
      _fromCode = _toCode;
      _toCode = temp;
    });
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAr = provider.isArabic;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final toCurrency = CurrencyService.currencies.firstWhere((c) => c.code == _toCode);

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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

          // Modal Title
          Row(
            children: [
              const Icon(Icons.currency_exchange_rounded, color: AppColors.primaryOrange, size: 28),
              const SizedBox(width: 10),
              Text(
                isAr ? 'حاسبة تحويل العملات المباشرة' : 'Real-Time Currency Converter',
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
            isAr ? 'تحويل فوري لأسعار الصرف للجنيه المصري والدولار واليورو' : 'Instant live exchange rates for EGP, USD, EUR & top currencies.',
            style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Amount Input Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculate(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0.00',
                      labelText: isAr ? 'المبلغ المطلوب تحويله' : 'Amount to Convert',
                      labelStyle: const TextStyle(color: AppColors.mediumGray, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _fromCode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryOrange),
                  items: CurrencyService.currencies.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.code,
                      child: Text(
                        '${c.flagSymbol} ${c.code}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _fromCode = val);
                      _recalculate();
                    }
                  },
                ),
              ],
            ),
          ),

          // Swap Action Button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppleTouchable(
                pressedScale: 0.88,
                onTap: _swapCurrencies,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryOrange, size: 24),
                ),
              ),
            ),
          ),

          // Converted Result Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.sunsetOrangeGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'النتيجة المحولة' : 'Converted Value',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${toCurrency.flagSymbol} ${_convertedValue.toStringAsFixed(2)} ${toCurrency.code}',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: _toCode,
                  dropdownColor: AppColors.darkGray,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                  items: CurrencyService.currencies.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.code,
                      child: Text(
                        '${c.flagSymbol} ${c.code}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _toCode = val);
                      _recalculate();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Presets Chips (e.g. Pyramid Ticket, Meal, Nile Cruise, Hotel)
          Text(
            isAr ? 'مبالغ سريعة شائعة في مصر:' : 'Quick Travel Presets:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkGray),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetChip('250 EGP', isAr ? 'تذكرة مزار' : 'Ticket'),
              _buildPresetChip('600 EGP', isAr ? 'وجبة طعام' : 'Meal'),
              _buildPresetChip('2500 EGP', isAr ? 'فندق / ليلة' : 'Hotel Night'),
              _buildPresetChip('5000 EGP', isAr ? 'رحلة نيلية' : 'Nile Cruise'),
            ],
          ),
          const SizedBox(height: 20),

          // Apply Currency as Default App Currency Button
          AppleTouchable(
            onTap: () {
              provider.setCurrency(_toCode);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAr
                        ? 'تم اعتماد $_toCode كعملة العرض الأساسية بالتطبيق!'
                        : 'Updated default app currency to $_toCode!',
                  ),
                  backgroundColor: AppColors.primaryPurple,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.royalPurpleGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isAr ? 'اعتماد $_toCode كعملة أساسية بالتطبيق' : 'Set $_toCode as Default App Currency',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String amountEgp, String label) {
    return AppleTouchable(
      pressedScale: 0.92,
      onTap: () {
        final val = amountEgp.split(' ')[0];
        setState(() {
          _amountController.text = val;
          _fromCode = 'EGP';
        });
        _recalculate();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          '$amountEgp ($label)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGray),
        ),
      ),
    );
  }
}
