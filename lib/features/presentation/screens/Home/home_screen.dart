import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Cars'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 5, // Temporary placeholder
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                color: Colors.grey[300], // Placeholder for car image
                child: const Icon(Icons.car_rental, size: 40),
              ),
              title: const Text('Car Model'),
              subtitle: const Text('PHP 2,500/day'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to car details
              },
            ),
          );
        },
      ),
    );
  }
}
