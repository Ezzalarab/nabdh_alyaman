extension ExtString on String {
  bool get isValidName {
    final nameRegExp =
        RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"^7[0-9]{7}[0-9]$");
    final phoneWithKeyCodeRegExp = RegExp(r"^\+9677[0-9]{7}[0-9]$");
    return phoneRegExp.hasMatch(this) || phoneWithKeyCodeRegExp.hasMatch(this);
  }

  bool get isValidPhoneWithKeyCode {
    final phoneWithKeyCodeRegExp = RegExp(r"^\+9677[0-9]{7}[0-9]$");
    return phoneWithKeyCodeRegExp.hasMatch(this);
  }

  bool get isValidEmail {
    final phoneRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return phoneRegExp.hasMatch(this);
  }
}
