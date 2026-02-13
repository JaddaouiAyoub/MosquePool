import 'package:flutter/material.dart';
import '../models/mosque.dart';
import '../../../core/theme/app_theme.dart';

class MosqueSelectorSheet extends StatefulWidget {
  final Function(Mosque) onSelected;

  const MosqueSelectorSheet({super.key, required this.onSelected});

  @override
  State<MosqueSelectorSheet> createState() => _MosqueSelectorSheetState();
}

class _MosqueSelectorSheetState extends State<MosqueSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Mosque> _filteredMosques = [];

  @override
  void initState() {
    super.initState();
    // Sort alphabetically by default
    _filteredMosques = List.from(availableMosques)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void _filterMosques(String query) {
    setState(() {
      _filteredMosques =
          availableMosques
              .where(
                (m) =>
                    m.name.toLowerCase().contains(query.toLowerCase()) ||
                    m.address.toLowerCase().contains(query.toLowerCase()),
              )
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Mosque',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _filterMosques,
            decoration: InputDecoration(
              hintText: 'Search by name or city...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.primaryGreen,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _filteredMosques.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mosque_outlined,
                          size: 48,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No mosques found',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMosques.length,
                    itemBuilder: (context, index) {
                      final m = _filteredMosques[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          m.address,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          widget.onSelected(m);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
