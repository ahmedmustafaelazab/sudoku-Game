import 'package:flutter/material.dart';
import 'package:sudoku/utilties/my_constant/my_constants.dart';

AppBar gameAppBar(
  String title,
) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: primaryColor,
    elevation: .9,
    shadowColor: Colors.red,
  );
}
