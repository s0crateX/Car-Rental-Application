import 'package:flutter/material.dart';
import '../../../../../shared/models/Mock Model/booking_model.dart';

class ExtraChargesCard extends StatelessWidget {
  final BookingModel booking;

  const ExtraChargesCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = _getRequestedServices(booking);
    final hasServices = services.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.miscellaneous_services,
                  size: 20,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Requested Services',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!hasServices) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No additional services requested',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ] else ...[
              ...services.map(
                (service) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (service.startsWith('Car Delivery to: '))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Car Delivery to:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    service.substring(
                                      'Car Delivery to: '.length,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              )
                            else
                              Text(service, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _getRequestedServices(BookingModel booking) {
    final services = <String>[];

    // Check for common service requests
    if (booking.extras.containsKey('Driver Fee')) {
      services.add('With Driver');
    }

    if (booking.extras.containsKey('Delivery Fee')) {
      final deliveryText =
          booking.deliveryLocation != null
              ? 'Car Delivery to: ${booking.deliveryLocation}'
              : 'Car Delivery to Location';
      services.add(deliveryText);
    }

    if (booking.extras.containsKey('Child Seat')) {
      services.add('Child Safety Seat');
    }

    if (booking.extras.containsKey('GPS')) {
      services.add('GPS Navigation');
    }

    // Add any other custom services
    final customServices =
        booking.extras.keys
            .where(
              (key) =>
                  ![
                    'Driver Fee',
                    'Delivery Fee',
                    'Child Seat',
                    'GPS',
                  ].contains(key),
            )
            .toList();

    services.addAll(customServices);

    return services;
  }
}
