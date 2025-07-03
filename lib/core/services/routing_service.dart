import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  /// Fetches a route between two points using OSRM free public API
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    // Format: {service}/{version}/{profile}/{coordinates}[.{format}]?option=value&option=value
    // Using the free public OSRM demo server
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          // Extract the route geometry from the response
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          
          // Convert the GeoJSON coordinates (which are [lng, lat]) to LatLng objects
          return coordinates.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]); // Convert [lng, lat] to LatLng(lat, lng)
          }).toList();
        } else {
          print('No routes found in response: ${data['code']}');
          throw Exception('No routes found');
        }
      } else {
        print('Failed to get route: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get route');
      }
    } catch (e) {
      print('Error fetching route: $e');
      throw Exception('Error fetching route: $e');
    }
  }
}
