String authErrorMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'user-not-found':
      return 'No account was found for this email.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled in Firebase.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    case 'network-request-failed':
      return 'Network error. Check your internet connection.';
    default:
      return 'Authentication failed. ($code)';
  }
}
