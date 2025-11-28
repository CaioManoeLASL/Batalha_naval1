package com.example.demo.service;

import com.example.demo.model.Match;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class InMemoryMatchStore implements MatchStore {

    private final Map<Long, Match> matches = new ConcurrentHashMap<>();

    @Override
    public Match save(Match match) {
        matches.put(match.getId(), match);
        return match;
    }

    @Override
    public Optional<Match> findById(Long id) {
        return Optional.ofNullable(matches.get(id));
    }
}
