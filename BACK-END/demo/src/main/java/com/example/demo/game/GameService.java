package com.example.demo.game;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class GameService {

    private final Map<Long, GameState> games = new ConcurrentHashMap<>();
    private final AtomicLong sequence = new AtomicLong(1);

    private static final int BOARD_SIZE = 10;

    public GameState startNewGame(String playerName) {
        Long id = sequence.getAndIncrement();
        GameState state = new GameState(id, playerName, BOARD_SIZE);

        // aqui depois vamos gerar os navios do inimigo, etc
        // por enquanto o tabuleiro vai todo zerado

        games.put(id, state);
        return state;
    }

    public GameState getGame(Long id) {
        return games.get(id);
    }
}
