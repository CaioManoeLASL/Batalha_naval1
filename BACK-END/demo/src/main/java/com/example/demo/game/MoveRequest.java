package com.example.demo.game;

public class MoveRequest {

    private int x;
    private int y;

    public MoveRequest() {
    }

    public MoveRequest(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public int getX() {
        return x;
    }

    public void setX(int x) {
        this.x = x;
    }

    public int getY() {
        return y;
    }

    public void setY(int y) {
        this.y = y;
    }
}
