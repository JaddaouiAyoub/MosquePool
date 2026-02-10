import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mosqueController = TextEditingController();
  final _departureController = TextEditingController();
  final _seatsController = TextEditingController();
  final List<TextEditingController> _pickupControllers = [
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Ride'),
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
            Text(
              'Trip Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _departureController,
              decoration: const InputDecoration(
                labelText: 'Departure Point',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (val) =>
                  val!.isEmpty ? 'Please enter departure point' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mosqueController,
              decoration: const InputDecoration(
                labelText: 'Destination Mosque',
                prefixIcon: Icon(Icons.mosque),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (val) =>
                  val!.isEmpty ? 'Please enter mosque name' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Departure Time',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onTap: () {
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _seatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available Seats',
                      prefixIcon: Icon(Icons.event_seat),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? 'Enter seats' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pickup Points',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(
                      () => _pickupControllers.add(TextEditingController()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Point'),
                ),
              ],
            ),
            ..._pickupControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: 'Pickup Point ${entry.key + 1}',
                    suffixIcon: _pickupControllers.length > 1
                        ? IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => setState(
                              () => _pickupControllers.removeAt(entry.key),
                            ),
                          )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Logic to save trip
                  Navigator.pop(context);
                }
              },
              child: const Text('Publish Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
