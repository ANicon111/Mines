#include "bits/stdc++.h"

struct Coords
{
    int x;
    int y;
    Coords(int x, int y)
    {
        this->x = x;
        this->y = y;
    }
};

struct Board
{
    int height = 0, width = 0, mines = 0, flags = 0, remaining = 0;
    bool firstMove = true;
    bool **board = nullptr;
    int **revealed = nullptr;

    Board();

    Board(int width, int height, int mines)
    {
        this->width = width;
        this->height = height;
        this->mines = mines;
        remaining = width * height;
        board = new bool *[height];
        for (int i = 0; i < height; i++)
            board[i] = new bool[width];
        revealed = new int *[height];
        for (int i = 0; i < height; i++)
        {
            revealed[i] = new int[width];
            for (int j = 0; j < width; j++)
                revealed[i][j] = -2;
        }
    }
} board;

bool isPosValid(int x, int y)
{
    return x >= 0 && x < board.height && y >= 0 && y < board.width;
}

void reset(int safeX = -2, int safeY = -2)
{
    board.firstMove = true;
    int pos = 0;
    int safePlaces = 10;
    if (safeX == 0 || safeX == board.width - 1)
        safePlaces -= 3;
    if (safeY == 0 || safeY == board.height - 1)
        safePlaces -= 3;
    if ((safeX == 0 && safeY == 0) ||
        (safeX == board.width - 1 && safeY == board.height - 1))
        safePlaces++;
    int mines = board.mines;
    int nonMines = board.height * board.width - mines;
    while (mines + nonMines > 0)
    {
        bool safePlace = false;
        int val = std::rand() % (mines + nonMines);
        for (int i = -1; i <= 1; i++)
        {
            for (int j = -1; j <= 1; j++)
            {
                if (isPosValid(safeX + i, safeY + j) &&
                    pos == (safeY + j) * board.height + safeX + i)
                {
                    nonMines--;
                    board.board[pos % board.height][pos / board.height] = false;
                    safePlace = true;
                    safePlaces--;
                }
            }
        }
        if (!safePlace)
        {
            if (val < mines || nonMines < safePlaces)
            {
                mines--;
                board.board[pos % board.height][pos / board.height] = true;
            }
            else
            {
                nonMines--;
                board.board[pos % board.height][pos / board.height] = false;
            }
        }
        pos++;
    }
}

int val(int x, int y)
{
    if (!isPosValid(x, y))
        return -2;
    int val = 0;
    if (board.board[x][y])
        return -1;
    for (int i = -1; i <= 1; i++)
    {
        for (int j = -1; j <= 1; j++)
        {
            if (isPosValid(x + i, y + j) && board.board[x + i][y + j])
            {
                val++;
            }
        }
    }
    return val;
}

int val(int x, int y)
{
    int value = val(x, y);
    if (board.revealed[x][y] == -2)
        board.remaining--;
    board.revealed[x][y] = value;
    board.firstMove = false;
    return value;
}

// AI
double **moves = nullptr;
double unknownK = 0.099;
double closenessK = 0.9;

void update(int x, int y)
{
    if (board.revealed[x][y] == -2)
    {
        for (int i = -1; i <= 1; i++)
        {
            for (int j = -1; j <= 1; j++)
            {
                if (isPosValid(x + i, y + j))
                {
                    if (moves[x + i][y + j] != 1 && moves[x + i][y + j] != 0)
                    {
                        moves[x + i][y + j] *= closenessK;
                    }
                }
            }
        }
    }
    if (board.revealed[x][y] >= 0)
    {
        int undiscoveredNeighbours = 0;
        int unflaggedMines = board.revealed[x][y];
        for (int i = -1; i <= 1; i++)
        {
            for (int j = -1; j <= 1; j++)
            {
                if (isPosValid(x + i, y + j))
                {
                    if (board.revealed[x + i][y + j] == -2)
                    {
                        undiscoveredNeighbours++;
                    }
                    else if (board.revealed[x + i][y + j] == -3)
                    {
                        unflaggedMines--;
                    }
                }
            }
        }
        for (int i = -1; i <= 1; i++)
        {
            for (int j = -1; j <= 1; j++)
            {
                if (isPosValid(x + i, y + j) &&
                    board.revealed[x + i][y + j] == -2)
                {
                    if (moves[x + i][y + j] != 1 && moves[x + i][y + j] != 0)
                    {
                        if (unflaggedMines == 0)
                        {
                            moves[x + i][y + j] = 1;
                        }
                        else if (moves[x + i][y + j] == unknownK)
                        {
                            moves[x + i][y + j] = 1 - (unflaggedMines / undiscoveredNeighbours) * (((double)(std::rand() % 100)) / 5000 + 0.99);
                        }
                        else
                        {
                            moves[x + i][y + j] *= (1 - (unflaggedMines / undiscoveredNeighbours)) * (((double)(std::rand() % 100)) / 5000 + 0.99);
                        }
                    }
                    if (moves[x + i][y + j] == 0 &&
                        board.revealed[x + i][y + j] != -3)
                    {
                        board.revealed[x + i][y + j] = -3;
                        for (int i = -1; i <= 1; i++)
                        {
                            for (int j = -1; j <= 1; j++)
                            {
                                if (isPosValid(x + i, y + j) && board.revealed[x + i][y + j] >= 0)
                                    update(x + i, y + j);
                            }
                        }
                        board.flags++;
                    }
                }
            }
        }
    }
}

void processBoard()
{
    for (int x = 0; x < board.height; x++)
    {
        for (int y = 0; y < board.width; y++)
        {
            if (board.revealed[x][y] >= 0)
                update(x, y);
        }
    }
}

void initAI()
{
    moves = new double *[board.width];
    for (int i = 0; i < board.height; i++)
    {
        moves[i] = new double[board.width];
        for (int j = 0; j < board.width; j++)
            moves[i][j] = -2;
    }
    processBoard();
}

Coords getBestMove()
{
    if (board.firstMove)
    {
        return Coords((board.height - 1) / 2, (board.width - 1) / 2);
    }
    int bestX = 0;
    int bestY = 0;
    for (int i = 0; i < board.height; i++)
    {
        for (int j = 0; j < board.width; j++)
        {
            if (moves[i][j] > moves[bestX][bestY])
            {
                bestX = i;
                bestY = j;
            }
        }
    }
    return Coords(bestX, bestY);
}

int main()
{
    return 0;
}