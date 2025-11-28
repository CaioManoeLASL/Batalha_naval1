package com.example.demo.game;

public class GameState {

    private Long id;
    private String playerName;

    private int boardSize;

    // 0 = vazio, 1 = navio, 2 = tiro na água, 3 = tiro que acertou
    private int[][] enemyBoard;
    private int remainingShipCells;

    public GameState(Long id, String playerName, int boardSize) {
        this.id = id;
        this.playerName = playerName;
        this.boardSize = boardSize;

        this.enemyBoard = new int[boardSize][boardSize];

        // EXEMPLO: 1 navio simples de 3 células na linha 1 (para testar)
        enemyBoard[1][1] = 1;
        enemyBoard[1][2] = 1;
        enemyBoard[1][3] = 1;
        remainingShipCells = 3;
    }

    public Long getId() {
        return id;
    }

    public String getPlayerName() {
        return playerName;
    }

    public int getBoardSize() {
        return boardSize;
    }

    public int[][] getEnemyBoard() {
        return enemyBoard;
    }

    public MoveResult shootAtEnemy(int x, int y) {
        // valida coordenadas
        if (x < 0 || x >= boardSize || y < 0 || y >= boardSize) {
            // coordenada inválida -> considera como já tentado
            return new MoveResult(false, true, remainingShipCells == 0, enemyBoard);
        }

        int cell = enemyBoard[x][y];

        // já tinha tiro aqui
        if (cell == 2 || cell == 3) {
            return new MoveResult(false, true, remainingShipCells == 0, enemyBoard);
        }

        boolean hit = false;

        if (cell == 1) {
            // acertou navio
            enemyBoard[x][y] = 3;
            hit = true;
            remainingShipCells--;
        } else if (cell == 0) {
            // água
            enemyBoard[x][y] = 2;
        }

        boolean gameOver = (remainingShipCells == 0);

        return new MoveResult(hit, false, gameOver, enemyBoard);
    }
}
