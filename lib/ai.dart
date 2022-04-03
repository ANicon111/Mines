import 'package:minesweeper/board.dart';

class AI {
  List<List<double>> moves = [];
  Board board;
  final double safetyCoefficient = 0.608;

  void _processBoard() {
    for (int x = 0; x < board.height; x++) {
      for (int y = 0; y < board.width; y++) {
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
                  if (unflaggedMines == 0 ||
                      unflaggedMines == undiscoveredNeighbours) {
                    moves[x + i][y + j] =
                        unflaggedMines / undiscoveredNeighbours;
                  } else {
                    double min = (unflaggedMines / undiscoveredNeighbours) >
                            moves[x + i][y + j]
                        ? moves[x + i][y + j]
                        : (unflaggedMines / undiscoveredNeighbours);
                    double max = (unflaggedMines / undiscoveredNeighbours) +
                        moves[x + i][y + j] -
                        min;
                    moves[x + i][y + j] = (max * safetyCoefficient +
                            min * (1 - safetyCoefficient)) /
                        2;
                  }
                }
                if (moves[x + i][y + j] == 1) {
                  board.revealed[x + i][y + j] = -3;
                }
              }
            }
          }
        }
      }
    }
  }

  AI(this.board) {
    moves = List.generate(
        board.height,
        ((i) => List.generate(
            board.width, ((j) => board.revealed[i][j] == -2 ? 0.99 : 1))));
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
        if (moves[i][j] < moves[bestX][bestY]) {
          bestX = i;
          bestY = j;
        }
      }
    }
    return Coords(bestX, bestY);
  }
}
