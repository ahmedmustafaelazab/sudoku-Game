import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sudoku/controllers/home_controller.dart';
import 'package:sudoku/views/game_grid.dart';
import 'package:sudoku/utilties/my_constant/my_constants.dart';

class CustomBotton extends StatelessWidget {
  final String text;
  final double padding;
  CustomBotton({super.key, required this.text, required this.padding});
  HomeController _homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(primaryColor),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          padding: MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: padding))),
      onPressed: () {
        _homeController.setGameDiffculity(text);
        Get.to(GameGrid());
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
