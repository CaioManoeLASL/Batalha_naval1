var request_id = ds_map_find_value(async_load, "id");
var status     = ds_map_find_value(async_load, "status");
var body       = ds_map_find_value(async_load, "result");

show_debug_message("HTTP resp id=" + string(request_id) + " status=" + string(status));
show_debug_message("Body: " + string(body));

// Se for a resposta do /ping
if (request_id == global.req_ping) {
    if (status == 200) {
        show_debug_message("PING OK do backend!");
    } else {
        show_debug_message("PING falhou, status = " + string(status));
    }
}
