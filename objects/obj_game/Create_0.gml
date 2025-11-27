app_state = "menu";
menu = Menu_Create();
randomize();
game = BattleshipGame_Create();

// TESTE SIMPLES: ping no backend
var url = "http://127.0.0.1:8080/ping";
global.req_ping = http_get(url);

show_debug_message("URL teste: " + url);
show_debug_message("req_ping id = " + string(global.req_ping));
