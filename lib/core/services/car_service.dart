import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../shared/models/Final Model/Firebase_car_model.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'Cars';

  // Get all cars
  Future<List<CarModel>> getCars() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).get();
      
      return snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
    }
  }

  // Get nearby cars based on user location
  Future<List<CarModel>> getNearbyCars(LatLng? userLocation, {double maxDistanceKm = 20.0}) async {
    if (userLocation == null) return getCars();
    
    try {
      final List<CarModel> allCars = await getCars();
      final Distance distance = Distance();
      
      final carsWithDistance = allCars
          .where((car) => car.location.isNotEmpty) // Filter cars with location
          .map((car) {
            if (car.location.containsKey('lat') && car.location.containsKey('lng')) {
              final carLoc = LatLng(
                car.location['lat'] ?? 0.0,
                car.location['lng'] ?? 0.0,
              );
              final dist = distance.as(LengthUnit.Kilometer, userLocation, carLoc);
              return {'car': car, 'distance': dist};
            }
            return {'car': car, 'distance': double.infinity};
          })
          .where((entry) => (entry['distance'] as double) <= maxDistanceKm)
          .toList();
      
      // Sort by distance
      carsWithDistance.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );
      
      return carsWithDistance.map((entry) => entry['car'] as CarModel).toList();
    } catch (e) {
      print('Error fetching nearby cars: $e');
      return [];
    }
  }

  // Get cars by owner ID
  Future<List<CarModel>> getCarsByOwner(String ownerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('carOwnerDocumentId', isEqualTo: ownerId)
          .get();
      
      return snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching owner cars: $e');
      return [];
    }
  }

  // Get car by ID
  Future<CarModel?> getCarById(String carId) async {
    try {
      final DocumentSnapshot doc = 
          await _firestore.collection(_collectionName).doc(carId).get();
      
      if (doc.exists) {
        return CarModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching car by ID: $e');
      return null;
    }
  }
}
