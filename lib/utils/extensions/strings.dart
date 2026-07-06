extension ImagePathExtension on String {
  String get image_ => 'assets/images/$this';
  String get icon_ => 'assets/icons/$this';
}