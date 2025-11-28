/// Async - HTTP

var _id     = ds_map_find_value(async_load, "id");
var _status = ds_map_find_value(async_load, "status");
var _result = ds_map_find_value(async_load, "result");

show_debug_message("HTTP EVENT -> req_id=" + string(_id) + " status=" + string(_status));

// resposta da /game/start
if (_id == global.req_start) {

    if (_status == 200) {
        show_debug_message("Start OK. Corpo = " + _result);

        var json = json_decode(_result);

        game.match_id   = json[? "id"];
        game.board_size = json[? "boardSize"];

        // se quiser, você pode guardar os tabuleiros depois:
        // game.player_board_backend = json[? "playerBoard"];
        // game.enemy_board_backend  = json[? "enemyBoard"];

        ds_map_destroy(json);

    } else {
        show_debug_message("Erro ao iniciar jogo: status = " + string(_status));
    }
}
