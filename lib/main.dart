import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool settingsOpen = false;

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
    aiEnabled = !aiEnabled;
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
        actions: [
          settingsOpen
              ? IconButton(
                  onPressed: () {
                    if (width != board.width ||
                        height != board.height ||
                        mines != board.mines) _reset();
                    setState(() {
                      settingsOpen = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      settingsOpen = true;
                    });
                  },
                  icon: const Icon(Icons.settings),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: InteractiveViewer(
          maxScale: 10,
          child: settingsOpen
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100 * RelSize(context).pixel(),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(label: Text("Width:")),
                          onChanged: (val) {
                            setState(() {
                              width = int.tryParse(val) ?? width;
                            });
                          },
                          initialValue: width.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100 * RelSize(context).pixel(),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(label: Text("Height:")),
                          onChanged: (val) {
                            setState(() {
                              height = int.tryParse(val) ?? height;
                            });
                          },
                          initialValue: height.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100 * RelSize(context).pixel(),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(label: Text("Mines:")),
                          onChanged: (val) {
                            setState(() {
                              mines = int.tryParse(val) ?? mines;
                            });
                          },
                          initialValue: mines.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 50 * RelSize(context).pixel(),
                        ),
                        Text(
                          (board.mines - board.flags).toString(),
                          style: TextStyle(
                              fontSize: 50 * RelSize(context).pixel()),
                        ),
                        Icon(
                          Icons.square,
                          size: 50 * RelSize(context).pixel(),
                          color: Colors.grey,
                        ),
                        Text(
                          (board.remaining -
                                  (board.flags > 0 ? board.flags : 0))
                              .toString(),
                          style: TextStyle(
                              fontSize: 50 * RelSize(context).pixel()),
                        ),
                      ],
                    ),
                    Column(
                      children: List.generate(
                        height,
                        (x) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            width,
                            (y) => Cell(
                              size: RelSize(context).pixel() *
                                  640 /
                                  (width > height ? width : height),
                              reveal: _reveal,
                              value: board.revealed[x][y],
                              toggleFlag: _toggleFlag,
                              x: x,
                              y: y,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.all(8.0 * RelSize(context).pixel()),
                          child: Ink(
                            height: 100 * RelSize(context).pixel(),
                            width: 300 * RelSize(context).pixel(),
                            color: Colors.grey.shade700,
                            child: InkWell(
                              hoverColor: Colors.grey,
                              mouseCursor: SystemMouseCursors.click,
                              onTap: _reset,
                              child: Center(
                                child: Text(
                                  "Play Again",
                                  style: TextStyle(
                                    fontSize: 60 * RelSize(context).pixel(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.all(8.0 * RelSize(context).pixel()),
                          child: Ink(
                            height: 100 * RelSize(context).pixel(),
                            width: 300 * RelSize(context).pixel(),
                            color: Colors.grey.shade700,
                            child: InkWell(
                              hoverColor: Colors.grey,
                              mouseCursor: SystemMouseCursors.click,
                              onTap: _toggleAI,
                              child: Center(
                                child: Text(
                                  "AI Move",
                                  style: TextStyle(
                                    fontSize: 60 * RelSize(context).pixel(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
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
  final double size;
  const Cell(
      {Key? key,
      required this.reveal,
      required this.value,
      required this.toggleFlag,
      required this.x,
      required this.y,
      required this.size})
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
    -2: null,
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
  }

  @override
  Widget build(BuildContext context) {
    double dim = widget.size * 3 / 4;
    for (int i = 1; i < 9; i++) {
      icons[i] = Text(
        i.toString(),
        style: TextStyle(
          fontSize: dim,
        ),
      );
    }
    icons[-3] = Icon(
      Icons.flag,
      size: dim,
    );
    icons[-1] = Icon(
      Icons.circle,
      size: dim,
    );
    return GestureDetector(
      onLongPress: _toggleFlag,
      onSecondaryTap: _toggleFlag,
      child: Padding(
        padding: EdgeInsets.all(RelSize(context).pixel()),
        child: Ink(
          color: colors[widget.value],
          width: widget.size,
          height: widget.size,
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
