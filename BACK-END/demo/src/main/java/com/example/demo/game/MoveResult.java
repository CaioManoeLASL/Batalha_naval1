package com.example.demo.game;

public class MoveResult {

    private boolean hit;          // acertou navio?
    private boolean alreadyTried; // célula já tinha sido atacada?
    private boolean gameOver;     // acabou o jogo?
    private int[][] enemyBoard;   // visão atual do tabuleiro do inimigo

    public MoveResult() {
    }

    public MoveResult(boolean hit, boolean alreadyTried, boolean gameOver, int[][] enemyBoard) {
        this.hit = hit;
        this.alreadyTried = alreadyTried;
        this.gameOver = gameOver;
        this.enemyBoard = enemyBoard;
    }

    public boolean isHit() {
        return hit;
    }

    public void setHit(boolean hit) {
        this.hit = hit;
    }

    public boolean isAlreadyTried() {
        return alreadyTried;
    }

    public void setAlreadyTried(boolean alreadyTried) {
        this.alreadyTried = alreadyTried;
    }

    public boolean isGameOver() {
        return gameOver;
    }

    public void setGameOver(boolean gameOver) {
        this.gameOver = gameOver;
    }

    public int[][] getEnemyBoard() {
        return enemyBoard;
    }

    public void setEnemyBoard(int[][] enemyBoard) {
        this.enemyBoard = enemyBoard;
    }
}
