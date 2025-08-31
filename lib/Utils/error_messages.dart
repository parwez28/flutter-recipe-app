String getFirebaseAuthErrorMessage(String code) {
  switch (code) {
    case "invalid-email":
      return "Please enter a valid email address.";
    case "email-already-in-use":
      return "This email is already registered.";
    case "weak-password":
      return "Password must be at least 6 characters long.";
    case "user-not-found":
      return "No user found with this email.";
    case "wrong-password":
      return "Incorrect password. Try again.";
    case "invalid-credential": // Some SDK versions return this instead
      return "Incorrect email or password. Try again.";
    default:
      return "An unexpected error occurred. Please try again.";
  }
}
