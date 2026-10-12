import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../services/itinerary_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../navigation_shell.dart';

class TripWizardScreen extends StatefulWidget {
  const TripWizardScreen({super.key});

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> {
  String _selectedDestinationId = 'cairo';
  int _daysCount = 3;
  int _travelerCount = 2;
  final _titleController = TextEditingController(text: 'Egyptian Odyssey');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('startPlanning'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'اسم الرحلة' : 'Trip Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'e.g. Cairo & Pyramids Discovery'),
            ),
            const SizedBox(height: 20),

            Text(
              isAr ? 'اختر الوجهة الرئيسية' : 'Select Destination',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestinationId,
              decoration: const InputDecoration(),
              items: TourismDatabase.destinations.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(isAr ? d.nameAr : d.nameEn),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDestinationId = val);
              },
            ),
            const SizedBox(height: 20),

            Text(
              isAr ? 'عدد أيام الرحلة: $_daysCount أيام' : 'Trip Duration: $_daysCount Days',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Slider(
              value: _daysCount.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.nileTeal,
              label: '$_daysCount days',
              onChanged: (val) => setState(() => _daysCount = val.toInt()),
            ),
            const SizedBox(height: 20),

            Text(
              isAr ? 'عدد المسافرين: $_travelerCount' : 'Travelers Count: $_travelerCount',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Slider(
              value: _travelerCount.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              activeColor: AppColors.terracotta,
              label: '$_travelerCount travelers',
              onChanged: (val) => setState(() => _travelerCount = val.toInt()),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                final attractionIds = TourismDatabase.attractions
                    .where((a) => a.destinationId == _selectedDestinationId)
                    .map((a) => a.id)
                    .toList();

                final trip = ItineraryEngine.generateAutoTrip(
                  title: _titleController.text.trim().isEmpty ? 'Egyptian Journey' : _titleController.text.trim(),
                  destinationId: _selectedDestinationId,
                  attractionIds: attractionIds,
                  startDate: DateTime.now().add(const Duration(days: 7)),
                  daysCount: _daysCount,
                  travelerCount: _travelerCount,
                );

                provider.addTrip(trip);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NavigationShell(initialIndex: 3)),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.nileTeal,
              ),
              child: Text(
                loc.translate('confirmTrip'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
