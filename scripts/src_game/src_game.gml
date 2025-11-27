/// scr_game.gml

function BattleshipGame_Create(_config) {

    // config vindo do menu ou default
    var cfg;
    if (is_undefined(_config)) {
        cfg = {
            difficulty  : "medio",
            ai_delay_min: 2,
            ai_delay_max: 3
        };
    } else {
        cfg = _config;
    }

    var grid_size  = 10;
    var cell_size  = 48;
    var offset_y   = 120;
    var player_off = 120;
    var enemy_off  = player_off + grid_size * cell_size + 200;

    var _game = {
        grid_size  : grid_size,
        cell_size  : cell_size,

        offset_y   : offset_y,
        player_off : player_off,
        enemy_off  : enemy_off,

        placing_ships : true,
        max_ships      : 19,
        player_turn    : true,

        player_board : Board_Create(grid_size),
        enemy_board  : Board_Create(grid_size),

        hover : { x : -1, y : -1, board : "" },
        click : { x : -1, y : -1, board : "" },

        ai : undefined,
        difficulty : cfg.difficulty,
        ai_delay_min_sec : cfg.ai_delay_min,
        ai_delay_max_sec : cfg.ai_delay_max,

        player_turns : 0,
        enemy_turns  : 0,
        game_over    : false,
        winner       : "",

        ai_thinking  : false,
        ai_timer     : 0,
        ai_delay     : 0,

        ships_to_place : [
            { kind : "single" },
            { kind : "single" },
            { kind : "single" },
            { kind : "line", len : 2 },
            { kind : "line", len : 2 },
            { kind : "line", len : 3 },
            { kind : "line", len : 4 },
            { kind : "T" }
        ],
        current_ship_index : 0,

        current_rotation : 0, // 0,1,2,3 (90 graus)

        preview : {
            cells : [],
            valid : false
        },
		
        player_cards : [],
        enemy_cards  : [],

        player_card_cooldown : 3, // a cada 3 turnos de ataque, ganha carta
        enemy_card_cooldown  : 3,

        player_skip_next_attack : false,
        enemy_skip_next_attack  : false,

        enemy_last_hit : { x : -1, y : -1 },

        // alvo de carta da IA (para scanner / tridente)
        ai_card_target : undefined,
		
		// scanner
        scanner_cells  : [],
        scanner_active : false,
		scanner_hits   : [],

        // tridente aiming
        trident_aiming       : false,
        trident_card_index   : -1,
		
		heal_aiming       : false,
        heal_card_index   : -1,
		
		scanner_aiming       : false,
        scanner_card_index   : -1,
		
		debug_free_cards : true
    };

    // cria IA de acordo com dificuldade
    switch (_game.difficulty) {
        case "facil":
            _game.ai = AI_Easy_Create();
        break;
        case "medio":
            _game.ai = AI_Medium_Create();
        break;
        case "dificil":
            _game.ai = AI_Hard_Create();
        break;
        default:
            _game.ai = AI_Easy_Create();
        break;
    }

    // frota do inimigo
    _game.enemy_board.place_default_fleet(_game.enemy_board);

    return _game;
}

function BattleshipGame_Update(_game) {

    // reset hover
    _game.hover.x = -1;
    _game.hover.y = -1;
    _game.hover.board = "";

    var mx = mouse_x;
    var my = mouse_y;

    var size      = _game.grid_size;
    var cell_size = _game.cell_size;

    // hover player
    if (mx >= _game.player_off && mx < _game.player_off + size * cell_size &&
        my >= _game.offset_y   && my < _game.offset_y   + size * cell_size) {

        _game.hover.x = floor((mx - _game.player_off) / cell_size);
        _game.hover.y = floor((my - _game.offset_y) / cell_size);
        _game.hover.board = "player";
    }
    // hover enemy
    else if (mx >= _game.enemy_off && mx < _game.enemy_off + size * cell_size &&
             my >= _game.offset_y  && my < _game.offset_y + size * cell_size) {

        _game.hover.x = floor((mx - _game.enemy_off) / cell_size);
        _game.hover.y = floor((my - _game.offset_y) / cell_size);
        _game.hover.board = "enemy";
    }

    // atualiza preview dos navios
    if (_game.placing_ships) {
        BattleshipGame_UpdatePreview(_game);
    } else {
        _game.preview.cells = [];
        _game.preview.valid = false;
    }

    if (_game.game_over) {
        return;
    }
	
	// DEBUG: ganhar todas as cartas sempre que apertar Z
    if (keyboard_check_pressed(ord("Z"))) {
        BattleshipGame_GiveRandomCard(_game, true);
        BattleshipGame_GiveRandomCard(_game, true);
        BattleshipGame_GiveRandomCard(_game, true);
        show_debug_message("DEBUG: ganhou 3 cartas.");
    }

	
	    // Uso de cartas pelo jogador (debug com teclas 1,2,3)
    if (_game.placing_ships == false && _game.player_turn && !_game.game_over) {

        // Cada tecla tenta usar uma carta da mao
        if (keyboard_check_pressed(ord("1"))) {
            BattleshipGame_PlayPlayerCard(_game, 0);
        }
        if (keyboard_check_pressed(ord("2"))) {
            BattleshipGame_PlayPlayerCard(_game, 1);
        }
        if (keyboard_check_pressed(ord("3"))) {
            BattleshipGame_PlayPlayerCard(_game, 2);
        }
    }


    // clique do jogador
    if (mouse_check_button_pressed(mb_left) && _game.hover.board != "") {
        _game.click.x = _game.hover.x;
        _game.click.y = _game.hover.y;
        _game.click.board = _game.hover.board;
		
		        // Se estiver em modo Tridente, usa a carta aqui
        if (_game.trident_aiming) {

            if (_game.click.board != "enemy") {
                show_debug_message("Clique em uma celula do inimigo para usar o Tridente.");
            } else {
                var card = _game.player_cards[_game.trident_card_index];
                card.play(_game, true);

                // sempre gasta a carta
                array_delete(_game.player_cards, _game.trident_card_index, 1);

                _game.trident_aiming     = false;
                _game.trident_card_index = -1;

                // usou carta → acaba turno do jogador
                _game.card_used_this_turn = true;
                _game.player_turn = false;
            }

            return;
        }

		if (_game.heal_aiming) {

            if (_game.click.board != "player") {
                show_debug_message("Clique em um navio seu para usar a cura.");
            } else {
                var card_h = _game.player_cards[_game.heal_card_index];
                card_h.play(_game, true);

                array_delete(_game.player_cards, _game.heal_card_index, 1);

                _game.heal_aiming     = false;
                _game.heal_card_index = -1;

                _game.card_used_this_turn = true;
                _game.player_turn = false;
            }

            return;
        }
		
	// 3) Scanner – NOVO
		if (_game.scanner_aiming) {

			if (_game.click.board != "enemy") {
				show_debug_message("Scanner: clique no tabuleiro do inimigo.");
			} else {
				var card_s = _game.player_cards[_game.scanner_card_index];

				// usa scanner (Card_PlayScanner vai usar _game.click)
				card_s.play(_game, true);

				// gasta a carta
				array_delete(_game.player_cards, _game.scanner_card_index, 1);

				_game.scanner_aiming     = false;
				_game.scanner_card_index = -1;

				_game.card_used_this_turn = true;
				_game.player_turn = false; // usou carta → passa pra IA
			}

			return;
		}

    // se nao esta usando carta, segue fluxo normal
    if (_game.placing_ships) {
        BattleshipGame_HandlePlaceShips(_game);
    } else {
        BattleshipGame_HandlePlayerShot(_game);
    }

        if (_game.placing_ships) {
            BattleshipGame_HandlePlaceShips(_game);
        } else {
            BattleshipGame_HandlePlayerShot(_game);
        }
    }

    // turno da IA (com delay)
    if (!_game.placing_ships && !_game.player_turn && !_game.game_over) {

        if (_game.ai_delay_min_sec <= 0 && _game.ai_delay_max_sec <= 0) {
            BattleshipGame_HandleAI(_game);
        } else {
            if (!_game.ai_thinking) {
                _game.ai_thinking = true;
                _game.ai_timer    = 0;
                _game.ai_delay    = irandom_range(
                    room_speed * _game.ai_delay_min_sec,
                    room_speed * _game.ai_delay_max_sec
                );
            } else {
                _game.ai_timer++;

                if (_game.ai_timer >= _game.ai_delay) {
                    _game.ai_thinking = false;
                    _game.ai_timer    = 0;
                    _game.ai_delay    = 0;

                    BattleshipGame_HandleAI(_game);
                }
            }
        }
    }
}

// preview do navio inteiro baseado no hover e rotacao
function BattleshipGame_UpdatePreview(_game) {

    _game.preview.cells = [];
    _game.preview.valid = false;

    if (!_game.placing_ships) return;
    if (_game.hover.board != "player") return;
    if (_game.current_ship_index >= array_length(_game.ships_to_place)) return;

    var ship = _game.ships_to_place[_game.current_ship_index];
    var gx = _game.hover.x;
    var gy = _game.hover.y;
    var rot = _game.current_rotation;

    var cells = [];
    var valid = false;

    switch (ship.kind) {

        case "single":
            array_push(cells, [gx, gy]);
            valid = (_game.player_board.get_cell(_game.player_board, gx, gy) == 0);
        break;

        case "line":
            var horizontal = ((rot mod 2) == 0);

            if (horizontal) {
                for (var i = 0; i < ship.len; i++) {
                    var tx = gx + i;
                    var ty = gy;
                    array_push(cells, [tx, ty]);
                }
            } else {
                for (var j = 0; j < ship.len; j++) {
                    var vx = gx;
                    var vy = gy + j;
                    array_push(cells, [vx, vy]);
                }
            }

            valid = Board_CanPlaceLine(_game.player_board, gx, gy, ship.len, horizontal);
        break;

        case "T":
            var offsets = Board_GetTOffsets(rot);

            for (var k = 0; k < array_length(offsets); k++) {
                var ox = offsets[k][0];
                var oy = offsets[k][1];
                var px = gx + ox;
                var py = gy + oy;
                array_push(cells, [px, py]);
            }

            valid = Board_CanPlaceT(_game.player_board, gx, gy, rot);
        break;
    }

    _game.preview.cells = cells;
    _game.preview.valid = valid;
}

function BattleshipGame_HandlePlaceShips(_game) {

    if (_game.click.board != "player") return;

    var gx = _game.click.x;
    var gy = _game.click.y;

    if (_game.current_ship_index >= array_length(_game.ships_to_place)) {
        _game.placing_ships = false;
        _game.player_turn   = true;
		_game.card_used_this_turn = false;
        return;
    }

    var ship   = _game.ships_to_place[_game.current_ship_index];
    var placed = false;
    var rot    = _game.current_rotation;

    switch (ship.kind) {

        case "single":
            if (_game.player_board.get_cell(_game.player_board, gx, gy) == 0) {
                _game.player_board.set_cell(_game.player_board, gx, gy, 1);
                placed = true;
            }
        break;

        case "line":
            var horizontal = ((rot mod 2) == 0);
            if (Board_CanPlaceLine(_game.player_board, gx, gy, ship.len, horizontal)) {
                Board_PlaceLine(_game.player_board, gx, gy, ship.len, horizontal);
                placed = true;
            }
        break;

        case "T":
            if (Board_CanPlaceT(_game.player_board, gx, gy, rot)) {
                Board_PlaceT(_game.player_board, gx, gy, rot);
                placed = true;
            }
        break;
    }

    if (placed) {
        _game.current_ship_index++;

        if (_game.current_ship_index >= array_length(_game.ships_to_place)) {
            _game.placing_ships = false;
            _game.player_turn   = true;
            show_debug_message("Todos os navios posicionados! Iniciando a batalha!");
        }
    } else {
        show_debug_message("Posicao invalida para este navio.");
    }
}

function BattleshipGame_HandlePlayerShot(_game) {

    if (!_game.player_turn) return;
	
	// se uma area de scanner ainda estiver ativa,
    // ela desaparece quando voce fizer o proximo tiro
    if (_game.scanner_active) {
        _game.scanner_active = false;
        _game.scanner_cells  = [];
    }


    // se estiver punido pelo Tridente, gasta o turno sem atacar
    if (_game.player_skip_next_attack) {
        _game.player_skip_next_attack = false;
        _game.player_turn = false; // passa para IA
        show_debug_message("Voce perdeu este ataque por usar o Tridente.");
        return;
    }

    if (_game.click.board != "enemy") return;

    var cx = _game.click.x;
    var cy = _game.click.y;

    if (!_game.enemy_board.is_attackable(_game.enemy_board, cx, cy)) {
        return;
    }

    var hit = _game.enemy_board.receive_shot(_game.enemy_board, cx, cy);

    if (hit) {
        show_debug_message("Jogador ACERTOU [" + string(cx) + "," + string(cy) + "]");
    } else {
        show_debug_message("Jogador ERROU [" + string(cx) + "," + string(cy) + "]");
    }

    _game.player_turns++;
    _game.player_card_cooldown--;

    if (_game.player_card_cooldown <= 0) {
        BattleshipGame_GiveRandomCard(_game, true);
        _game.player_card_cooldown = 3;
    }


    if (_game.enemy_board.all_ships_sunk(_game.enemy_board)) {
        _game.game_over = true;
        _game.winner    = "player";
        show_debug_message("Jogador VENCEU!");
        return;
    }

    _game.player_turn   = false;
    _game.ai_thinking   = false;
    _game.ai_timer      = 0;
    _game.ai_delay      = 0;
}

function BattleshipGame_GetTridentCellsFromHover(_game) {

    var cells = [];

    if (_game.hover.board != "enemy") return cells;

    var gx = _game.hover.x;
    var gy = _game.hover.y;

    var size = _game.enemy_board.grid_size;

    var rot        = _game.current_rotation;
    var horizontal = ((rot mod 2) == 0);

    if (horizontal) {
        var arr = [
            [gx - 1, gy],
            [gx,     gy],
            [gx + 1, gy]
        ];
    } else {
        var arr = [
            [gx, gy - 1],
            [gx, gy    ],
            [gx, gy + 1]
        ];
    }

    for (var i = 0; i < array_length(arr); i++) {
        var cx = arr[i][0];
        var cy = arr[i][1];

        if (cx < 0 || cy < 0 || cx >= size || cy >= size) continue;
        array_push(cells, [cx, cy]);
    }

    return cells;
}


function BattleshipGame_HandleAI(_game) {
	
	    // se IA estiver punida pelo Tridente, perde este ataque
    if (_game.enemy_skip_next_attack) {
        _game.enemy_skip_next_attack = false;
        _game.player_turn = true;
        show_debug_message("IA perdeu este ataque por usar o Tridente.");
        return;
    }
	
	// tenta usar carta ANTES de atirar
    if (BattleshipGame_AI_TryUseCard(_game)) {
        // se a carta foi usada, IA nao ataca neste mesmo frame
        _game.player_turn = true;
        return;
    }

    var pos = _game.ai.choose_target(_game.ai, _game.player_board);
    var cx = pos[0];
    var cy = pos[1];

    var hit = _game.player_board.receive_shot(_game.player_board, cx, cy);

    _game.ai.on_result(_game.ai, _game.player_board, cx, cy, hit);

    if (hit) {
        _game.enemy_last_hit.x = cx;
        _game.enemy_last_hit.y = cy;
    }


    _game.enemy_turns++;
	
	_game.enemy_card_cooldown--;

    if (_game.enemy_card_cooldown <= 0) {
        BattleshipGame_GiveRandomCard(_game, false);
        _game.enemy_card_cooldown = 3;
    }


    if (_game.player_board.all_ships_sunk(_game.player_board)) {
        _game.game_over = true;
        _game.winner    = "enemy";
        show_debug_message("IA VENCEU!");
        return;
    }
	
	 // limpa scanner apos a IA agir (1 turno)
    _game.scanner_active = false;
    _game.scanner_cells  = [];

    _game.player_turn = true;


    _game.card_used_this_turn = false;
}

function BattleshipGame_AI_TryUseCard(_game) {

    var cards = _game.enemy_cards;
    var card_count = array_length(cards);
    if (card_count <= 0) return false;

    var diff = _game.difficulty;
    var size = _game.player_board.grid_size;

    // =========================================
    // 1) Achar UMA celula de navio danificado (2)
    //    no tabuleiro da IA (enemy_board)
    // =========================================
    var dmg_found = false;
    var dmg_x = -1;
    var dmg_y = -1;

    var b = _game.enemy_board;
    for (var ix = 0; ix < b.grid_size && !dmg_found; ix++) {
        for (var iy = 0; iy < b.grid_size; iy++) {
            var v = b.get_cell(b, ix, iy);
            if (v == 2) {
                dmg_found = true;
                dmg_x = ix;
                dmg_y = iy;
                break;
            }
        }
    }

    // =========================================
    // 2) Encontrar indices das cartas (scanner, tridente, heal)
    // =========================================
    var scanner_idx = -1;
    var trident_idx = -1;
    var heal_idx    = -1;

    for (var i = 0; i < card_count; i++) {
        var card_id = cards[i].id; // <--- trocado de "id" para "card_id"
        if (card_id == "scanner" && scanner_idx < 0) scanner_idx = i;
        else if (card_id == "trident" && trident_idx < 0) trident_idx = i;
        else if (card_id == "heal"    && heal_idx    < 0) heal_idx    = i;
    }

    // alvo aleatorio no tabuleiro do jogador
    var rnd_x = irandom(size - 1);
    var rnd_y = irandom(size - 1);

    // =========================================
    // FACIL
    // =========================================
    if (diff == "facil") {

        // 5% de chance de usar qualquer carta
        if (irandom(99) >= 5) return false;

        var idx_any  = irandom(card_count - 1);
        var card_any = cards[idx_any];

        if (card_any.id == "scanner" || card_any.id == "trident") {
            _game.ai_card_target = { x : rnd_x, y : rnd_y };
        }
        else if (card_any.id == "heal") {
            if (!dmg_found) return false;
            _game.ai_card_target = { x : dmg_x, y : dmg_y };
        }

        card_any.play(_game, false);
        array_delete(_game.enemy_cards, idx_any, 1);
        return true;
    }

    // =========================================
    // MEDIO – scanner > tridente > cura
    // =========================================
    if (diff == "medio") {

        // 1) Scanner – 40% de chance
        if (scanner_idx >= 0 && irandom(99) < 40) {

            _game.ai_card_target = { x : rnd_x, y : rnd_y };

            var c_sc = cards[scanner_idx];
            c_sc.play(_game, false);
            array_delete(_game.enemy_cards, scanner_idx, 1);
            return true;
        }

        // 2) Tridente – se tiver ultimo acerto
        if (trident_idx >= 0 && _game.enemy_last_hit.x >= 0 && irandom(99) < 40) {

            _game.ai_card_target = {
                x : _game.enemy_last_hit.x,
                y : _game.enemy_last_hit.y
            };

            var c_tr = cards[trident_idx];
            c_tr.play(_game, false);
            array_delete(_game.enemy_cards, trident_idx, 1);
            return true;
        }

        // 3) Cura – se tiver dano
        if (heal_idx >= 0 && dmg_found && irandom(99) < 30) {

            _game.ai_card_target = { x : dmg_x, y : dmg_y };

            var c_he = cards[heal_idx];
            c_he.play(_game, false);
            array_delete(_game.enemy_cards, heal_idx, 1);
            return true;
        }

        return false;
    }

    // =========================================
    // DIFICIL – cura > tridente > scanner
    // =========================================
    if (diff == "dificil") {

        // 1) Cura – 70% se houver navio danificado
        if (heal_idx >= 0 && dmg_found && irandom(99) < 70) {

            _game.ai_card_target = { x : dmg_x, y : dmg_y };

            var c_he2 = cards[heal_idx];
            c_he2.play(_game, false);
            array_delete(_game.enemy_cards, heal_idx, 1);
            return true;
        }

        // 2) Tridente – se tem ultimo acerto
        if (trident_idx >= 0 && _game.enemy_last_hit.x >= 0) {

            _game.ai_card_target = {
                x : _game.enemy_last_hit.x,
                y : _game.enemy_last_hit.y
            };

            var c_tr2 = cards[trident_idx];
            c_tr2.play(_game, false);
            array_delete(_game.enemy_cards, trident_idx, 1);
            return true;
        }

        // 3) Scanner – 50% chance
        if (scanner_idx >= 0 && irandom(99) < 50) {

            _game.ai_card_target = { x : rnd_x, y : rnd_y };

            var c_sc2 = cards[scanner_idx];
            c_sc2.play(_game, false);
            array_delete(_game.enemy_cards, scanner_idx, 1);
            return true;
        }

        return false;
    }

    // fallback
    return false;
}


function BattleshipGame_Draw(_game) {

    draw_clear(make_color_rgb(0, 10, 30));
    draw_set_font(fnt_board);
    draw_set_color(c_white);

    // HUD
    draw_set_color(make_color_rgb(5, 5, 20));
    draw_rectangle(0, 0, room_width, 120, true);

    var player_alive = _game.player_board.count_ships(_game.player_board);
    var enemy_alive  = _game.enemy_board.count_ships(_game.enemy_board);

    var turno_text = "";
    if (_game.game_over) {
        turno_text = "Jogo encerrado";
    } else if (_game.player_turn) {
        turno_text = "Seu turno";
    } else if (_game.ai_thinking) {
        turno_text = "IA pensando...";
    } else {
        turno_text = "Turno da IA";
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    draw_text(20, 16,  "Barcos inimigo: " + string(enemy_alive));
    draw_text(20, 40,  "Seus barcos: "    + string(player_alive));
    draw_text(20, 64,  "Estado: "         + turno_text);

    Board_Draw(
        _game.player_board,
        _game.player_off,
        _game.offset_y,
        true,
        "SEU TABULEIRO",
        _game.cell_size,
        _game.hover,
        _game.preview
    );

    var empty_preview = { cells : [], valid : false };

    Board_Draw(
        _game.enemy_board,
        _game.enemy_off,
        _game.offset_y,
        false,
        "INIMIGO",
        _game.cell_size,
        _game.hover,
        empty_preview
    );
	
	// info de qual navio esta colocando
    if (_game.placing_ships && _game.current_ship_index < array_length(_game.ships_to_place)) {
        var ship = _game.ships_to_place[_game.current_ship_index];
        var ship_text = "";
        if (ship.kind == "single") {
            ship_text = "Navio 1x1";
        } else if (ship.kind == "line") {
            ship_text = "Navio " + string(ship.len) + "x1";
        } else if (ship.kind == "T") {
            ship_text = "Navio em T";
        }
        draw_text(20, 88, "Colocando: " + ship_text);
    }
	
	// =========================
    // HUD de cartas na mao
    // =========================
    var hud_x = room_width - 260;
    var hud_y = 16;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(c_white);
    draw_text(hud_x, hud_y, "Cartas na mao:");

    // ate 3 slots (teclas 1,2,3)
    for (var i = 0; i < 3; i++) {

        var line_y = hud_y + 24 * (i + 1);

        var slot_text = "[" + string(i + 1) + "] ";

        if (i < array_length(_game.player_cards)) {
            var card = _game.player_cards[i];
            slot_text += card.name;
        } else {
            slot_text += "- vazio -";
        }

        // destaque se for o Tridente em modo mira
        if (_game.trident_aiming && _game.trident_card_index == i) {
            draw_set_color(c_yellow);
        } else {
            draw_set_color(c_ltgray);
        }

        draw_text(hud_x, line_y, slot_text);
    }
	
	// =========================
    // HUD do Scanner (coordenadas encontradas)
    // =========================
    if (_game.scanner_active) {

        var hx = room_width - 260; // mesmo lado das cartas
        var hy = 200;

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_aqua);

        draw_text(hx, hy, "Scanner:");

        if (array_length(_game.scanner_hits) == 0) {
            draw_text(hx, hy + 20, "Nenhum navio encontrado.");
        } else {
            // lista coordenadas tipo A5, C7...
            for (var i = 0; i < array_length(_game.scanner_hits); i++) {
                var cell = _game.scanner_hits[i];
                var gx = cell[0];
                var gy = cell[1];

                var col_letter = chr(ord("A") + gx);
                var row_number = string(gy + 1);

                draw_text(hx, hy + 20 + i * 18, "- " + col_letter + row_number);
            }
        }
    }


    // info simples de quando vem a proxima carta
    draw_set_color(c_gray);
    draw_text(hud_x, hud_y + 24 * 5, "Prox carta em: " + string(max(0, _game.player_card_cooldown)) + " turno(s)");

	
	    // Preview do Tridente (jogador, modo aiming)
    if (!_game.placing_ships && _game.trident_aiming && _game.hover.board == "enemy") {

        var cells = BattleshipGame_GetTridentCellsFromHover(_game);

        var cs = _game.cell_size;
        var offx = _game.enemy_off;
        var offy = _game.offset_y;

        draw_set_alpha(0.5);
        draw_set_color(make_color_rgb(255, 200, 0)); // amarelo

        for (var i = 0; i < array_length(cells); i++) {
            var cx = cells[i][0];
            var cy = cells[i][1];

            var x1 = offx + cx * cs;
            var y1 = offy + cy * cs;
            var x2 = x1 + cs - 1;
            var y2 = y1 + cs - 1;

            draw_rectangle(x1, y1, x2, y2, true);
        }

        draw_set_alpha(1);
    }
	
	// Scanner: destaca area 3x3 no tabuleiro inimigo por 1 "ciclo"
    if (_game.scanner_active) {

		var cs   = _game.cell_size;
		var offx = _game.enemy_off;
		var offy = _game.offset_y;

		for (var i = 0; i < array_length(_game.scanner_cells); i++) {
			var cx = _game.scanner_cells[i][0];
			var cy = _game.scanner_cells[i][1];

			var x1 = offx + cx * cs;
			var y1 = offy + cy * cs;
			var x2 = x1 + cs - 1;
			var y2 = y1 + cs - 1;

			var v = _game.enemy_board.get_cell(_game.enemy_board, cx, cy);

			// fundo levemente tingido, mas transparente
			if (v == 1) {
				draw_set_color(make_color_rgb(0, 200, 0)); // navio
			} else {
				draw_set_color(make_color_rgb(0, 100, 180)); // agua
			}

			draw_set_alpha(0.35);
			draw_rectangle(x1, y1, x2, y2, true);

			// borda clara
			draw_set_alpha(1);
			draw_set_color(c_white);
			draw_rectangle(x1, y1, x2, y2, false);
		}
	}



    if (_game.game_over) {
        var msg = (_game.winner == "player") ? "VOCE VENCEU!" : "VOCE PERDEU!";
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_yellow);
        draw_text(room_width / 2, 20, msg);
    }
}
