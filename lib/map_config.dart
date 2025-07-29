import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapConfig {
  final MapObjectId targetMapObjectId;
  bool tiltGesturesEnabled;
  bool zoomGesturesEnabled;
  bool rotateGesturesEnabled;
  bool scrollGesturesEnabled;
  bool modelsEnabled;
  bool nightModeEnabled;
  bool fastTapEnabled;
  bool mode2DEnabled;
  ScreenRect? focusRect;
  MapType mapType;
  int? poiLimit;
  final String style;
  final CameraPosition startCameraPosition;

  MapConfig({
    this.startCameraPosition = const CameraPosition(
        target: Point(latitude: 58.5966, longitude: 49.6601)),
    this.targetMapObjectId = const MapObjectId('target_placemark'),
    this.tiltGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.modelsEnabled = true,
    this.nightModeEnabled = false,
    this.fastTapEnabled = false,
    this.mode2DEnabled = false,
    this.focusRect,
    this.mapType = MapType.vector,
    this.poiLimit,
    this.style = '''
    {
      "tags": {
        "all": ["park"]
      },
      "stylers": {
        "color": "#5db839"
      }
    }
    ''',
  });
}