import 'package:car_rental_app/config/routes.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/models/Final%20Model/Firebase_car_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'widgets/widgets.dart';

class OwnerMyCarsScreen extends StatefulWidget {
  const OwnerMyCarsScreen({super.key});

  @override
  _OwnerMyCarsScreenState createState() => _OwnerMyCarsScreenState();
}

class _OwnerMyCarsScreenState extends State<OwnerMyCarsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Get current user ID when screen initializes
    _getCurrentUserId();
  }

  // Get current user ID from AuthService
  void _getCurrentUserId() {
    final user = _authService.user;
    if (user != null && mounted) {
      setState(() {
        _currentUserId = user.uid;
      });
      print('Current user ID: $_currentUserId'); // Debug print

      // Force refresh of the stream by triggering setState
      setState(() {});
    } else {
      print('No user found or widget not mounted');
    }
  }

  void _navigateToAddCar() {
    Navigator.pushNamed(context, AppRoutes.addNewCar).then((_) {
      // Refresh user ID when returning from add car screen
      _getCurrentUserId();
    });
  }

  void _editCar(CarModel car) {
    // Navigate to an edit screen, similar to add car screen but pre-filled
    print('Editing car: ${car.name}');
    // You can pass the car data to the edit screen
    // Navigator.pushNamed(context, AppRoutes.editCar, arguments: car);
  }

  void _viewCarDetails(CarModel car) {
    // Navigate to car details screen
    print('Viewing car details: ${car.name}');
    // Navigator.pushNamed(context, AppRoutes.carDetails, arguments: car);
  }

  void _deleteCar(CarModel car) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Deletion',
                  style: TextStyle(color: AppTheme.white),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to delete "${car.name}"? This action cannot be undone.',
              style: TextStyle(color: AppTheme.paleBlue),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.lightBlue),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _deleteCarFromFirestore(car);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCarFromFirestore(CarModel car) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('Cars').doc(car.id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${car.name} deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting car: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: AppTheme.lightBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Cars Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first car to get started',
            style: TextStyle(fontSize: 16, color: AppTheme.paleBlue),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddCar,
            icon: const Icon(Icons.add),
            label: const Text('Add Car'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Cars',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: AppTheme.paleBlue),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}), // Trigger rebuild
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.darkNavy,

        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  AddCarButton(onPressed: _navigateToAddCar),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          _firestore
                              .collection('Cars')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        // Handle loading state
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightBlue,
                              ),
                            ),
                          );
                        }

                        // Handle error state
                        if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        }

                        // Handle empty state
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        // Parse car data and filter by current user ID
                        final allCars =
                            snapshot.data!.docs
                                .map((doc) {
                                  try {
                                    final car = CarModel.fromFirestore(doc);
                                    print(
                                      'Car: ${car.name}, Owner ID: "${car.carOwnerDocumentId}", Doc ID: ${doc.id}',
                                    );
                                    return car;
                                  } catch (e) {
                                    print(
                                      'Error parsing car document ${doc.id}: $e',
                                    );
                                    return null;
                                  }
                                })
                                .where((car) => car != null)
                                .cast<CarModel>()
                                .toList();

                        // Filter cars by the current user ID with more flexible matching
                        final cars =
                            _currentUserId != null
                                ? allCars
                                    .where(
                                      (car) =>
                                          car.carOwnerDocumentId ==
                                              _currentUserId ||
                                          car.carOwnerDocumentId.trim() ==
                                              _currentUserId ||
                                          (_currentUserId != null &&
                                              car
                                                  .carOwnerDocumentId
                                                  .isNotEmpty &&
                                              _currentUserId!.contains(
                                                car.carOwnerDocumentId,
                                              )) ||
                                          (car.carOwnerDocumentId.isNotEmpty &&
                                              _currentUserId != null &&
                                              car.carOwnerDocumentId.contains(
                                                _currentUserId!,
                                              )),
                                    )
                                    .toList()
                                : allCars;

                        print(
                          'Found ${cars.length} cars for user "$_currentUserId" out of ${allCars.length} total cars',
                        );

                        // Handle case where all documents failed to parse
                        if (cars.isEmpty) {
                          return _buildErrorState('Unable to load car data');
                        }

                        // Build car list
                        return RefreshIndicator(
                          onRefresh: () async {
                            // Refresh is handled automatically by StreamBuilder
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                          },
                          color: AppTheme.lightBlue,
                          backgroundColor: AppTheme.navy,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: cars.length,
                            itemBuilder: (context, index) {
                              final car = cars[index];
                              return OwnerCarCard(
                                carData: car,
                                onEdit: () => _editCar(car),
                                onDelete: () => _deleteCar(car),
                                onTap: () => _viewCarDetails(car),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
