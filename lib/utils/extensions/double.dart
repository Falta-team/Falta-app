import 'package:flutter/material.dart';

extension DoubleExtension on double {
  Widget get ws => SizedBox(width: this);
  Widget get hs => SizedBox(height: this);
}