import '../../models/Mock Model/car_model.dart';
import 'package:latlong2/latlong.dart';

// Sample car data that will be replaced with Firebase data later
class SampleCars {
  // Common features for cars
  static final List<String> _commonFeatures = [
    'Air Conditioning',
    'Bluetooth',
    'USB Port',
    'GPS Navigation',
    'Backup Camera',
    'Keyless Entry',
    'Power Windows',
    'Power Steering',
  ];

  // Common inclusions for rental
  static final List<String> _commonInclusions = [
    'Insurance',
    'Unlimited Mileage',
    '24/7 Roadside Assistance',
    'Free Cancellation (24h)',
  ];

  // Common extra charges
  static final Map<String, double> _commonExtraCharges = {
    'Driver Fee': 25.00,
    'Delivery Fee': 15.00,
    'Late Return Fee (per hour)': 10.00,
    'Additional Cleaning': 30.00,
  };

  // Common rental requirements
  static final Map<String, String> _commonRentalRequirements = {
    'Driver\'s License': 'Valid for at least 1 year',
    'Minimum Age': '21 years',
    'Security Deposit': '200',
  };
  static List<CarModel> getPopularCars() {
    final now = DateTime.now();
    return [
      CarModel(
        id: '1',
        image: 'assets/images/cars/1.png',
        imageGallery: [
          'assets/images/cars/1.png',
          'assets/images/cars/hyundai_verna.png',
          'assets/images/cars/1.png',
          'assets/images/cars/hyundai_verna.png',
        ],
        type: 'Sedan',
        name: 'Hyundai Verna',
        brand: 'Hyundai',
        model: 'Verna',
        year: '2023',
        transmissionType: 'Manual',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        luggageCapacity: '3 Bags',
        rating: 4.9,
        price: 25.00,
        pricePeriod: '/hr',
        priceOptions: {'Daily': 150.00, 'Weekly': 900.00, 'Monthly': 3200.00},
        features: [..._commonFeatures, 'Sunroof', 'Leather Seats'],
        inclusions: _commonInclusions,
        extraCharges: _commonExtraCharges,
        availabilityStatus: AvailabilityStatus.available,

        pickupLocations: [
          'Main Office',
          'Airport Terminal 1',
          'Downtown Branch',
        ],
        returnLocations: [
          'Main Office',
          'Airport Terminal 1',
          'Downtown Branch',
        ],
        rentalRequirements: _commonRentalRequirements,
        fuelPolicy: 'Full to Full',
        cancellationPolicy: 'Free cancellation up to 24 hours before pickup',
        reviews: [
          {
            'id': '101',
            'userName': 'David',
            'userAvatar': 'assets/images/avatars/user1.png',
            'rating': 5.0,
            'comment': 'Great car, very comfortable and fuel efficient.',
            'date': now.subtract(const Duration(days: 5)).toIso8601String(),
          },
          {
            'id': '102',
            'userName': 'Jane',
            'userAvatar': 'assets/images/avatars/user2.png',
            'rating': 4.8,
            'comment': 'Smooth drive, would rent again.',
            'date': now.subtract(const Duration(days: 12)).toIso8601String(),
          },
        ],
        location: const LatLng(
          6.114171118812157,
          125.16531847651395,
        ), // General Santos City, Philippines
        locationAddress:
            '89 Tieza St, General Santos City (Dadiangas), South Cotabato',
      ),
      CarModel(
        id: '3',
        image: 'assets/images/cars/1.png',
        imageGallery: [
          'assets/images/cars/1.png',
          'assets/images/cars/hyundai_verna.png',
          'assets/images/cars/1.png',
          'assets/images/cars/hyundai_verna.png',
        ],
        type: 'MPV',
        name: 'Toyota Innova',
        brand: 'Toyota',
        model: 'Innova',
        year: '2023',
        transmissionType: 'Automatic',
        fuelType: 'Diesel',
        seatsCount: '7 Seats',
        luggageCapacity: '4 Bags',
        rating: 4.7,
        price: 35.00,
        pricePeriod: '/hr',
        priceOptions: {'Daily': 200.00, 'Weekly': 1200.00, 'Monthly': 4500.00},
        features: [
          ..._commonFeatures,
          'Leather Seats',
          'Rear AC Vents',
          'Touchscreen Infotainment',
        ],
        inclusions: _commonInclusions,
        extraCharges: _commonExtraCharges,
        availabilityStatus: AvailabilityStatus.available,
        pickupLocations: [
          'Makati City Branch',
          'Bonifacio Global City',
          'NAIA Terminal 3',
        ],
        returnLocations: [
          'Makati City Branch',
          'Bonifacio Global City',
          'NAIA Terminal 3',
        ],
        rentalRequirements: _commonRentalRequirements,
        fuelPolicy: 'Full to Full',
        cancellationPolicy: 'Free cancellation up to 24 hours before pickup',
        reviews: [
          {
            'id': '103',
            'userName': 'Michael Tan',
            'userAvatar': 'assets/images/avatars/user3.png',
            'rating': 4.9,
            'comment': 'Very spacious and comfortable for family trips.',
            'date': now.subtract(const Duration(days: 7)).toIso8601String(),
          },
        ],
        location: const LatLng(
          6.117298267360866,
          125.16471904080554,
        ), // General Santos City
        locationAddress:
            'Macopa St, General Santos City (Dadiangas), South Cotabato',
      ),
      CarModel(
        id: '4',
        image: 'assets/images/cars/hyundai_verna.png',
        imageGallery: [
          'assets/images/cars/1.png',
          'assets/images/cars/hyundai_verna.png',
          'assets/images/cars/1.png',
          'assets/images/cars/hyundai_verna.png',
        ],
        type: 'Sedan',
        name: 'Honda City',
        brand: 'Honda',
        model: 'City',
        year: '2023',
        transmissionType: 'CVT',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        luggageCapacity: '3 Bags',
        rating: 4.6,
        price: 28.00,
        pricePeriod: '/hr',
        priceOptions: {'Daily': 170.00, 'Weekly': 1000.00, 'Monthly': 3800.00},
        features: [
          ..._commonFeatures,
          'Push Start',
          'Paddle Shifters',
          'Lane Watch Camera',
        ],
        inclusions: _commonInclusions,
        extraCharges: _commonExtraCharges,
        availabilityStatus: AvailabilityStatus.available,
        pickupLocations: [
          'Quezon City Branch',
          'Eastwood City',
          'Araneta City',
        ],
        returnLocations: [
          'Quezon City Branch',
          'Eastwood City',
          'Araneta City',
        ],
        location: const LatLng(6.116343, 125.164520), // General Santos City
        locationAddress: 'General Santos City, South Cotabato, Philippines',
        rentalRequirements: _commonRentalRequirements,
        fuelPolicy: 'Full to Full',
        cancellationPolicy: 'Free cancellation up to 24 hours before pickup',
        reviews: [
          {
            'id': '104',
            'userName': 'Lim',
            'userAvatar': 'assets/images/avatars/user4.png',
            'rating': 4.8,
            'comment': 'Great fuel efficiency and comfortable ride.',
            'date': now.subtract(const Duration(days: 10)).toIso8601String(),
          },
        ],
      ),
    ];
  }
}
