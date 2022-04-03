import 'dart:math';

class Coords {
  final int x;
  final int y;
  Coords(this.x, this.y);
}

class Board {
  int height = 0, width = 0, mines = 0;
  bool firstMove = true;
  List<List<bool>> _board = [];
  List<List<int>> revealed = [];

  bool isPosValid(int x, int y) {
    return x >= 0 && x < height && y >= 0 && y < width;
  }

  Board(this.width, this.height, this.mines) {
    _board = List.generate(height, (_) => List.generate(width, (_) => false));
    revealed = List.generate(height, (_) => List.generate(width, (_) => -2));
  }

  void reset([int safeX = -2, int safeY = -2]) {
    firstMove = true;
    Random randomCoord = Random();
    int pos = 0;
    int safePlaces = 10;
    if (safeX == 0 || safeX == width - 1) safePlaces -= 3;
    if (safeY == 0 || safeY == height - 1) safePlaces -= 3;
    if ((safeX == 0 && safeY == 0) ||
        (safeX == width - 1 && safeY == height - 1)) safePlaces++;
    int mines = this.mines;
    int nonMines = height * width - mines;
    while (mines + nonMines > 0) {
      bool safePlace = false;
      int val = randomCoord.nextInt(mines + nonMines);
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (isPosValid(safeX + i, safeX + j) &&
              pos == (safeY + j) * height + safeX + i) {
            nonMines--;
            _board[pos % height][pos ~/ height] = false;
            safePlace = true;
            safePlaces--;
          }
        }
      }
      if (!safePlace) {
        if (val < mines || nonMines < safePlaces) {
          mines--;
          _board[pos % height][pos ~/ height] = true;
        } else {
          nonMines--;
          _board[pos % height][pos ~/ height] = false;
        }
      }
      pos++;
    }
  }

  int _val(int x, int y) {
    if (!isPosValid(x, y)) return -2;
    int val = 0;
    if (_board[x][y]) return -1;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (isPosValid(x + i, y + j) && _board[x + i][y + j]) {
          val++;
        }
      }
    }
    return val;
  }

  int val(int x, int y) {
    int val = _val(x, y);
    revealed[x][y] = val;
    firstMove = false;
    return val;
  }
}
