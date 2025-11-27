function Board_Draw(_board, _offx, _offy, _is_player, _label, _cell_size, _hover, _preview) {

    var grid_size = _board.grid_size;

    draw_set_font(fnt_board);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var has_preview = (!is_undefined(_preview) && array_length(_preview.cells) > 0);

    for (var ix = 0; ix < grid_size; ix++) {
        for (var iy = 0; iy < grid_size; iy++) {

            var x1 = _offx + ix * _cell_size;
            var y1 = _offy + iy * _cell_size;
            var x2 = x1 + _cell_size - 1;
            var y2 = y1 + _cell_size - 1;

            var v  = _board.get_cell(_board, ix, iy);
            var cx = x1 + _cell_size / 2;
            var cy = y1 + _cell_size / 2;

            // ==== 1) ver se esta celula esta no preview de navio ====
            var in_preview    = false;
            var preview_valid = false;

            if (_is_player && has_preview) {
                preview_valid = _preview.valid;
                for (var p = 0; p < array_length(_preview.cells); p++) {
                    var pc = _preview.cells[p];
                    if (pc[0] == ix && pc[1] == iy) {
                        in_preview = true;
                        break;
                    }
                }
            }

            // ==== 2) Fundo: agua normal OU preview (verde/vermelho) ====
            if (in_preview) {
                if (preview_valid) {
                    draw_set_color(make_color_rgb(0, 200, 0)); // verde preview
                } else {
                    draw_set_color(make_color_rgb(200, 0, 0)); // vermelho preview
                }
            } else {
                draw_set_color(make_color_rgb(0, 70, 150)); // agua
            }
            draw_rectangle(x1, y1, x2, y2, true);

            // ==== 3) Conteudo (navio/acerto/erro) – só se NÃO estiver em preview ====
            if (!in_preview) {
                if (v == 1 && _is_player) {
                    draw_set_color(make_color_rgb(80, 80, 80));
                    draw_rectangle(x1 + 6, y1 + 6, x2 - 6, y2 - 6, true);
                }
                else if (v == 2) {
                    draw_set_color(make_color_rgb(150, 0, 0));
                    draw_rectangle(x1 + 8, y1 + 8, x2 - 8, y2 - 8, true);
                }
                else if (v == 3) {
                    draw_set_color(make_color_rgb(0, 150, 150));
                    draw_rectangle(x1 + 8, y1 + 8, x2 - 8, y2 - 8, true);
                }
            }

            // ==== 4) Borda base ====
            draw_set_color(c_white);
            draw_rectangle(x1, y1, x2, y2, false);

            // ==== 5) Hover da célula principal (borda verde) ====
            if (_hover.board != "") {
                var hover_player = (_hover.board == "player" && _is_player);
                var hover_enemy  = (_hover.board == "enemy"  && !_is_player);

                if (hover_player || hover_enemy) {
                    if (ix == _hover.x && iy == _hover.y) {
                        draw_set_alpha(0.4);
                        draw_set_color(c_lime);
                        draw_rectangle(x1, y1, x2, y2, false);
                        draw_set_alpha(1);
                    }
                }
            }

            // ==== 6) contorno extra (navio/acerto/erro) – só se não estiver em preview ====
            if (!in_preview) {
                if (v == 1 && _is_player) {
                    draw_set_color(c_ltgray);
                    draw_rectangle(x1 + 2, y1 + 2, x2 - 2, y2 - 2, false);
                }
                else if (v == 2) {
                    draw_set_color(c_red);
                    draw_rectangle(x1 + 2, y1 + 2, x2 - 2, y2 - 2, false);
                }
                else if (v == 3) {
                    draw_set_color(c_aqua);
                    draw_rectangle(x1 + 2, y1 + 2, x2 - 2, y2 - 2, false);
                }
            }

            // ==== 7) debug opcional ====
            if (keyboard_check(vk_control)) {
                draw_set_color(c_yellow);
                draw_text(x1 + 6, y1 + 6, string(v));
            }
        }
    }

    // coordenadas e título
    draw_set_color(c_white);
    for (var ix2 = 0; ix2 < grid_size; ix2++) {
        draw_text(_offx + ix2 * _cell_size + _cell_size / 2, _offy - 20, chr(ord("A") + ix2));
    }
    for (var iy2 = 0; iy2 < grid_size; iy2++) {
        draw_text(_offx - 20, _offy + iy2 * _cell_size + _cell_size / 2, string(iy2 + 1));
    }

    draw_text(_offx + grid_size * _cell_size / 2, _offy - 44, _label);
}
