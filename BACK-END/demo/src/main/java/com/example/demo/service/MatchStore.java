package com.example.demo.service;

import com.example.demo.model.Match;

import java.util.Optional;

public interface MatchStore {

    Match save(Match match);

    Optional<Match> findById(Long id);
}
