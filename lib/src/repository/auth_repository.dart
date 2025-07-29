import 'package:firebase_auth/firebase_auth.dart';
import 'package:yandexmap/map_booking_screen.dart';
import 'package:yandexmap/src/features/authentification/screens/dashboard.dart';
import 'package:yandexmap/src/features/authentification/screens/welcome_screen.dart';
import 'package:yandexmap/src/repository/exceptions/signup_failure.dart';
import 'package:get/get.dart';
// import 'package:yandexmap/src/features/authentification/screens/map.dart';

class AuthentificationRepository extends GetxController {
  static AuthentificationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  var verificationId = ''.obs;

@override
void onReady() {
  super.onReady();
  firebaseUser = Rx<User?>(_auth.currentUser);
  firebaseUser.bindStream(_auth.userChanges());

  ever(firebaseUser, (user) {
    print("🔁 Слушатель авторизации: ${user?.email}");
  });
}


Future<void> phoneAuthentification(String phoneNo) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNo,
    verificationCompleted: (credential) async {
      await _auth.signInWithCredential(credential);
    },
    codeSent: (verificationId, resendToken) {
      this.verificationId.value = verificationId;
      // Get.to(() => const Map());
    }, 
    codeAutoRetrievalTimeout: (verificationId){
      this.verificationId.value = verificationId;
    },
    verificationFailed: (e){
      if (e.code == 'invalid-phone-number') {
      Get.snackbar("Error", "The provided phone number is not valid",);
    } else {
      Get.snackbar("Error", "Something went wrong",);
    }
    }
    );
} 

Future<bool> verifyOTP(String otp) async {
  var credentials = await _auth.signInWithCredential(PhoneAuthProvider.credential(
    verificationId: verificationId.value,
    smsCode: otp,
  ));
  return credentials.user != null ? true : false;
}

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try { 
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    firebaseUser.value != null? Get.offAll(() => const Dashboard()) : Get.to(() => WelcomeScreen());
  // ignore: unused_catch_clause
  } on FirebaseException catch(e) {
    final ex = SignUpEmailAndPasswordFailure.code(e.code);
    print('FIREBASE AUTH EXCEPTION - ${ex.message}' );
    throw ex;
  } catch (_) {
    const ex = SignUpEmailAndPasswordFailure();
    print('EXCEPTION - ${ex.message}');
    throw ex;
  }
}

 Future<void> loginWithEmailAndPassword(String email, String password) async {
    try { 
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  // ignore: unused_catch_clause
  } on FirebaseException catch(e){}
    catch (_) {}
  }

  Future<void> logout() async => await _auth.signOut();
}