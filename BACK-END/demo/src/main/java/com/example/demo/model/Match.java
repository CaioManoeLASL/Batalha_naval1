package com.example.demo.model;

import com.example.demo.enums.GameStatus;
import com.example.demo.enums.Turn;
import lombok.Data;

@Data
public class Match {

    private Long id;
    private Player player;
    private Board playerBoard;
    private Board enemyBoard;
    private Turn currentTurn;
    private GameStatus status;

    public Match(Long id, String playerName) {
        this.id = id;
        this.player = new Player(1L, playerName);
        this.playerBoard = new Board();
        this.enemyBoard = new Board();
        this.currentTurn = Turn.PLAYER;
        this.status = GameStatus.IN_PROGRESS;
    }
}
