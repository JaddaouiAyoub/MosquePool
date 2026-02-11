import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../providers/trips_provider.dart';
import '../../../core/theme/app_theme.dart';

class EditTripScreen extends ConsumerStatefulWidget {
  final Trip trip;
  const EditTripScreen({super.key, required this.trip});

  @override
  ConsumerState<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mosqueController;
  late TextEditingController _departureController;
  late TextEditingController _seatsController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late List<TextEditingController> _pickupControllers;

  @override
  void initState() {
    super.initState();
    _mosqueController = TextEditingController(text: widget.trip.mosqueName);
    _departureController = TextEditingController(
      text: widget.trip.departurePoint,
    );
    _seatsController = TextEditingController(
      text: widget.trip.seatsAvailable.toString(),
    );
    _selectedDate = widget.trip.departureTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.trip.departureTime);
    _pickupControllers = widget.trip.pickupPoints
        .map((p) => TextEditingController(text: p))
        .toList();
    if (_pickupControllers.isEmpty) {
      _pickupControllers.add(TextEditingController());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
          'Modify Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildScheduleCard(),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _departureController,
              label: 'From (Departure Point)',
              icon: Icons.my_location,
              iconColor: AppTheme.secondaryBlue,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _mosqueController,
              label: 'To (Mosque)',
              icon: Icons.mosque,
              iconColor: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _seatsController,
              label: 'Available Seats',
              icon: Icons.event_seat,
              iconColor: Colors.orange,
              isNumber: true,
            ),
            const SizedBox(height: 32),
            _buildPickupPointsHeader(),
            const SizedBox(height: 8),
            ..._buildPickupPointsList(),
            const SizedBox(height: 48),
            _buildSaveButton(),
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
            'Trip Schedule',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) => val!.isEmpty ? 'Field required' : null,
    );
  }

  Widget _buildPickupPointsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pickup Points',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextButton.icon(
          onPressed: () =>
              setState(() => _pickupControllers.add(TextEditingController())),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add stop'),
        ),
      ],
    );
  }

  List<Widget> _buildPickupPointsList() {
    return _pickupControllers.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: entry.value,
          decoration: InputDecoration(
            labelText: 'Stop ${entry.key + 1}',
            prefixIcon: const Icon(Icons.push_pin_outlined, size: 20),
            suffixIcon: _pickupControllers.length > 1
                ? IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () =>
                        setState(() => _pickupControllers.removeAt(entry.key)),
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
    }).toList();
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final departureDateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );

          final updatedTrip = widget.trip.copyWith(
            departurePoint: _departureController.text,
            mosqueName: _mosqueController.text,
            seatsAvailable: int.parse(_seatsController.text),
            departureTime: departureDateTime,
            pickupPoints: _pickupControllers
                .map((c) => c.text)
                .where((t) => t.isNotEmpty)
                .toList(),
          );

          ref.read(tripsProvider.notifier).updateTrip(updatedTrip);
          Navigator.pop(context);
        }
      },
      child: const Text(
        'Save Changes',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
