import 'package:flutter/material.dart';

extension IntExtension on int {
  Widget get ws => SizedBox(width: toDouble());
  Widget get hs => SizedBox(height: toDouble());
}