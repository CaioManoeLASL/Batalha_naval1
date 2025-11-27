package com.example.demo.game;

public class GameState {

    private Long id;
    private String playerName;

    // 10x10 simples so pra teste
    private int[][] playerBoard;
    private int[][] enemyBoard;

    private boolean playerTurn;
    private boolean gameOver;
    private String winner; // "player", "enemy" ou null

    public GameState(Long id, String playerName, int size) {
        this.id = id;
        this.playerName = playerName;
        this.playerBoard = new int[size][size];
        this.enemyBoard  = new int[size][size];
        this.playerTurn  = true;
        this.gameOver    = false;
        this.winner      = null;
    }

    public Long getId() {
        return id;
    }

    public String getPlayerName() {
        return playerName;
    }

    public int[][] getPlayerBoard() {
        return playerBoard;
    }

    public int[][] getEnemyBoard() {
        return enemyBoard;
    }

    public boolean isPlayerTurn() {
        return playerTurn;
    }

    public void setPlayerTurn(boolean playerTurn) {
        this.playerTurn = playerTurn;
    }

    public boolean isGameOver() {
        return gameOver;
    }

    public void setGameOver(boolean gameOver) {
        this.gameOver = gameOver;
    }

    public String getWinner() {
        return winner;
    }

    public void setWinner(String winner) {
        this.winner = winner;
    }
}
