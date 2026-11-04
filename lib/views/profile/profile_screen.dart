import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 110),
            child: Column(
              children: [
                // User Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.papyrusGold,
                        child: Icon(Icons.person, color: AppColors.primaryPurple, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.2),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      AppleTouchable(
                        pressedScale: 0.85,
                        onTap: () {
                          Navigator.push(
                            context,
                            AppCupertinoPageRoute(page: const LoginScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.login_outlined, color: Colors.white, size: 20),
                        ),
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
                      AppCupertinoPageRoute(page: const OnboardingScreen()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.favorite_rounded,
                  title: loc.translate('favorites'),
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      AppCupertinoPageRoute(page: const FavoritesScreen()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.hotel_rounded,
                  title: loc.translate('hotelsTitle'),
                  color: AppColors.primaryPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      AppCupertinoPageRoute(page: const HotelSearchScreen()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.directions_car_rounded,
                  title: loc.translate('transportPlanner'),
                  color: AppColors.primaryOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      AppCupertinoPageRoute(page: const TransportPlannerScreen()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.map_rounded,
                  title: loc.translate('mapView'),
                  color: AppColors.seaTurquoise,
                  onTap: () {
                    Navigator.push(
                      context,
                      AppCupertinoPageRoute(page: const InteractiveMapScreen()),
                    );
                  },
                ),
                const Divider(height: 32),

                // Preferences Controls Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language_rounded, color: AppColors.primaryPurple),
                          title: Text(loc.translate('selectLanguage'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: DropdownButton<String>(
                            value: provider.locale.languageCode,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'ar', child: Text('العربية', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) {
                              if (val != null) provider.setLocale(Locale(val));
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.attach_money_rounded, color: AppColors.primaryOrange),
                          title: Text(loc.translate('currency'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: DropdownButton<String>(
                            value: provider.currency,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'EGP', child: Text('EGP (ج.م)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'USD', child: Text('USD (\$)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'EUR', child: Text('EUR (€)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'GBP', child: Text('GBP (£)', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) {
                              if (val != null) provider.setCurrency(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Admin Portal Launcher
                _buildTile(
                  context,
                  icon: Icons.admin_panel_settings_rounded,
                  title: loc.translate('adminDashboard'),
                  color: AppColors.primaryPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      AppCupertinoPageRoute(page: const AdminDashboardScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: AppleTouchable(
        pressedScale: 0.97,
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon, color: color, size: 24),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: -0.2)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.mediumGray),
        ),
      ),
    );
  }
}
