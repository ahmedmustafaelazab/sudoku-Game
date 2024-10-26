// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sudoku/models/Box.dart';
import 'package:sudoku/utilties/data_structure/stack.dart';
import 'package:sudoku/utilties/my_constant/my_constants.dart';

class GameController extends GetxController {
  final List<List<Box>> _gridBoxs = [];
  List<List<int>> _gridBoxsAsNumber = [];
  final _time = 0.obs;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _mistakes = 0;
  Box? _currentSelectedBox;
  List<List<int>> preSolved = [];
  get boxs => _gridBoxs;

  get time => _time.value;
  get mistakes => _mistakes;
  StackDataStructure<Box> lastPlayedStack = StackDataStructure<Box>();

  updateTimer() {
    _time.value += 1;
  }

  setBoxs(listOfListOfint) {
    _gridBoxsAsNumber = listOfListOfint;

    for (var slist in listOfListOfint) {
      List<Box> list = [];
      for (var number in slist) {
        Box box = Box(
            inHintStack: false,
            isSelected: false,
            hasRelationWithSelected: false,
            isWrong: false,
            number: number);
        list.add(box);
      }
      _gridBoxs.add(list);
    }

    // solve by sudoku algorthim
    preSolved = copyOfGridBoxsValues(boxs);
    solveSudoku(preSolved);
  }

  // to change row and col color and box(3*3) color and set current selected box
  onBoxClick(int row, int col) {
    _setCurrentSelectedBox(row, col);
    _selectedCol = col;
    _selectedRow = row;

    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        _gridBoxs[i][j].isSelected = false;
        _gridBoxs[i][j].hasRelationWithSelected = false;
        _gridBoxs[i][j].isWrong = false;
      }
    }

    for (var i = 0; i < 9; i++) {
      _gridBoxs[row][i].hasRelationWithSelected = true;
    }
    for (var i = 0; i < 9; i++) {
      _gridBoxs[i][col].hasRelationWithSelected = true;
    }

    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (var i = boxRow; i < boxRow + 3; i++) {
      for (var j = boxCol; j < boxCol + 3; j++) {
        _gridBoxs[i][j].hasRelationWithSelected = true;
      }
    }

    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        if (_currentSelectedBox != null) {
          if (getCurrentSelectedBox()!.number != 0) {
            if (getCurrentSelectedBox()!.number == _gridBoxs[i][j].number) {
              _gridBoxs[i][j].hasRelationWithSelected = true;
            }
          }
        }
      }
    }
    _gridBoxs[row][col].isSelected = true;
    update();
  }

  _setCurrentSelectedBox(int row, int col) {
    _currentSelectedBox = _gridBoxs[row][col];
  }

  Box? getCurrentSelectedBox() {
    return _currentSelectedBox;
  }

  deleteNumInSelectedBox() {
    lastPlayedStack.remove(_currentSelectedBox!);
    _currentSelectedBox!.number = 0;
    update();
  }

  backOneStep() {
    if (!lastPlayedStack.isEmpty()) {
      lastPlayedStack.pop().number = 0;
      update();
    }
  }

  checkIfTheNumIsCorrect(int number) {
    //check if input number is the same of the number in presolved
    if (preSolved[_selectedRow][_selectedCol] == number) {
      _currentSelectedBox?.number = number;
      lastPlayedStack.push(_currentSelectedBox!);
    } else {
      //if not
      _currentSelectedBox?.isWrong = true;
      increaseMistakes();
    }
    update();
  }

  bool solveSudoku(List<List<int>> gridBoxsCopy) {
    const gridSize = 9;
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        if (gridBoxsCopy[row][col] == 0) {
          for (var i = 1; i <= 9; i++) {
            if (isValidMove(gridBoxsCopy, row, col, i)) {
              gridBoxsCopy[row][col] = i;

              if (solveSudoku(gridBoxsCopy)) {
                return true;
              }
              //else
              gridBoxsCopy[row][col] = 0;
            }
          }
          return false; // no valid number found
        }
      }
    }

    return true; // grid is full
  }

  bool isValidMove(List<List<int>> gridBoxsCopy, int row, int col, int number) {
    const gridSize = 9;
    //check row and col
    for (var i = 0; i < gridSize; i++) {
      if (gridBoxsCopy[row][i] == number || gridBoxsCopy[i][col] == number) {
        return false;
      }
    }

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    //check 3 by 3 square
    for (var i = startRow; i < startRow + 3; i++) {
      for (var j = startCol; j < startCol + 3; j++) {
        if (gridBoxsCopy[i][j] == number) {
          return false;
        }
      }
    }

    return true;
  }

  increaseMistakes() {
    _mistakes += 1;
  }

  getHint() {
    List<List<int>> _3x3Boxsprobability = [];
    int startRow = 0;
    int startCol = 3;
    _3x3Boxsprobability = _helperGetHint(startRow, startCol);
    print(_3x3Boxsprobability);

    bool boxHasOnePorbability = false;
    int boxNumberWhichHasOneProbability = -1;
    for (var i = 0; i < _3x3Boxsprobability.length; i++) {
      if (_3x3Boxsprobability[i].length == 1) {
        //if one box has one probability
        boxHasOnePorbability = true;
        boxNumberWhichHasOneProbability = i;
        break;
      }
    }

    if (boxHasOnePorbability) {
      int boxRow = (boxNumberWhichHasOneProbability ~/ 3) + startRow;
      int boxCol = (boxNumberWhichHasOneProbability % 3) + startCol;

      _handleBoxHasOnePorbability(boxRow, boxCol);
    } else {}
  }

  _helperGetHint(int rowStart, int colStart) {
    List<List<int>> _3x3Boxsprobability = [];

    // loop on every box in 3x3
    for (int row = rowStart; row < rowStart + 3; row++) {
      for (var col = colStart; col < colStart + 3; col++) {
        List<int> helper = [];
        // check if the box is empty
        if (boxs[row][col].number == 0) {
          for (var number = 1; number <= 9; number++) {
            // check if the number is valild to this box
            if (isValidMove(_gridBoxsAsNumber, row, col, number)) {
              helper.add(number);
            }
          }
        }
        _3x3Boxsprobability.add(helper);
      }
    }
    return _3x3Boxsprobability;
  }

  _handleBoxHasOnePorbability(int row, int col) async {
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    //check 3 by 3 square
    List<int> validNumberIn3x3 = [];
    for (var number = 1; number <= 9; number++) {
      bool numberIsValid = true;
      for (var i = startRow; i < startRow + 3; i++) {
        for (var j = startCol; j < startCol + 3; j++) {
          if (_gridBoxs[i][j].number == number) {
            numberIsValid = false;
          }
        }
      }
      //if number is valid
      if (numberIsValid) validNumberIn3x3.add(number);
    }
    List<int> copyValidNumberIn3x3 = [];
    copyValidNumberIn3x3.addAll(validNumberIn3x3);
    List<Box> theReasonsBoxs = [];
    for (var i = 0; i < 9; i++) {
      if (copyValidNumberIn3x3.contains(_gridBoxs[row][i].number)) {
        theReasonsBoxs.add(_gridBoxs[row][i]);
        copyValidNumberIn3x3.remove(_gridBoxs[row][i].number);
      } else if (copyValidNumberIn3x3.contains(_gridBoxs[i][col].number)) {
        theReasonsBoxs.add(_gridBoxs[i][col]);
        copyValidNumberIn3x3.remove(_gridBoxs[i][col].number);
      }
    }

    for (Box box in theReasonsBoxs) {
      box.inHintStack = true;
      if (_currentSelectedBox != null) _currentSelectedBox!.isSelected = false;
      _setCurrentSelectedBox(row, col);
      _gridBoxs[row][col].isSelected = true;
    }

    bottomSheet(validNumberIn3x3, copyValidNumberIn3x3, theReasonsBoxs);
    update();
  }

  bottomSheet(List<int> validNumberIn3x3, List<int> shouldPlay,
      List<Box> theResonsBoxs) {
    String text =
        "You Can Play in Blue Box This Numbers ${validNumberIn3x3.toString()} But Becouse Of Green Boxs Values You Can Play Only ${shouldPlay.toList()}";

    Get.dialog(
      barrierColor: const Color.fromARGB(0, 255, 255, 255),
      barrierDismissible: false,
      AlertDialog(
        insetPadding: const EdgeInsets.only(top: 550),
        title: const Text("Hint"),
        backgroundColor: Color.fromARGB(107, 0, 0, 0),
        content: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )),
        actions: [
          InkWell(
            onTap: () {
              for (Box box in theResonsBoxs) {
                box.inHintStack = false;
              }

              update();
              Get.back();
            },
            child: Container(
              color: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

List<List<int>> copyOfGridBoxsValues(List<List<Box>> gridBoxs) {
  List<List<int>> copedList = [];

  for (var lists in gridBoxs) {
    List<int> list = [];
    for (var box in lists) {
      list.add(box.number);
    }

    copedList.add(list);
  }

  return copedList;
}
