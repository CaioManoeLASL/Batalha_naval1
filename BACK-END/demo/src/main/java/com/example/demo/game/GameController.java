package com.example.demo.game;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/game")
public class GameController {

    private final GameService gameService;

    public GameController(GameService gameService) {
        this.gameService = gameService;
    }

    // POST /game/start?playerName=Wagner
    @GetMapping("/start")
    public GameState startGame(@RequestParam String playerName) {
        return gameService.startNewGame(playerName);
    }

    // GET /game/state/1
    @GetMapping("/state/{id}")
    public GameState getState(@PathVariable Long id) {
        GameState state = gameService.getGame(id);
        if (state == null) {
            throw new RuntimeException("Partida nao encontrada: " + id);
        }
        return state;
    }
}
