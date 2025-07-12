import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOwnedCars(String userId) {
    return _firestore
        .collection('Cars')
        .where('carOwnerDocumentId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getBookings(List<String> carIds, String collection) {
    return _firestore
        .collection(collection)
        .where('carId', whereIn: carIds)
        .snapshots();
  }

  Stream<QuerySnapshot> getBookingsByCustomer(String userId, String collection) {
    return _firestore
        .collection(collection)
        .where('customerId', isEqualTo: userId)
        .snapshots();
  }

  Stream<Map<String, int>> getBookingCounts(List<String> carIds, String collection) {
    return _firestore
        .collection(collection)
        .where('carId', whereIn: carIds)
        .snapshots()
        .map((snapshot) {
      int rentNowCount = 0;
      int reserveCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['bookingType'] == 'rentNow') {
          rentNowCount++;
        } else if (data['bookingType'] == 'reserve') {
          reserveCount++;
        }
      }
      return {
        'rentNow': rentNowCount,
        'reserve': reserveCount,
      };
    });
  }
}