import 'package:flutter/material.dart';
import 'package:yandexmap/src/constants/sizes.dart';
import 'package:yandexmap/src/features/authentification/screens/login_page.dart';
import 'package:yandexmap/src/features/authentification/screens/sign_up_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    print("✅ WelcomeScreen initState");

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward().then((_) {
      print("✅ Анимация завершена");
    });
  }

  @override
  void dispose() {
    print("🛑 WelcomeScreen disposed");
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🧱 WelcomeScreen build вызван");

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Container(
        padding: const EdgeInsets.all(tDefaultSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                width: 300,
                height: 500,
                child: Image(
                  image: const AssetImage("assets/images/football_field.png"),
                  errorBuilder: (context, error, stackTrace) {
                    print("❌ Ошибка загрузки football_field.png: \$error");
                    return  Text("Изображение не найдено");
                  },
                ),
              ),
            ),
            Text(
              "Welcome to our project",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      backgroundColor: isDarkMode ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: tButtonHeight),
                    ),
                   onPressed: () {
                    print("➡️ Переход на LoginScreen");
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } catch (e, stack) {
                      print("❌ Ошибка при переходе на LoginScreen: \$e");
                      print(stack);
                    }
                  },
                    child: Text(
                      "Login".toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.black : Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      backgroundColor: isDarkMode ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: tButtonHeight),
                    ),
                    onPressed: () {
                      print("➡️ Нажатие на Sign Up");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      "Sign Up".toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
