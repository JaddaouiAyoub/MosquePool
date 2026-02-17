import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../widgets/trip_card.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(filteredTripsProvider);
    final unreadCount = ref.watch(notificationsProvider).where((n) => !n.isRead).length;
    
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
                  Image.asset(
                    'assets/logo/logo1.png',
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MosquePool',
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search mosque or departure point...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
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
                    borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1),
                  ),
                ),
              ),
            ),
          ),
          if (trips.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No trips found',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
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
        label: const Text('Offer a Ride'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}
