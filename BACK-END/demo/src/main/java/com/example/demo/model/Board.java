package com.example.demo.model;

import lombok.Data;

@Data
public class Board {

    private int rows = 10;
    private int cols = 10;
    private int[][] cells;

    public Board() {
        // Inicializa tudo como água (0)
        this.cells = new int[rows][cols];
    }

    public int getCell(int x, int y) {
        return cells[x][y];
    }

    public void setCell(int x, int y, int value) {
        cells[x][y] = value;
    }
}
