import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class TransportPlannerScreen extends StatelessWidget {
  const TransportPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('transportPlanner'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TourismDatabase.defaultTransportOptions.length,
        itemBuilder: (context, index) {
          final t = TourismDatabase.defaultTransportOptions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? t.titleAr : t.titleEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        provider.formatPrice(t.priceEgp, t.priceUsd),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.mode,
                    style: const TextStyle(color: AppColors.nileTeal, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? t.notesAr : t.notesEn,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${t.estimatedDurationMinutes} mins average leg duration', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
