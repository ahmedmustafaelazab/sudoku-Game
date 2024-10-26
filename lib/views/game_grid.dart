import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sudoku/controllers/game_controllers.dart';
import 'package:sudoku/controllers/home_controller.dart';
import 'package:sudoku/utilties/sudoku_solver_generator/sudoku_generator_base.dart';
import 'package:sudoku/models/Box.dart';
import 'package:sudoku/utilties/my_constant/my_constants.dart';
import 'package:sudoku/views/widgets/game_app_bar.dart';
import 'package:sudoku/views/widgets/mydialog.dart';
import 'package:sudoku/views/widgets/too_bar_item.dart';
import 'package:sudoku/views/widgets/vertical_horizontal_spance.dart';

class GameGrid extends StatefulWidget {
  GameGrid({super.key});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  GameController gameController = Get.put(GameController());
  HomeController _homeController = Get.find();
  late List list = [];
  //stopwatch
  void _stopWatch() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      gameController.updateTimer();
    });
  }

  @override
  void initState() {
    super.initState();
    _stopWatch();

    var s = SudokuGenerator(
        emptySquares: _homeController.numberOfEmptySquare(),
        uniqueSolution: true);
    gameController.setBoxs(s.newSudoku);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gameAppBar("Sudoku Ai"),
      body: gameGridUi(),
    );
  }

  gameGridUi() {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: backgroundColor,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            verticalSpace(20),
            infoRow(),
            verticalSpace(40),
            theGrid(),
            verticalSpace(40),
            toolBar(),
            verticalSpace(40),
            inputView()
          ],
        ));
  }

  infoRow() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.back_hand,
              size: 30,
            ),
          ),
          GetX<GameController>(
            builder: (controller) {
              int minutes = gameController.time ~/ 60;
              int sec = gameController.time % 60;
              return Column(
                children: [
                  Text("Time", style: smallLightTextStyle),
                  Text("$minutes :$sec", style: smallBoldTextStyle)
                ],
              );
            },
          ),
          infoRowChild("Score", 120),
          GetBuilder<GameController>(
            builder: (controller) {
              return Column(
                children: [
                  Text("Mistakes", style: smallLightTextStyle),
                  Text(gameController.mistakes.toString(),
                      style: smallBoldTextStyle)
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  infoRowChild(String title, int value) {
    return Column(
      children: [
        Text(title, style: smallLightTextStyle),
        Text(value.toString(), style: smallBoldTextStyle)
      ],
    );
  }

  theGrid() {
    return GetBuilder<GameController>(
      builder: (controller) {
        return Container(
          height: 400,
          width: 400,
          decoration: squareBoldBorder,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 81,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9, mainAxisSpacing: 0, crossAxisSpacing: 0),
            itemBuilder: (context, index) {
              int row = index ~/ 9;
              int col = index % 9;
              Box box = gameController.boxs[row][col];
              return GestureDetector(
                  onTap: () {
                    gameController.onBoxClick(row, col);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: box.inHintStack
                          ? Color.fromARGB(255, 81, 255, 62)
                          : box.isWrong
                              ? Color.fromARGB(255, 255, 95, 84)
                              : box.isSelected
                                  ? primaryColor
                                  : box.hasRelationWithSelected
                                      ? SecondaryColor
                                      : Colors.grey.shade200,
                      border: (row + 1) % 3 == 0
                          ? Border(
                              bottom: const BorderSide(
                                  color: Colors.black, width: 2),
                              left: (col) % 3 == 0
                                  ? const BorderSide(
                                      color: Colors.black, width: 2)
                                  : const BorderSide(
                                      color: Color.fromARGB(255, 204, 204, 204),
                                      width: 1))
                          : (col) % 3 == 0
                              ? const Border(
                                  left:
                                      BorderSide(color: Colors.black, width: 2),
                                  bottom: BorderSide(
                                      color: Color.fromARGB(255, 204, 204, 204),
                                      width: 1))
                              : Border.all(
                                  color:
                                      const Color.fromARGB(255, 204, 204, 204),
                                  width: 1),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        box.number == 0 ? "" : box.number.toString(),
                        style: LargeTextStyle,
                      ),
                    ),
                  ));
            },
          ),
        );
      },
    );
  }

  toolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TooBarItem(
            iconShape: FontAwesomeIcons.lightbulb,
            text: "Hint",
            onPressed: () {
              gameController.getHint();
            }),
        TooBarItem(
            iconShape: FontAwesomeIcons.eraser,
            text: "Delete",
            onPressed: () {
              delete();
            }),
        TooBarItem(
            iconShape: FontAwesomeIcons.arrowRotateLeft,
            text: "Back",
            onPressed: () {
              gameController.backOneStep();
            })
      ],
    );
  }

  inputView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        theInput(1),
        theInput(2),
        theInput(3),
        theInput(4),
        theInput(5),
        theInput(6),
        theInput(7),
        theInput(8),
        theInput(9),
      ],
    );
  }

  theInput(int number) {
    return InkWell(
      onTap: () {
        //check if there is selected box
        if (gameController.getCurrentSelectedBox()?.number != null) {
          //check if selected box is empty
          if (gameController.getCurrentSelectedBox()!.number == 0) {
            gameController.checkIfTheNumIsCorrect(number);
          } else {
            //if selected box not empty
            myDialog(context, "This Box Is Already Filled");
          }
        } else {
          // if there is not selected box
          myDialog(context, "You Must Select Box To Play In");
        }
      },
      child: Text(
        number.toString(),
        style: const TextStyle(fontSize: 35, color: primaryColor),
      ),
    );
  }

  delete() {
    if (gameController.getCurrentSelectedBox() != null) {
      gameController.deleteNumInSelectedBox();
    }
  }
}
