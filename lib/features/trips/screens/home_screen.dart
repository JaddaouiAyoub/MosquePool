import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../widgets/trip_card.dart';
import '../widgets/city_selector_sheet.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(filteredTripsProvider);
    final unreadCount = ref
        .watch(notificationsProvider)
        .where((n) => !n.isRead)
        .length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo/logo1.png', height: 40, width: 40),
                  const SizedBox(width: 10),
                  const Text(
                    'LiftMosque',
                    style: TextStyle(
                      color: AppTheme.secondaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) =>
                        ref.read(searchQueryProvider.notifier).state = value,
                    decoration: InputDecoration(
                      hintText:
                          'Rechercher une mosquée ou un point de départ...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryGreen,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Toutes'),
                        selected: ref.watch(selectedCityProvider) == null,
                        onSelected: (_) =>
                            ref.read(selectedCityProvider.notifier).state =
                                null,
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryGreen,
                        labelStyle: TextStyle(
                          color: ref.watch(selectedCityProvider) == null
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade700,
                        ),
                        side: BorderSide(
                          color: ref.watch(selectedCityProvider) == null
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: Icon(
                          Icons.location_city,
                          size: 16,
                          color: ref.watch(selectedCityProvider) != null
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade600,
                        ),
                        label: Text(
                          ref.watch(selectedCityProvider) ??
                              'Choisir une ville',
                          style: TextStyle(
                            color: ref.watch(selectedCityProvider) != null
                                ? AppTheme.primaryGreen
                                : Colors.grey.shade700,
                            fontWeight: ref.watch(selectedCityProvider) != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CitySelectorSheet(
                              selectedCity: ref.watch(selectedCityProvider),
                              onSelected: (city) {
                                ref.read(selectedCityProvider.notifier).state =
                                    city;
                              },
                            ),
                          );
                        },
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: ref.watch(selectedCityProvider) != null
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (trips.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun trajet trouvé',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final trip = trips[index];
                  return TripCard(
                    trip: trip,
                    onTap: () => context.push('/trip-details', extra: trip),
                  );
                }, childCount: trips.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-trip'),
        label: const Text('Proposer un trajet'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}
