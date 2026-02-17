import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../providers/trips_provider.dart';
import '../widgets/mosque_selector_sheet.dart';
import '../../../core/theme/app_theme.dart';

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key});

  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mosqueController = TextEditingController();
  final _departureController = TextEditingController();
  final _seatsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<TextEditingController> _pickupControllers = [
    TextEditingController(),
  ];
  String? _selectedMosqueId;
  String? _selectedMosqueAddress;
  double? _selectedMosqueLat;
  double? _selectedMosqueLng;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          'Proposer un trajet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildScheduleCard(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _departureController,
              decoration: InputDecoration(
                labelText: 'De (Point de départ)',
                prefixIcon: const Icon(
                  Icons.my_location,
                  color: AppTheme.secondaryBlue,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (val) => val!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => MosqueSelectorSheet(
                    onSelected: (mosque) {
                      setState(() {
                        _mosqueController.text = mosque.name;
                        _selectedMosqueId = mosque.id;
                        _selectedMosqueAddress = mosque.address;
                        _selectedMosqueLat = mosque.latitude;
                        _selectedMosqueLng = mosque.longitude;
                      });
                    },
                  ),
                );
              },
              child: IgnorePointer(
                child: TextFormField(
                  controller: _mosqueController,
                  decoration: InputDecoration(
                    labelText: 'Vers (Mosquée)',
                    hintText: 'Sélectionner une mosquée...',
                    prefixIcon: const Icon(
                      Icons.mosque,
                      color: AppTheme.primaryGreen,
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Veuillez sélectionner une mosquée' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Places disponibles',
                prefixIcon: const Icon(Icons.event_seat, color: Colors.orange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (val) => val!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 32),
            _buildPickupSection(),
            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horaire du trajet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPickerTile(
                  onTap: () => _selectDate(context),
                  icon: Icons.calendar_today,
                  text: DateFormat('MMM dd').format(_selectedDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPickerTile(
                  onTap: () => _selectTime(context),
                  icon: Icons.access_time,
                  text: _selectedTime.format(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Points de passage',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton.icon(
              onPressed: () => setState(
                () => _pickupControllers.add(TextEditingController()),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Ajouter un arrêt'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._pickupControllers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: entry.value,
              decoration: InputDecoration(
                labelText: 'Arrêt ${entry.key + 1}',
                prefixIcon: const Icon(Icons.push_pin_outlined, size: 20),
                suffixIcon: _pickupControllers.length > 1
                    ? IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => setState(
                          () => _pickupControllers.removeAt(entry.key),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() => _isLoading = true);
          try {
            final user = ref.read(profileProvider);
            if (user.id.isEmpty) {
              throw Exception("Profil utilisateur non chargé. Veuillez patienter.");
            }
            
            final departureDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );

            final newTrip = Trip(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              mosqueId: _selectedMosqueId,
              driverId: user.id,
              driverName: user.fullName,
              departurePoint: _departureController.text,
              mosqueName: _mosqueController.text,
              mosqueAddress: _selectedMosqueAddress ?? '',
              mosqueLat: _selectedMosqueLat,
              mosqueLng: _selectedMosqueLng,
              seatsAvailable: int.parse(_seatsController.text),
              departureTime: departureDateTime,
              createdAt: DateTime.now(),
              pickupPoints: _pickupControllers
                  .map((c) => c.text)
                  .where((t) => t.isNotEmpty)
                  .toList(),
            );

            await ref.read(tripsProvider.notifier).updateTrip(newTrip);
            if (mounted) Navigator.pop(context);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
              );
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        }
      },
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Text(
              'Publier le trajet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}
