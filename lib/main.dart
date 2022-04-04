import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minesweeper/ai.dart';
import 'package:minesweeper/board.dart';
import 'package:minesweeper/definitions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const Mine(),
    );
  }
}

class Mine extends StatefulWidget {
  const Mine({Key? key}) : super(key: key);

  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> {
  FocusNode focusNode = FocusNode();
  int width = 30;
  int height = 16;
  int mines = 99;
  Board board = Board(30, 16, 99);
  bool gameOver = false;
  bool initd = false;
  bool aiEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  void _reset() {
    board = Board(width, height, mines);
    gameOver = false;
    initd = false;
    setState(() {});
  }

  void _reveal(int x, int y) {
    if (!initd) {
      board.reset(x, y);
      initd = true;
    }
    if (board.revealed[x][y] == -2) {
      switch (board.val(x, y)) {
        case 0:
          if (!gameOver) {
            for (int i = -1; i <= 1; i++) {
              for (int j = -1; j <= 1; j++) {
                if (board.isPosValid(x + i, y + j) &&
                    board.revealed[x + i][y + j] == -2) {
                  _reveal(x + i, y + j);
                }
              }
            }
          }
          break;
        case -1:
          if (!gameOver) {
            gameOver = true;
            for (int i = 0; i < board.height; i++) {
              for (int j = 0; j < board.width; j++) {
                _reveal(i, j);
              }
            }
          }
          break;
        default:
      }
      setState(() {});
    }
  }

  void _aiMove() {
    Coords coords = AI(board).getBestMove();
    _reveal(coords.x, coords.y);
    setState(() {});
    if (aiEnabled) Timer(const Duration(milliseconds: 10), _aiMove);
  }

  void _toggleAI() {
    aiEnabled != aiEnabled;
    if (aiEnabled) _aiMove();
  }

  void _toggleFlag(int x, int y) {
    if (board.revealed[x][y] == -2 || board.revealed[x][y] == -3) {
      setState(() {
        board.flags += board.revealed[x][y] == -2 ? 1 : -1;
        board.revealed[x][y] = board.revealed[x][y] == -2 ? -3 : -2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minesweeper"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GridView.count(
              childAspectRatio: 1,
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: RelSize(context).pixel(),
              mainAxisSpacing: RelSize(context).pixel(),
              crossAxisCount: width,
              children: List.generate(
                  width * height,
                  (index) => Cell(
                      reveal: _reveal,
                      value: board.revealed[index ~/ width][index % width],
                      toggleFlag: _toggleFlag,
                      x: index ~/ width,
                      y: index % width))),
          Padding(
            padding: EdgeInsets.all(8.0 * RelSize(context).pixel()),
            child: Ink(
              height: 120 * RelSize(context).pixel(),
              width: 480 * RelSize(context).pixel(),
              color: Colors.grey.shade700,
              child: InkWell(
                hoverColor: Colors.grey,
                mouseCursor: SystemMouseCursors.click,
                onTap: _reset,
                child: Center(
                  child: Text(
                    "Play Again",
                    style: TextStyle(
                      fontSize: 80 * RelSize(context).pixel(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0 * RelSize(context).pixel()),
            child: Ink(
              height: 120 * RelSize(context).pixel(),
              width: 480 * RelSize(context).pixel(),
              color: Colors.grey.shade700,
              child: InkWell(
                hoverColor: Colors.grey,
                mouseCursor: SystemMouseCursors.click,
                onTap: _toggleAI,
                child: Center(
                  child: Text(
                    "AI Move",
                    style: TextStyle(
                      fontSize: 80 * RelSize(context).pixel(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text((board.mines - board.flags).toString()),
        ],
      ),
    );
  }
}

class Cell extends StatefulWidget {
  final Function reveal;
  final Function toggleFlag;
  final int value;
  final int x;
  final int y;
  const Cell(
      {Key? key,
      required this.reveal,
      required this.value,
      required this.toggleFlag,
      required this.x,
      required this.y})
      : super(key: key);

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  Map<int, Color> colors = {
    -3: Colors.black,
    -2: Colors.grey.shade700,
    -1: Colors.black,
    0: Colors.grey.shade400,
    1: Colors.green,
    2: Colors.yellow.shade700,
    3: Colors.orange.shade700,
    4: Colors.red,
    5: Colors.purple,
    6: Colors.deepPurple,
    7: Colors.brown,
    8: Colors.grey.shade800,
  };

  Map<int, Widget?> icons = {
    -3: const Icon(Icons.flag),
    -2: null,
    -1: const Icon(Icons.circle),
    0: null,
  };

  void _reveal() {
    widget.reveal(widget.x, widget.y);
  }

  void _toggleFlag() {
    widget.toggleFlag(widget.x, widget.y);
  }

  @override
  void initState() {
    super.initState();
    for (int i = 1; i < 9; i++) {
      icons.addAll({i: Text(i.toString())});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _toggleFlag,
      onSecondaryTap: _toggleFlag,
      child: Padding(
        padding: EdgeInsets.all(RelSize(context).pixel()),
        child: Ink(
          color: colors[widget.value],
          child: InkWell(
            hoverColor: widget.value == -2 ? Colors.grey : colors[widget.value],
            mouseCursor: widget.value == -2 ? SystemMouseCursors.click : null,
            onTap: _reveal,
            child: Center(
              child: icons[widget.value],
            ),
          ),
        ),
      ),
    );
  }
}
