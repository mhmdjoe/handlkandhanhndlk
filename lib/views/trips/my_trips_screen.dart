import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../planner/itinerary_detail_screen.dart';
import '../planner/trip_wizard_screen.dart';
import '../map/interactive_map_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  String _selectedStatusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;
    final allTrips = provider.userTrips;

    final filteredTrips = _selectedStatusFilter == 'All'
        ? allTrips
        : allTrips.where((t) => t.status == _selectedStatusFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('myTripsTitle')),
        actions: [
          AppleTouchable(
            onTap: () {
              Navigator.push(
                context,
                AppCupertinoPageRoute(page: const TripWizardScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryOrange, size: 28),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
          // Status Filter Chips
          if (allTrips.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedStatusFilter = 'All'),
                    child: ChoiceChip(
                      label: Text(
                        isAr ? 'جميع الرحلات (${allTrips.length})' : 'All Trips (${allTrips.length})',
                        style: TextStyle(
                          color: _selectedStatusFilter == 'All' ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: _selectedStatusFilter == 'All',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedStatusFilter = 'Active Journey'),
                    child: ChoiceChip(
                      label: Text(
                        isAr ? 'رحلات قائمة' : 'Active Journeys',
                        style: TextStyle(
                          color: _selectedStatusFilter == 'Active Journey' ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: _selectedStatusFilter == 'Active Journey',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedStatusFilter = 'Confirmed'),
                    child: ChoiceChip(
                      label: Text(
                        loc.translate('statusConfirmed'),
                        style: TextStyle(
                          color: _selectedStatusFilter == 'Confirmed' ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: _selectedStatusFilter == 'Confirmed',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredTrips.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.card_travel_rounded, size: 64, color: AppColors.mediumGray),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('noTrips'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate('noTripsSub'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          AppleTouchable(
                            onTap: () {
                              Navigator.push(
                                context,
                                AppCupertinoPageRoute(page: const TripWizardScreen()),
                              );
                            },
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  AppCupertinoPageRoute(page: const TripWizardScreen()),
                                );
                              },
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: Text(loc.translate('createFirstTrip')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 110),
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      final dest = TourismDatabase.destinations.firstWhere(
                        (d) => d.id == trip.destinationId,
                        orElse: () => TourismDatabase.destinations.first,
                      );

                      return StaggeredEntranceItem(
                        index: index,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _SlidableTripCard(
                            trip: trip,
                            dest: dest,
                            provider: provider,
                            isAr: isAr,
                            loc: loc,
                            onDeleteRequested: () => _showConfirmDeleteDialog(context, provider, trip, isAr),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  ),
);
}

  Future<bool?> _showConfirmDeleteDialog(BuildContext context, AppProvider provider, Trip trip, bool isAr) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(isAr ? 'حذف الرحلة؟' : 'Delete Trip?'),
          content: Text(
            isAr
                ? 'هل أنت تأكد من رغبتك في حذف "${trip.title}" نهائياً من رحلاتك؟'
                : 'Are you sure you want to permanently delete "${trip.title}" from your saved trips?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            AppleTouchable(
              onTap: () => Navigator.pop(context, true),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text(isAr ? 'حذف الرحلة' : 'Delete Trip'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SlidableTripCard extends StatefulWidget {
  final Trip trip;
  final Destination dest;
  final AppProvider provider;
  final bool isAr;
  final AppLocalizations loc;
  final Future<bool?> Function() onDeleteRequested;

  const _SlidableTripCard({
    required this.trip,
    required this.dest,
    required this.provider,
    required this.isAr,
    required this.loc,
    required this.onDeleteRequested,
  });

  @override
  State<_SlidableTripCard> createState() => _SlidableTripCardState();
}

class _SlidableTripCardState extends State<_SlidableTripCard> {
  double _slideOffset = 0.0;
  static const double _maxRevealWidth = 84.0;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _slideOffset = (_slideOffset + details.delta.dx).clamp(-_maxRevealWidth, 0.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_slideOffset < -35.0) {
      setState(() => _slideOffset = -_maxRevealWidth);
      HapticFeedback.lightImpact();
    } else {
      setState(() => _slideOffset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Revealed Delete Icon Button (Stays visible behind on the right)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: _maxRevealWidth,
                alignment: Alignment.center,
                child: AppleTouchable(
                  pressedScale: 0.85,
                  onTap: () async {
                    final confirmed = await widget.onDeleteRequested();
                    if (confirmed == true) {
                      widget.provider.removeTrip(widget.trip.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.darkGray,
                            content: Text(
                              widget.isAr ? 'تم حذف الرحلة بنجاح' : 'Trip deleted successfully',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            action: SnackBarAction(
                              label: widget.isAr ? 'تراجع' : 'Undo',
                              textColor: AppColors.primaryOrange,
                              onPressed: () => widget.provider.addTrip(widget.trip),
                            ),
                          ),
                        );
                      }
                    } else {
                      setState(() => _slideOffset = 0.0);
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Sliding Trip Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: AppCurves.springSnappy,
            transform: Matrix4.translationValues(_slideOffset, 0, 0),
            child: AppleTouchable(
              pressedScale: 0.97,
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (_slideOffset < 0) {
                  setState(() => _slideOffset = 0.0);
                } else {
                  Navigator.push(
                    context,
                    AppCupertinoPageRoute(
                      page: ItineraryDetailScreen(trip: widget.trip),
                    ),
                  );
                }
              },
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SafeNetworkImage(
                          imageUrl: widget.trip.coverImageUrl,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.70), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.trip.status == 'Active Journey'
                                  ? AppColors.primaryOrange
                                  : AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.trip.status,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trip.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: -0.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${widget.isAr ? widget.dest.nameAr : widget.dest.nameEn} • ${widget.trip.daysCount} ${widget.loc.translate('days')}',
                                style: const TextStyle(color: AppColors.papyrusGold, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event_outlined, size: 16, color: AppColors.mediumGray),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.trip.startDate.day}/${widget.trip.startDate.month}/${widget.trip.startDate.year}',
                                style: const TextStyle(fontSize: 12, color: AppColors.darkGray, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AppleTouchable(
                                pressedScale: 0.85,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    AppCupertinoPageRoute(
                                      page: const InteractiveMapScreen(),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.map_outlined, color: AppColors.primaryPurple, size: 22),
                                ),
                              ),
                              const SizedBox(width: 4),
                              AppleTouchable(
                                pressedScale: 0.85,
                                onTap: () async {
                                  final confirmed = await widget.onDeleteRequested();
                                  if (confirmed == true) {
                                    widget.provider.removeTrip(widget.trip.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 5),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: AppColors.darkGray,
                                          content: Text(
                                            widget.isAr ? 'تم حذف الرحلة بنجاح' : 'Trip deleted successfully',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                          ),
                                          action: SnackBarAction(
                                            label: widget.isAr ? 'تراجع' : 'Undo',
                                            textColor: AppColors.primaryOrange,
                                            onPressed: () => widget.provider.addTrip(widget.trip),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.provider.formatPrice(widget.trip.totalCostEgp, widget.trip.totalCostUsd),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange, fontSize: 15),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
