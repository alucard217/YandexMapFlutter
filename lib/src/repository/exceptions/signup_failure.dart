
class SignUpEmailAndPasswordFailure {
  final String message;

  const SignUpEmailAndPasswordFailure([this.message = "An unknown error occured."]);

  factory SignUpEmailAndPasswordFailure.code(String code) {
    switch(code){
      case 'weak-password':
        return const SignUpEmailAndPasswordFailure('please enter a stronger password.');
      case 'invalid-email':
        return const SignUpEmailAndPasswordFailure('Email is not valid or badly formated.');
      case 'email-already-in-use':
        return const SignUpEmailAndPasswordFailure('An account already exists for the email.');
      case 'operation-non-allowed':
        return const SignUpEmailAndPasswordFailure('Operation is not allowed. Please contact support');
      case 'user-disabled':
        return const SignUpEmailAndPasswordFailure('please enter a stronger password');
      default:
        return const SignUpEmailAndPasswordFailure();
    }
  }
}