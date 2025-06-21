import 'package:car_rental_app/config/routes.dart';
import 'package:car_rental_app/shared/data/sample_cars.dart';
import 'package:car_rental_app/shared/models/car_model.dart';
import 'package:flutter/material.dart';
import 'widgets/widgets.dart';

class OwnerMyCarsScreen extends StatefulWidget {
  const OwnerMyCarsScreen({super.key});

  @override
  _OwnerMyCarsScreenState createState() => _OwnerMyCarsScreenState();
}

class _OwnerMyCarsScreenState extends State<OwnerMyCarsScreen> {
  late List<CarModel> _cars;

  @override
  void initState() {
    super.initState();
    _cars = SampleCars.getPopularCars();
  }

  void _navigateToAddCar() {
    Navigator.pushNamed(context, AppRoutes.addNewCar).then((_) {
      // Potentially refresh the list if a car was added
      setState(() {
        _cars = SampleCars.getPopularCars(); // Re-fetch or update list
      });
    });
  }

  void _editCar(CarModel car) {
    // Navigate to an edit screen, similar to add car screen but pre-filled
    print('Editing car: ${car.name}');
  }

  void _deleteCar(CarModel car) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete ${car.name}?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  setState(() {
                    _cars.remove(car);
                  });
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AddCarButton(onPressed: _navigateToAddCar),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final car = _cars[index];
                  return OwnerCarCard(
                    car: car,
                    onEdit: () => _editCar(car),
                    onDelete: () => _deleteCar(car),
                  );
                }, childCount: _cars.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
