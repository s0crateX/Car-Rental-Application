import 'package:flutter/material.dart';
import '../../../../../../shared/models/car_model.dart';

class RentalHistoryWidget extends StatelessWidget {
  final List<CarModel> history;
  const RentalHistoryWidget({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text('No rental history yet.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...history.map((car) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(car.image, width: 56, height: 40, fit: BoxFit.cover),
                ),
                title: Text(car.name, style: theme.textTheme.titleSmall),
                subtitle: Text(car.brand + ' • ' + car.model),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 18),
                    Text('Completed', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
