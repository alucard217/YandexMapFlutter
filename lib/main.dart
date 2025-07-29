import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandexmap/map_booking_screen.dart';
import 'package:yandexmap/src/features/authentification/controllers/theme_controller.dart';
import 'package:yandexmap/src/utils/theme/theme.dart';
import 'firebase_options.dart';
import 'src/features/authentification/screens/welcome_screen.dart';
import 'src/repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print(" Uncaught Flutter error: ${details.exception}");
  };
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthentificationRepository());
  await Permission.location.request();
  Get.put(ThemeController());
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Yandex MapKit Demo',
          debugShowCheckedModeBanner: false,
          theme: AppThemes().customLightTheme,
          darkTheme: AppThemes().customDarkTheme,
          themeMode: themeController.themeMode.value,
          home: const WelcomeScreen(),
        ));
  }
}

