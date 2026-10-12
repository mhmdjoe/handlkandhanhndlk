import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../hotels/hotel_search_screen.dart';
import '../transport/transport_planner_screen.dart';
import '../map/interactive_map_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final user = provider.userProfile;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('userProfile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 110),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.nileTeal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.papyrusGold,
                    child: Icon(Icons.person, color: AppColors.nileTeal, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(color: AppColors.desertSand, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.login_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Links
            _buildTile(
              context,
              icon: Icons.explore_outlined,
              title: 'Welcome & Preference Quiz',
              color: AppColors.papyrusGold,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              },
            ),
            _buildTile(
              context,
              icon: Icons.favorite,
              title: loc.translate('favorites'),
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            _buildTile(
              context,
              icon: Icons.hotel,
              title: loc.translate('hotelsTitle'),
              color: AppColors.nileTeal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotelSearchScreen()),
                );
              },
            ),
            _buildTile(
              context,
              icon: Icons.directions_car,
              title: loc.translate('transportPlanner'),
              color: AppColors.terracotta,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransportPlannerScreen()),
                );
              },
            ),
            _buildTile(
              context,
              icon: Icons.map,
              title: loc.translate('mapView'),
              color: AppColors.seaTurquoise,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InteractiveMapScreen()),
                );
              },
            ),
            const Divider(height: 32),

            // Preferences Controls
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.nileTeal),
              title: Text(loc.translate('selectLanguage')),
              trailing: DropdownButton<String>(
                value: provider.locale.languageCode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (val) {
                  if (val != null) provider.setLocale(Locale(val));
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: AppColors.nileTeal),
              title: Text(loc.translate('currency')),
              trailing: DropdownButton<String>(
                value: provider.currency,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'EGP', child: Text('EGP (ج.م)')),
                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                ],
                onChanged: (val) {
                  if (val != null) provider.setCurrency(val);
                },
              ),
            ),
            const Divider(height: 32),

            // Admin Portal Launcher
            _buildTile(
              context,
              icon: Icons.admin_panel_settings,
              title: loc.translate('adminDashboard'),
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
