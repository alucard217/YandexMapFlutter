import 'package:yandex_mapkit/yandex_mapkit.dart';

class Field {
  final String id;
  final String name;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String image;
  final List<Point> polygon;

  Field({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.polygon,
  });

factory Field.fromMap(String id, Map<String, dynamic> data) {
  final polygonData = data['polygon'];
  final polygon = polygonData is List
      ? polygonData.map((point) {
          final lat = point['lat'];
          final lng = point['lng'];
          if (lat == null || lng == null) return null;
          return Point(latitude: lat, longitude: lng);
        }).whereType<Point>().toList()
      : <Point>[];

  return Field(
    id: id,
    name: data['name'] ?? '',
    type: data['type'] ?? '',
    description: data['description'] ?? '',
    latitude: (data['latitude'] ?? 0.0).toDouble(),
    longitude: (data['longitude'] ?? 0.0).toDouble(),
    image: data['image'] ?? '',
    polygon: polygon,
  );
}


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
      'polygon': polygon
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    };
  }
}
