import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:handlkandhnhndlk/main.dart';
import 'package:handlkandhnhndlk/providers/app_provider.dart';
import 'package:handlkandhnhndlk/data/tourism_database.dart';
import 'package:handlkandhnhndlk/services/itinerary_engine.dart';
import 'package:handlkandhnhndlk/views/navigation_shell.dart';
import 'package:handlkandhnhndlk/views/explore/attraction_detail_screen.dart';

void main() {
  test('TourismDatabase contains authentic verified Egyptian data', () {
    expect(TourismDatabase.destinations.length, greaterThanOrEqualTo(8));
    expect(TourismDatabase.attractions.length, greaterThanOrEqualTo(10));
    expect(TourismDatabase.hotels.length, greaterThanOrEqualTo(4));

    final giza = TourismDatabase.attractions.firstWhere((a) => a.id == 'giza_pyramids');
    expect(giza.isOfficialVerified, isTrue);
    expect(giza.verifiedSource, contains('mota.gov.eg'));
  });

  test('ItineraryEngine generates trip without schedule errors', () {
    final trip = ItineraryEngine.generateAutoTrip(
      title: 'Cairo Trip',
      destinationId: 'cairo',
      attractionIds: ['giza_pyramids', 'gem_museum'],
      startDate: DateTime.now(),
      daysCount: 2,
      travelerCount: 2,
    );

    expect(trip.items.length, equals(2));
    expect(trip.totalCostEgp, greaterThan(0));

    final conflicts = ItineraryEngine.checkScheduleConflicts(trip);
    expect(conflicts, isEmpty);
  });

  testWidgets('HndlkApp renders Onboarding and NavigationShell without overflowing', (WidgetTester tester) async {
    await tester.pumpWidget(const HndlkApp());
    await tester.pumpAndSettle();

    expect(find.text('HNDLK W HNHNDLK'), findsWidgets);

    // Render NavigationShell directly
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(
          home: NavigationShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationShell), findsOneWidget);
  });

  testWidgets('AttractionDetailScreen renders without errors', (WidgetTester tester) async {
    final attraction = TourismDatabase.attractions.first;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: MaterialApp(
          home: AttractionDetailScreen(attraction: attraction),
        ),
      ),
    );
    await tester.pump();
  });
}
