package com.example.demo.game;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class GameController {

    private final com.example.demo.game.GameService gameService;

    // injeção via construtor
    public GameController(com.example.demo.game.GameService gameService) {
        this.gameService = gameService;
    }

    @GetMapping("/game/start")
    public GameState start(@RequestParam String playerName) {
        return gameService.startNewGame(playerName);
    }

    @PostMapping("/game/{id}/move")
    public ResponseEntity<MoveResult> move(@PathVariable Long id,
                                           @RequestBody MoveRequest request) {

        MoveResult result = gameService.playerMove(id, request.getX(), request.getY());
        if (result == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        return ResponseEntity.ok(result);
    }
}
