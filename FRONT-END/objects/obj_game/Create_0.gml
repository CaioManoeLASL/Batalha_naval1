app_state = "menu";
menu      = Menu_Create();
randomize();

game = BattleshipGame_Create();

// nome do jogador (sem url_encode)
var player_name = "Wagner";

// se um dia tiver espaço, pode usar:
// player_name = string_replace_all(player_name, " ", "%20");

var url = "http://127.0.0.1:8080/game/start?playerName=" + player_name;
show_debug_message("Chamando: " + url);

// cabeçalhos (por enquanto vazio)
var headers = ds_map_create();

// AQUI É O PULO DO GATO: usar http_get (constante correta)
global.req_start = http_request(url, http_get, "", headers);

// já pode destruir o mapa de headers, o GM faz uma cópia interna
ds_map_destroy(headers);

// por segurança, inicializa o match_id
game.match_id = -1;
