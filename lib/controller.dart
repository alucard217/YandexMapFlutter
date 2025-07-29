import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'map_tag_info.dart';

class MapScreenController {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];

  void createTabObjects(BuildContext context) {
    mapObjects.addAll([
      PlacemarkMapObject(
        mapId: const MapObjectId('marker_1'),
        point: const Point(latitude: 51.1280, longitude: 71.4304),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/images/map_marks/shop.png'),
            scale: 0.45,
            anchor: const Offset(0.5, 1.0),
          ),
        ),
        onTap: (self, point) {
          showDialog(
            context: context,
            builder: (_) => _buildBookingDialog(context),
          );
        },

      ),
      PlacemarkMapObject(
        mapId: const MapObjectId('marker_2'),
        point: const Point(latitude: 51.1602, longitude: 71.4017),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/images/map_marks/shop.png'),
            scale: 0.45,
            anchor: const Offset(0.5, 1.0),
          ),
        ),
        onTap: (self, point) {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('Центральный Парк'),
              content: Text('Подходит для отдыха, спорта и прогулок.'),
            ),
          );
        },
      ),
      PlacemarkMapObject(
        mapId: const MapObjectId('marker_3'),
        point: const Point(latitude: 51.1503, longitude: 71.4389),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/images/map_marks/shop.png'),
            scale: 0.45,
            anchor: const Offset(0.5, 1.0),
          ),
        ),
        onTap: (self, point) {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('Park of Culture and Leisure'),
              content: Text('Beautiful park with walking paths and playgrounds.'),
            ),
          );
        },
      ),
    ]);

    mapObjects.add(
      PolygonMapObject(
        mapId: const MapObjectId('park_polygon'),
        polygon: Polygon(
          outerRing: const LinearRing(
            points: [
              Point(latitude: 51.1608, longitude: 71.4260),
              Point(latitude: 51.1612, longitude: 71.4285),
              Point(latitude: 51.1590, longitude: 71.4295),
              Point(latitude: 51.1587, longitude: 71.4265),
            ],
          ),
          innerRings: [],
        ),
        strokeColor: Colors.blue.shade900,
        fillColor: Colors.blue.withOpacity(0.4),
        strokeWidth: 3,
        isGeodesic: false,
      ),
    );

  }


  void startPositionCamera(CameraPosition coordinates) {
    controller.moveCamera(CameraUpdate.newCameraPosition(coordinates));
  }

  Future<void> createUserTabObject(BuildContext context) async {
    if (await locationPermissionNotGranted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission was NOT granted')),
      );
    }
  }

  Future<void> userPositionCamera(BuildContext context) async {
    final location = await userLocation();
    controller.moveCamera(
      CameraUpdate.newCameraPosition(location),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.2),
    );
  }

  Future<CameraPosition> userLocation() async {
    return const CameraPosition(target: Point(latitude: 51.1605, longitude: 71.4704), zoom: 15);
  }

  Future<bool> locationPermissionNotGranted() async {
    var status = await Permission.location.request();
    return !status.isGranted;
  }
}

Widget _buildBookingDialog(BuildContext context) {
  final nameController = TextEditingController();
  final timeController = TextEditingController();

  return AlertDialog(
    title: const Text('Booking a Field'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
          ),
        ),
        TextField(
          controller: timeController,
          decoration: const InputDecoration(
            labelText: 'Time (HH:MM)',
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          // здесь можно сохранить введённые данные или вывести в консоль
          String name = nameController.text;
          String time = timeController.text;

          print('User: $name, Time: $time');
          Navigator.pop(context);
        },
        child: const Text('Set Booking'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );
}
