// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yandexmap/src/constants/sizes.dart';
import 'package:yandexmap/src/features/authentification/controllers/singup_controller.dart';
import 'package:yandexmap/src/features/authentification/screens/forget_password_mail.dart';
import 'package:yandexmap/src/features/authentification/screens/otp_screen.dart';
import 'package:yandexmap/src/features/authentification/screens/sign_up_page.dart';
import 'package:get/get.dart';


class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(SignUpController());

  LoginScreen({super.key});// Initialize the controller

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Login Here", style: Theme.of(context).textTheme.headlineLarge,),
              Text("To gather people and enjoy it", style: Theme.of(context).textTheme.bodyMedium,),
              Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: loginForm(context, isDarkMode),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("OR", style: Theme.of(context).textTheme.headlineMedium,),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      icon: Image(image: AssetImage("assets/images/google_logo.png"), width: 30,),
                      label: Text("Sign with Google", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(color: Colors.blue),
                        )
                      ]
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column loginForm(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.email, // Use the controller
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline_outlined),
            labelText: "E-mail",
            hintText: "E-mail",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: tFormHeight - 20),
        TextFormField(
          controller: controller.password, // Use the controller
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fingerprint),
            labelText: "Password",
            hintText: "Password",
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: null,
              icon: Icon(Icons.remove_red_eye_outlined),
            )
          ),
          obscureText: true,
        ),
        SizedBox(height: tFormHeight - 20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(tDefaultSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Make Selection!", style: Theme.of(context).textTheme.headlineMedium,),
                      Text("Select one of the options given below to reset password", style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 30,),
                      // RESET BY E-MAIL
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgetPasswordMailScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: isDarkMode ? Colors.black : Colors.grey.shade200,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mail_outline_outlined, size: 60.0,),
                              const SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("E-mail", style: Theme.of(context).textTheme.headlineMedium,),
                                  Text("Reset via E-mail Verification", style: Theme.of(context).textTheme.bodyMedium,),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      // RESET BY NUMBER
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OTPScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: isDarkMode ? Colors.black : Colors.grey.shade200,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_android_outlined, size: 60.0,),
                              const SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Phone No", style: Theme.of(context).textTheme.headlineMedium,),
                                  Text("Reset via Phone Verification", style: Theme.of(context).textTheme.bodyMedium,),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text("Forget password?"),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              backgroundColor: Colors.black,
            ),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Set the context for the controller
                // Call the login method
                controller.loginUser(
                  context,
                  controller.email.text.trim(),
                  controller.password.text.trim(),
                );
              } else {
                print("Form is invalid");
                print("Email: ${controller.email.text}");
                print("Password: ${controller.password.text}");

              }
            },
            child: Text("Login".toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}