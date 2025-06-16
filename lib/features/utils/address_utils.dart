import 'package:geocoding/geocoding.dart';

class AddressUtils {
  /// Returns a human-readable address from latitude and longitude using the geocoding package.
  static Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String address = '';
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          address += placemark.street! + ', ';
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          address += placemark.subLocality! + ', ';
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          address += placemark.locality! + ', ';
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          address += placemark.administrativeArea! + ', ';
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          address += placemark.country!;
        }
        return address.trim().replaceAll(RegExp(r', *$'), '');
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }
}
