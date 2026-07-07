
/// Normalizes a Palestinian phone number typed by the user into the
/// single format the backend expects — E.164 style: `+970XXXXXXXXX`
/// (9 digits after the country code, no leading zero).
///
/// Used everywhere a phone number is sent to the API (Login, Register,
/// ForgotPassword, ...) so the format is defined in exactly one place.
class PhoneFormatter {
  const PhoneFormatter._();

  static String toApiFormat(String raw) {
    // Strip anything that isn't a digit (spaces, dashes, +, etc.)
    var digits = raw.trim().replaceAll(RegExp(r'[^0-9]'), '');

    // Drop a country code the user may have typed manually (970... or 00970...)
    if (digits.startsWith('00970')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('970')) {
      digits = digits.substring(3);
    }

    // Drop a single leading zero (e.g. "0599887766" → "599887766")
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return '+970$digits';
  }
}
