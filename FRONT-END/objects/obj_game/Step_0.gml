if (app_state == "menu") {

    var cfg = Menu_Update(menu);

    if (is_struct(cfg)) {
        game      = BattleshipGame_Create(cfg);
        app_state = "game";
    }

} else if (app_state == "game") {

    BattleshipGame_Update(game);
}