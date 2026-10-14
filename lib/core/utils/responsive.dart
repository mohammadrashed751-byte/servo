import 'package:flutter/material.dart';


double responsiveHeight(
  BuildContext context,
  double value, {
  double baseHeight = 932,
}) {
  double screenHeight = MediaQuery.of(context).size.height;
  return (value / baseHeight) * screenHeight;
}

double responsiveWidth(
  BuildContext context,
  double value, {
  double baseWidth = 430,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  return (value / baseWidth) * screenWidth;
}
