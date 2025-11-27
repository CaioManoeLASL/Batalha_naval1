function Menu_Create() {

    var _menu = {
        selected_difficulty : "medio", // "facil", "medio" ou "dificil"
        slow_ai             : true,    // regra: IA pensa devagar (2–3 s)
        ready_to_start      : false
    };

    return _menu;
}

/// Retorna um config struct quando o jogador clicar em "Iniciar"
function Menu_Update(_menu) {

    var mx = mouse_x;
    var my = mouse_y;

    var btn_w = 220;
    var btn_h = 40;
    var cx    = room_width / 2;
    var spacing = 8;

    var panel_w = 480;
    var panel_h = 420;
    var px1 = room_width / 2 - panel_w / 2;
    var py1 = room_height / 2 - panel_h / 2;

    var y_diff_base = py1 + 120;
    var y_rule      = y_diff_base + 3 * (btn_h + spacing) + 10;
    var y_start     = y_rule + 60;

    // retangulos de clique (iguais ao desenho)
    var easy_rect   = [cx - btn_w/2, y_diff_base + 0 * (btn_h + spacing), cx + btn_w/2, y_diff_base + 0 * (btn_h + spacing) + btn_h];
    var med_rect    = [cx - btn_w/2, y_diff_base + 1 * (btn_h + spacing), cx + btn_w/2, y_diff_base + 1 * (btn_h + spacing) + btn_h];
    var hard_rect   = [cx - btn_w/2, y_diff_base + 2 * (btn_h + spacing), cx + btn_w/2, y_diff_base + 2 * (btn_h + spacing) + btn_h];

    var rule_rect   = [cx - btn_w/2, y_rule, cx + btn_w/2, y_rule + btn_h];
    var start_rect  = [cx - btn_w/2, y_start, cx + btn_w/2, y_start + btn_h];

    if (mouse_check_button_pressed(mb_left)) {

        if (mx >= easy_rect[0] && mx <= easy_rect[2] &&
            my >= easy_rect[1] && my <= easy_rect[3]) {
            _menu.selected_difficulty = "facil";
        }

        if (mx >= med_rect[0] && mx <= med_rect[2] &&
            my >= med_rect[1] && my <= med_rect[3]) {
            _menu.selected_difficulty = "medio";
        }

        if (mx >= hard_rect[0] && mx <= hard_rect[2] &&
            my >= hard_rect[1] && my <= hard_rect[3]) {
            _menu.selected_difficulty = "dificil";
        }

        if (mx >= rule_rect[0] && mx <= rule_rect[2] &&
            my >= rule_rect[1] && my <= rule_rect[3]) {
            _menu.slow_ai = !_menu.slow_ai;
        }

        if (mx >= start_rect[0] && mx <= start_rect[2] &&
            my >= start_rect[1] && my <= start_rect[3]) {

            _menu.ready_to_start = true;

            var cfg = {
                difficulty  : _menu.selected_difficulty,
                ai_delay_min: _menu.slow_ai ? 2 : 0,
                ai_delay_max: _menu.slow_ai ? 3 : 0
            };

            return cfg;
        }
    }

    return undefined;
}


function Menu_Draw(_menu) {

    draw_clear(make_color_rgb(0, 10, 30));

    draw_set_font(fnt_board);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // fundo
    draw_set_color(make_color_rgb(5, 10, 40));
    draw_rectangle(0, 0, room_width, room_height / 2, true);
    draw_set_color(make_color_rgb(0, 0, 20));
    draw_rectangle(0, room_height / 2, room_width, room_height, true);

    // painel central (maior)
    var panel_w = 480;
    var panel_h = 420; // aumentei para caber tudo
    var px1 = room_width / 2 - panel_w / 2;
    var py1 = room_height / 2 - panel_h / 2;
    var px2 = px1 + panel_w;
    var py2 = py1 + panel_h;

    draw_set_color(make_color_rgb(10, 20, 60));
    draw_roundrect(px1, py1, px2, py2, false);
    draw_set_color(make_color_rgb(15, 30, 90));
    draw_roundrect(px1 + 2, py1 + 2, px2 - 2, py2 - 2, true);

    // textos
    draw_set_color(c_white);
    draw_text(room_width / 2, py1 + 40, "BATALHA NAVAL");

    draw_set_color(c_ltgray);
    draw_text(room_width / 2, py1 + 80, "Selecione a dificuldade e as regras");

    var btn_w = 220;
    var btn_h = 40;
    var cx    = room_width / 2;
    var spacing = 8;

    var y_diff_base = py1 + 120;
    var y_rule      = y_diff_base + 3 * (btn_h + spacing) + 10;
    var y_start     = y_rule + 60;

    // botoes dificuldade
    var labels = ["Facil", "Medio", "Dificil"];
    var diffs  = ["facil", "medio", "dificil"];

    for (var i = 0; i < 3; i++) {

        var y1 = y_diff_base + i * (btn_h + spacing);
        var y2 = y1 + btn_h;
        var x1 = cx - btn_w / 2;
        var x2 = cx + btn_w / 2;

        var is_selected = (_menu.selected_difficulty == diffs[i]);

        draw_set_color(is_selected ? make_color_rgb(20, 140, 60) : make_color_rgb(40, 40, 80));
        draw_roundrect(x1, y1, x2, y2, true);

        draw_set_color(is_selected ? c_lime : c_gray);
        draw_roundrect(x1, y1, x2, y2, false);

        draw_set_color(c_white);
        draw_text(cx, y1 + btn_h / 2, labels[i]);
    }

    // regra IA lenta
    var x1r = cx - btn_w/2;
    var x2r = cx + btn_w/2;
    var y1r = y_rule;
    var y2r = y1r + btn_h;

    draw_set_color(_menu.slow_ai ? make_color_rgb(20, 100, 40) : make_color_rgb(60, 60, 80));
    draw_roundrect(x1r, y1r, x2r, y2r, true);

    draw_set_color(_menu.slow_ai ? c_lime : c_gray);
    draw_roundrect(x1r, y1r, x2r, y2r, false);

    draw_set_color(c_white);
    var txt_rule = _menu.slow_ai ? "IA lenta (2-3s)" : "IA rapida (0s)";
    draw_text(cx, y1r + btn_h/2, txt_rule);

    // botao iniciar
    var x1s = cx - btn_w/2;
    var x2s = cx + btn_w/2;
    var y1s = y_start;
    var y2s = y1s + btn_h;

    draw_set_color(make_color_rgb(200, 180, 40));
    draw_roundrect(x1s, y1s, x2s, y2s, true);

    draw_set_color(c_yellow);
    draw_roundrect(x1s, y1s, x2s, y2s, false);

    draw_set_color(c_black);
    draw_text(cx, y1s + btn_h/2, "INICIAR");
}
