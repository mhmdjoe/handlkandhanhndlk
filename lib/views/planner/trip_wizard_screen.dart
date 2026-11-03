import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../services/itinerary_engine.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
import '../navigation_shell.dart';

class TripWizardScreen extends StatefulWidget {
  const TripWizardScreen({super.key});

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> {
  final _titleController = TextEditingController(text: 'My Egyptian Journey');
  String _selectedDestinationId = 'all';
  int _travelerCount = 2;
  String _selectedBudget = 'Moderate';
  int _daysCount = 3;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAr = provider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'تصميم رحلة مخصصة' : 'Custom Trip Builder'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.papyrusGold, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'صمم رحلتك بنفسك' : 'Customize Your Own Trip',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr ? 'حدد الخيارات ثم انتقل للاستكشاف لإضافة الأماكن والأوقات' : 'Set details, then explore places & pick visit days & times',
                          style: const TextStyle(color: AppColors.lightPurple, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Trip Name
            Text(
              isAr ? 'اسم الرحلة' : 'Trip Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: isAr ? 'مثال: جولة معالم مصر الكبرى' : 'e.g. Grand Tour of Egypt',
                prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.primaryPurple),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Select Main City / All Egypt Option
            Text(
              isAr ? 'اختر المدينة / الوجهة (أو كل مصر)' : 'Select Destination City (or All Egypt)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestinationId,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primaryPurple)),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    isAr ? 'جميع أنحاء مصر (كل المحافظات)' : 'All Egypt (All Governorates)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                  ),
                ),
                ...TourismDatabase.destinations.map((d) {
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text(isAr ? d.nameAr : d.nameEn),
                  );
                }),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDestinationId = val);
                }
              },
            ),
            const SizedBox(height: 20),

            // 3. Number of Travelers
            Text(
              isAr ? 'عدد المسافرين' : 'Number of Travelers',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 3, 4, 5, 6].map((count) {
                final isSel = _travelerCount == count;
                final label = count == 1
                    ? (isAr ? '1 مسافر' : '1 Solo')
                    : '$count ${isAr ? 'مسافرين' : 'Travelers'}';

                return AppleTouchable(
                  pressedScale: 0.92,
                  onTap: () => setState(() => _travelerCount = count),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    onSelected: null,
                    selectedColor: AppColors.primaryOrange,
                    backgroundColor: AppColors.lightPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Budget Tier
            Text(
              isAr ? 'فئة الميزانية' : 'Budget Tier',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Budget', 'Moderate', 'Luxury', 'Eco Lodge'].map((b) {
                final isSel = _selectedBudget == b;
                return AppleTouchable(
                  pressedScale: 0.92,
                  onTap: () => setState(() => _selectedBudget = b),
                  child: ChoiceChip(
                    label: Text(b),
                    selected: isSel,
                    onSelected: null,
                    selectedColor: AppColors.primaryPurple,
                    backgroundColor: AppColors.lightPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 5. Trip Duration in Days
            Text(
              isAr ? 'عدد أيام الرحلة المتاحة' : 'Free Trip Days',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 3, 5, 7, 10].map((days) {
                final isSel = _daysCount == days;
                return AppleTouchable(
                  pressedScale: 0.92,
                  onTap: () => setState(() => _daysCount = days),
                  child: ChoiceChip(
                    label: Text('$days ${isAr ? 'أيام' : 'Days'}'),
                    selected: isSel,
                    onSelected: null,
                    selectedColor: AppColors.primaryOrange,
                    backgroundColor: AppColors.lightPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Go to Explore Button
            AppleTouchable(
              onTap: () => _createTripAndOpenExplore(provider, isAr),
              child: ElevatedButton.icon(
                onPressed: () => _createTripAndOpenExplore(provider, isAr),
                icon: const Icon(Icons.travel_explore_rounded),
                label: Text(isAr ? 'الانتقال لاستكشاف وإضافة الأماكن والأوقات' : 'Go to Explore & Pick Places with Times'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createTripAndOpenExplore(AppProvider provider, bool isAr) {
    final destinationId = _selectedDestinationId == 'all' ? 'cairo' : _selectedDestinationId;

    final targetAttractions = _selectedDestinationId == 'all'
        ? TourismDatabase.attractions.map((a) => a.id).toList()
        : TourismDatabase.attractions.where((a) => a.destinationId == _selectedDestinationId).map((a) => a.id).toList();

    final tripName = _titleController.text.trim().isEmpty
        ? (isAr ? 'رحلة $selectedCityName' : 'My $selectedCityName Holiday')
        : _titleController.text.trim();

    final trip = ItineraryEngine.generateAutoTrip(
      title: tripName,
      destinationId: destinationId,
      attractionIds: targetAttractions,
      startDate: DateTime.now().add(const Duration(days: 7)),
      daysCount: _daysCount,
      travelerCount: _travelerCount,
    );

    provider.addTrip(trip);
    provider.setDestinationFilter(_selectedDestinationId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'تم تجهيز الرحلة! تصفح الأماكن واضغط (+) لإضافتها باليوم والتوقيت المناسب.'
              : 'Trip initialized! Browse places below and tap (+) Add to Trip to pick days & times.',
        ),
        backgroundColor: AppColors.primaryPurple,
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.pushReplacement(
      context,
      AppCupertinoPageRoute(
        page: const NavigationShell(initialIndex: 1),
      ),
    );
  }

  String get selectedCityName {
    if (_selectedDestinationId == 'all') {
      return 'All Egypt';
    }
    final dest = TourismDatabase.destinations.firstWhere(
      (d) => d.id == _selectedDestinationId,
      orElse: () => TourismDatabase.destinations.first,
    );
    return dest.nameEn;
  }
}
