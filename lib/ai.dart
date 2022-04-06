import 'dart:math';

import 'package:minesweeper/board.dart';

class AI {
  List<List<double>> moves = [];
  Board board;
  double unknownK = 0.099;
  final closenessK = 0.9;

  void _update(int x, int y) {
    if (board.revealed[x][y] == -2) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (board.isPosValid(x + i, y + j)) {
            if (moves[x + i][y + j] != 1 && moves[x + i][y + j] != 0) {
              moves[x + i][y + j] *= closenessK;
            }
          }
        }
      }
    }
    if (board.revealed[x][y] >= 0) {
      int undiscoveredNeighbours = 0;
      int unflaggedMines = board.revealed[x][y];
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (board.isPosValid(x + i, y + j)) {
            if (board.revealed[x + i][y + j] == -2) {
              undiscoveredNeighbours++;
            } else if (board.revealed[x + i][y + j] == -3) {
              unflaggedMines--;
            }
          }
        }
      }
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (board.isPosValid(x + i, y + j) &&
              board.revealed[x + i][y + j] == -2) {
            if (moves[x + i][y + j] != 1 && moves[x + i][y + j] != 0) {
              if (unflaggedMines == 0) {
                moves[x + i][y + j] = 1;
              } else if (moves[x + i][y + j] == unknownK) {
                moves[x + i][y + j] =
                    1 - (unflaggedMines / undiscoveredNeighbours);
              } else {
                moves[x + i][y + j] *=
                    (1 - (unflaggedMines / undiscoveredNeighbours)) *
                        (Random().nextDouble() / 50 + 0.99);
              }
            }
            if (moves[x + i][y + j] == 0 &&
                board.revealed[x + i][y + j] != -3) {
              board.revealed[x + i][y + j] = -3;
              for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                  if (board.isPosValid(x + i, y + j) &&
                      board.revealed[x + i][y + j] >= 0) _update(x + i, y + j);
                }
              }
              board.flags++;
            }
          }
        }
      }
    }
  }

  void _processBoard() {
    for (int x = 0; x < board.height; x++) {
      for (int y = 0; y < board.width; y++) {
        if (board.revealed[x][y] >= 0) _update(x, y);
      }
    }
  }

  AI(this.board) {
    moves = List.generate(
        board.height,
        ((i) => List.generate(
            board.width, ((j) => board.revealed[i][j] == -2 ? unknownK : 0))));
    _processBoard();
  }

  Coords getBestMove() {
    if (board.firstMove) {
      return Coords((board.height - 1) ~/ 2, (board.width - 1) ~/ 2);
    }
    int bestX = 0;
    int bestY = 0;
    for (int i = 0; i < board.height; i++) {
      for (int j = 0; j < board.width; j++) {
        if (moves[i][j] > moves[bestX][bestY]) {
          bestX = i;
          bestY = j;
        }
      }
    }
    return Coords(bestX, bestY);
  }
}
