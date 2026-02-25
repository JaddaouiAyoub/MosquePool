import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mosque_provider.dart';
import '../../../core/theme/app_theme.dart';

class CitySelectorSheet extends ConsumerStatefulWidget {
  final String? selectedCity;
  final Function(String?) onSelected;

  const CitySelectorSheet({
    super.key,
    this.selectedCity,
    required this.onSelected,
  });

  @override
  ConsumerState<CitySelectorSheet> createState() => _CitySelectorSheetState();
}

class _CitySelectorSheetState extends ConsumerState<CitySelectorSheet> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(mosquesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Choisir une ville',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une ville...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryGreen,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: mosquesAsync.when(
              data: (mosques) {
                final cities =
                    mosques
                        .map((m) => m.city)
                        .where((c) => c.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();

                final filteredCities = cities
                    .where(
                      (c) =>
                          c.toLowerCase().contains(_searchQuery.toLowerCase()),
                    )
                    .toList();

                if (filteredCities.isEmpty) {
                  return const Center(child: Text('Aucune ville trouvée'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    final isSelected = widget.selectedCity == city;

                    return ListTile(
                      onTap: () {
                        widget.onSelected(city);
                        Navigator.pop(context);
                      },
                      title: Text(
                        city,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppTheme.primaryGreen,
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
