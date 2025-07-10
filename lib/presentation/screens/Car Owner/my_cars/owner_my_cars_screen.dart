import 'package:car_rental_app/config/routes.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/models/Final%20Model/Firebase_car_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    
    // Add listener for auth state changes to refresh when user switches accounts
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted && user != null) {
        setState(() {
          _currentUserId = user.uid;
          print('Auth state changed - Current user ID: $_currentUserId');
        });
      }
    });
  }

  // Get current user ID from AuthService and Firebase Auth
  Future<void> _getCurrentUserId() async {
    // First try getting from Firebase Auth directly
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser == null) {
      // Try getting from auth service as fallback
      var user = _authService.user;
      
      // If still null, wait and try again
      if (user == null) {
        // Wait for auth to initialize if needed
        await Future.delayed(const Duration(milliseconds: 500));
        firebaseUser = FirebaseAuth.instance.currentUser;
      }
    }
    
    if (firebaseUser != null && mounted) {
      setState(() {
        _currentUserId = firebaseUser!.uid;
      });
      print('Current user ID refreshed: $_currentUserId');
      
      // Force refresh of the stream
      setState(() {});
    } else {
      print('No user found or widget not mounted');
    }
  }

  void _navigateToAddCar() {
    Navigator.pushNamed(context, AppRoutes.addNewCar).then((_) {
      // Refresh user ID when returning from add car screen
      _getCurrentUserId();
      // Force rebuild
      if (mounted) setState(() {});
    });
  }

  void _editCar(CarModel car) {
    // Navigate to an edit screen, similar to add car screen but pre-filled
    print('Editing car: ${car.type}');
    // You can pass the car data to the edit screen
    // Navigator.pushNamed(context, AppRoutes.editCar, arguments: car);
  }

  void _viewCarDetails(CarModel car) {
    // Navigate to car details screen
    print('Viewing car details: ${car.type}');
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
              'Are you sure you want to delete "${car.type}"? This action cannot be undone.',
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
            content: Text('${car.type} deleted successfully'),
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
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Cars',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.paleBlue.withOpacity(0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppTheme.white,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightBlue,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user ID when screen gains focus
    _getCurrentUserId();
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
                                      'Car: ${car.type}, Owner ID: "${car.carOwnerDocumentId}", Doc ID: ${doc.id}',
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

                        // Filter cars to only show those owned by the current user with exact ID match
                        final cars =
                            _currentUserId != null
                                ? allCars
                                    .where(
                                      (car) =>
                                          car.carOwnerDocumentId ==
                                          _currentUserId,
                                    )
                                    .toList()
                                : [];

                        print(
                          'Found ${cars.length} cars for user "$_currentUserId" out of ${allCars.length} total cars',
                        );

                        // If no cars found for user but we have user ID
                        if (cars.isEmpty && _currentUserId != null) {
                          // Check if we found any cars at all
                          if (allCars.isEmpty) {
                            return _buildErrorState('Unable to load car data');
                          } else {
                            return _buildEmptyState();
                          }
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
