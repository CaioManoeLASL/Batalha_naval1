app_state = "menu";
menu      = Menu_Create();
randomize();

game = BattleshipGame_Create();

// TESTE BACKEND SIMPLES
var player_name = "Wagner";

// sem url_encode, sem scr_url_encode, só string normal
var url = "http://127.0.0.1:8080/ping?playerName=" + player_name;

// guarda o id da requisição
global.req_ping = http_get(url);

show_debug_message("REQ_PING = " + string(global.req_ping));
