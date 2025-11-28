/// Async - HTTP do obj_game

// pega os dados básicos da resposta
var req_id = async_load[? "id"];      // id da requisição
var st     = async_load[? "status"];  // 0 = terminou, <0 = erro de rede
var body   = async_load[? "result"];  // texto vindo do servidor (se tiver)

show_debug_message("HTTP EVENT -> req_id=" + string(req_id) + " status=" + string(st));

// só queremos tratar a resposta do /ping
if (req_id != global.req_ping) {
    exit;
}

// se deu erro de rede
if (st < 0) {
    show_debug_message("ERRO DE REDE. status = " + string(st));
    exit;
}

// se ainda está transferindo (download de arquivo grande; não é nosso caso)
if (st == 1) {
    show_debug_message("Baixando... (status=1)");
    exit;
}

// se chegou aqui, st == 0  → requisição terminou
// agora pegamos o código HTTP de verdade
var http_code = async_load[? "http_status"]; // 200, 404, etc. (quando disponível)

show_debug_message("HTTP terminou. http_status = " + string(http_code));
show_debug_message("Corpo = " + string(body));
