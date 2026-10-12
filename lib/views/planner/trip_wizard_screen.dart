import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../services/itinerary_engine.dart';
import '../../theme/app_theme.dart';
import '../navigation_shell.dart';

class TripWizardScreen extends StatefulWidget {
  const TripWizardScreen({super.key});

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> {
  final _titleController = TextEditingController(text: 'My Egyptian Journey');
  String _selectedDestinationId = 'all'; // Default to All Egypt
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.nileTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.explore_outlined, color: AppColors.papyrusGold, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'صمم رحلتك بنفسك' : 'Customize Your Own Trip',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          isAr ? 'حدد الخيارات ثم انتقل للاستكشاف لإضافة الأماكن والأوقات' : 'Set details, then explore places & pick visit days & times',
                          style: const TextStyle(color: AppColors.desertSand, fontSize: 12),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: isAr ? 'مثال: جولة معالم مصر الكبرى' : 'e.g. Grand Tour of Egypt',
                prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.nileTeal),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Select Main City / All Egypt Option
            Text(
              isAr ? 'اختر المدينة / الوجهة (أو كل مصر)' : 'Select Destination City (or All Egypt)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestinationId,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.nileTeal)),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    isAr ? 'جميع أنحاء مصر (كل المحافظات)' : 'All Egypt (All Governorates)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.nileTeal),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
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

                return ChoiceChip(
                  label: Text(label),
                  selected: isSel,
                  selectedColor: AppColors.papyrusGold,
                  backgroundColor: AppColors.desertSand,
                  checkmarkColor: AppColors.nileTeal,
                  labelStyle: TextStyle(
                    color: isSel ? AppColors.nileTeal : AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _travelerCount = count),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Budget Tier
            Text(
              isAr ? 'فئة الميزانية' : 'Budget Tier',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Budget', 'Moderate', 'Luxury'].map((b) {
                final isSel = _selectedBudget == b;
                return ChoiceChip(
                  label: Text(b),
                  selected: isSel,
                  selectedColor: AppColors.nileTeal,
                  backgroundColor: AppColors.desertSand,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _selectedBudget = b),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 5. Trip Duration in Days
            Text(
              isAr ? 'عدد أيام الرحلة المتاحة' : 'Free Trip Days',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 3, 5, 7, 10].map((days) {
                final isSel = _daysCount == days;
                return ChoiceChip(
                  label: Text('$days ${isAr ? 'أيام' : 'Days'}'),
                  selected: isSel,
                  selectedColor: AppColors.nileTeal,
                  backgroundColor: AppColors.desertSand,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _daysCount = days),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Go to Explore Button
            ElevatedButton.icon(
              onPressed: () => _createTripAndOpenExplore(provider, isAr),
              icon: const Icon(Icons.travel_explore_rounded),
              label: Text(isAr ? 'الانتقال لاستكشاف وإضافة الأماكن والأوقات' : 'Go to Explore & Pick Places with Times'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.nileTeal,
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

    // Generate initialized trip
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
        backgroundColor: AppColors.nileTeal,
        duration: const Duration(seconds: 4),
      ),
    );

    // Route directly to the Explore Page (Tab index 1)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NavigationShell(initialIndex: 1),
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
