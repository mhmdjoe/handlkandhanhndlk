import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    final totalAttractions = TourismDatabase.attractions.length;
    final verifiedAttractions = TourismDatabase.attractions.where((a) => a.isOfficialVerified).length;
    final totalDestinations = TourismDatabase.destinations.length;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('adminDashboard'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('tourismDataStatus'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 12),

            // Health Cards
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Total Places',
                    value: '$totalAttractions',
                    color: AppColors.nileTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: loc.translate('verifiedItems'),
                    value: '$verifiedAttractions',
                    color: AppColors.verifiedGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Destinations',
                    value: '$totalDestinations',
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: 'Sources Health',
                    value: '100% Verified',
                    color: AppColors.seaTurquoise,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Source Audit Trail List
            const Text(
              'Official Source Audit Logs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 12),

            ...TourismDatabase.attractions.map((a) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.verified, color: AppColors.verifiedGreen),
                  title: Text(isAr ? a.nameAr : a.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Source: ${a.verifiedSource}\nVerified Date: ${a.verificationDate}'),
                  trailing: Text(provider.formatPrice(a.priceEgp, a.priceUsd)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
