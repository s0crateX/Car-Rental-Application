import '../models/Mock Model/car_brand_model.dart';

class SampleBrands {
  static List<CarBrandModel> getBrands() {
    return [
      CarBrandModel(name: 'BMW', logo: 'assets/svg/bmw.svg'),
      CarBrandModel(name: 'Toyota', logo: 'assets/svg/toyota.svg'),
      CarBrandModel(name: 'Honda', logo: 'assets/svg/honda.svg'),
      CarBrandModel(name: 'Hyundai', logo: 'assets/svg/hyundai.svg'),
      CarBrandModel(name: 'Chevrolet', logo: 'assets/svg/chevrolet.svg'),
      CarBrandModel(name: 'Nissan', logo: 'assets/svg/nissan.svg'),
      CarBrandModel(name: 'Ford', logo: 'assets/svg/ford.svg'),
      CarBrandModel(name: 'Subaru', logo: 'assets/svg/subaru.svg'),
      CarBrandModel(name: 'Mazda', logo: 'assets/svg/mazda.svg'),
      CarBrandModel(name: 'Audi', logo: 'assets/svg/audi.svg'),
      CarBrandModel(name: 'Mitsubishi', logo: 'assets/svg/mitsubishi.svg'),
      CarBrandModel(name: 'Suzuki', logo: 'assets/svg/suzuki.svg'),
    ];
  }
}
