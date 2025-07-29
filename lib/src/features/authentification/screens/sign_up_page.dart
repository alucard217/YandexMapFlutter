import 'package:flutter/material.dart';
import 'package:yandexmap/src/constants/sizes.dart';
import 'package:yandexmap/src/features/authentification/controllers/singup_controller.dart';
import 'package:yandexmap/src/features/authentification/screens/login_page.dart';
// import 'package:yandexmap/src/features/authentification/screens/otp_screen.dart';
import 'package:get/get.dart';

final _formKey = GlobalKey<FormState>();

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 150),
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Sign Up".toUpperCase(), style: Theme.of(context).textTheme.headlineLarge,),
              Text("Enter your credentials to sign in", style: Theme.of(context).textTheme.bodyMedium,),
              Form(
                key: _formKey, // Connect the form key here
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: SignUpForm(context, isDarkMode),
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
                      label: Text("Sign-In with Google", style: Theme.of(context).textTheme.bodyMedium,),
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
                      MaterialPageRoute(builder: (context) => LoginScreen())
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Login",
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

  Column SignUpForm(BuildContext context, bool isDarkMode) {
    final controller = Get.put(SignUpController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.fullName,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline_outlined),
            labelText: "Full Name",
            hintText: "Full Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        SizedBox(height: tFormHeight - 20),
        TextFormField(
          controller: controller.email,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            labelText: "E-mail",
            hintText: "E-mail",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: tFormHeight - 20),
        TextFormField(
          controller: controller.phoneNo,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.numbers),
            labelText: "Phone Number",
            hintText: "Phone Number",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        SizedBox(height: tFormHeight - 20),
        TextFormField(
          controller: controller.password,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fingerprint),
            labelText: "Password",
            hintText: "Password",
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: null,
              icon: Icon(Icons.remove_red_eye_outlined),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        SizedBox(height: tFormHeight - 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              backgroundColor: Colors.black,
            ),
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                
              await controller.registerUser(
                context,
                controller.email.text.trim(),
                controller.password.text.trim(),
              );

            // SignUpController.instance.phoneAuthentification(controller.phoneNo.text.trim());
            // Get.to(() => OTPScreen());
              } else {
                print("Form is invalid");
                print("Full Name: ${controller.fullName.text}");
                print("Email: ${controller.email.text}");
                print("Phone: ${controller.phoneNo.text}");
                print("Password: ${controller.password.text}");
              }
            },
            child: Text("signup".toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}