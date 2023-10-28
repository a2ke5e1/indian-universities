class Strings {
  Strings._();

  static const String BIO_MSG =
      "Provide a brief bio to help us personalize your experience.";
  static const String BIRTHDAY_MSG =
      "Your age will help us provide relevant content and features tailored to your preferences.";
  static const String PASSWORD_RULES = """Password should
1. At least contain one of these characters !, @,#, \$, %, ^, &, *
2. At least contain one Uppercase letter. 
3. At least contain one digit.
4. At least contain one Lowercase letter. 
5. Minimum length is 8 characters.
""";
  static const String WRONG_EMAIL_PASSWORD = "Wrong Email or password";
  static const String EMAIL_VERIFICATION_INTRO =
      "In order to use the app, you need to verify your email address.";
  static const String AUTH_WEAK_PASSWORD = "The password provided is too weak.";
  static const String AUTH_EMAIL_ALREADY_IN_USE =
      "The account already exists for that email.";
  static const String AUTH_NETWORK_ERROR =
      "No Internet! Check your connection and try again.";
  static const String AUTH_TOO_MANY_REQUESTS =
      "Too many requests! Try again later.";
  static const String RESET_PASSWORD_DESCRIPTION =
      "Enter your email address below and we'll send you a link to reset your password.";
}
