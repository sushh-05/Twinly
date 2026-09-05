import 'package:flutter/material.dart';

class Garment {
  final String id;
  final String name;
  final Color placeholderColor;
  // Size chart for a "standard" size of this garment — the fit engine
  // compares the user's measurements against these.
  final double chartChest;
  final double chartWaist;
  final double chartHip;

  const Garment({
    required this.id,
    required this.name,
    required this.placeholderColor,
    required this.chartChest,
    required this.chartWaist,
    required this.chartHip,
  });
}
