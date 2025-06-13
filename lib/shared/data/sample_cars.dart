import '../models/car_model.dart';

// Sample car data that will be replaced with Firebase data later
class SampleCars {
  static List<CarModel> getPopularCars() {
    return [
      CarModel(
        id: '1',
        image: 'assets/images/cars/1.png',
        type: 'Sedan',
        name: 'Hyundai Verna',
        transmissionType: 'Manual',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        rating: 4.9,
        price: 25.00,
      ),
      CarModel(
        id: '2',
        image: 'assets/images/cars/hyundai_verna.png',
        type: 'SUV',
        name: 'Toyota Fortuner',
        transmissionType: 'Automatic',
        fuelType: 'Diesel',
        seatsCount: '7 Seats',
        rating: 4.8,
        price: 45.00,
      ),
      CarModel(
        id: '3',
        image: 'assets/images/cars/1.png',
        type: 'Hatchback',
        name: 'Honda Jazz',
        transmissionType: 'Manual',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        rating: 4.7,
        price: 20.00,
      ),
      CarModel(
        id: '4',
        image: 'assets/images/cars/hyundai_verna.png',
        type: 'Sedan',
        name: 'Toyota Camry',
        transmissionType: 'Automatic',
        fuelType: 'Hybrid',
        seatsCount: '5 Seats',
        rating: 4.9,
        price: 35.00,
      ),
      CarModel(
        id: '5',
        image: 'assets/images/cars/1.png',
        type: 'Crossover',
        name: 'Nissan Kicks',
        transmissionType: 'CVT',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        rating: 4.6,
        price: 30.00,
      ),
    ];
  }

  static List<CarModel> getRecommendedCars() {
    return [
      CarModel(
        id: '6',
        image: 'assets/images/cars/1.png',
        type: 'Compact',
        name: 'Suzuki Swift',
        transmissionType: 'Manual',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        rating: 4.5,
        price: 18.00,
      ),
      CarModel(
        id: '7',
        image: 'assets/images/cars/hyundai_verna.png',
        type: 'Sedan',
        name: 'Honda City',
        transmissionType: 'CVT',
        fuelType: 'Petrol',
        seatsCount: '5 Seats',
        rating: 4.7,
        price: 22.00,
      ),
      CarModel(
        id: '8',
        image: 'assets/images/cars/1.png',
        type: 'SUV',
        name: 'Kia Seltos',
        transmissionType: 'Automatic',
        fuelType: 'Diesel',
        seatsCount: '5 Seats',
        rating: 4.8,
        price: 32.00,
      ),
    ];
  }
}
