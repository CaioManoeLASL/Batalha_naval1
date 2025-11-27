if (app_state == "game") {
    if (game.placing_ships) {
        game.current_rotation = (game.current_rotation + 3) mod 4;
    }
}
