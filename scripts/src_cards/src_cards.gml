// =========================
// TIPOS DE CARTA
// =========================
// "trident"  -> Tridente de Poseidon
// "heal"     -> Canto da Sereia
// "scanner"  -> Olho de Proteu

// Struct de carta genérica
function Card_Create(_id, _name, _desc, _play_func) {
    return {
        id          : _id,
        name        : _name,
        description : _desc,
        play        : _play_func   // função que aplica o efeito
    };
}

// -------- Tridente de Poseidon --------
// Ataca 3 casas em linha a partir da celula clicada (usa rotacao atual).
// Depois de usar, jogador/IA nao pode atacar no proximo turno normal.

function Card_CreateTrident() {
    return Card_Create(
        "trident",
        "Tridente de Poseidon",
        "Ataca 3 casas em linha. Perde o proximo ataque.",
        Card_PlayTrident
    );
}

function Card_PlayTrident(_game, _is_player) {

    // precisamos de uma celula alvo (clicada ou escolhida pela IA)
    var target = _is_player ? _game.click : _game.ai_card_target;
    if (is_undefined(target)) return;

    var board = _is_player ? _game.enemy_board : _game.player_board;

    var gx = target.x;
    var gy = target.y;

    // usa a mesma rotacao que voce ja tem para navios
    var rot       = _game.current_rotation;
    var horizontal = ((rot mod 2) == 0);

    // 3 casas: celula central e 2 ao redor (ou acima/abaixo)
    var cells = [];

    if (horizontal) {
        array_push(cells, [gx - 1, gy]);
        array_push(cells, [gx,     gy]);
        array_push(cells, [gx + 1, gy]);
    } else {
        array_push(cells, [gx, gy - 1]);
        array_push(cells, [gx, gy    ]);
        array_push(cells, [gx, gy + 1]);
    }

    var size = board.grid_size;

    for (var i = 0; i < array_length(cells); i++) {
        var cx = cells[i][0];
        var cy = cells[i][1];

        if (cx < 0 || cy < 0 || cx >= size || cy >= size) continue;
        if (!board.is_attackable(board, cx, cy)) continue;

        var hit = board.receive_shot(board, cx, cy);

        if (_is_player) {
            if (hit) {
                show_debug_message("Tridente acertou em [" + string(cx) + "," + string(cy) + "]");
            } else {
                show_debug_message("Tridente errou em [" + string(cx) + "," + string(cy) + "]");
            }
        } else {
            if (hit) {
                show_debug_message("IA usou Tridente e acertou em [" + string(cx) + "," + string(cy) + "]");
                _game.enemy_last_hit.x = cx;
                _game.enemy_last_hit.y = cy;
            } else {
                show_debug_message("IA usou Tridente e errou em [" + string(cx) + "," + string(cy) + "]");
            }
        }
    }

    // aplica penalidade: perde o proximo ataque normal
    if (_is_player) {
        _game.player_skip_next_attack = true;
    } else {
        _game.enemy_skip_next_attack = true;
    }
}

// -------- Canto da Sereia --------
// Cura todas as celulas 2 (acertadas) do jogador que ainda nao perdeu o jogo.

function Card_CreateHeal() {
    return Card_Create(
        "heal",
        "Canto da Sereia",
        "Cura navios parcialmente danificados.",
        Card_PlayHeal
    );
}

function Card_PlayHeal(_game, _is_player) {

    var board, target;

    if (_is_player) {
        // jogador clica no PROPRIO tabuleiro
        if (_game.click.board != "player") {
            show_debug_message("Clique em um navio seu para usar Canto da Sereia.");
            return;
        }
        target = _game.click;
        board  = _game.player_board;
    } else {
        // IA escolhe uma celula qualquer do tabuleiro dela
        if (is_undefined(_game.ai_card_target)) return;
        target = _game.ai_card_target;
        board  = _game.enemy_board;
    }

    var sx = target.x;
    var sy = target.y;

    var size = board.grid_size;
    if (sx < 0 || sy < 0 || sx >= size || sy >= size) return;

    var v = board.cells[sx][sy];
    if (v != 1 && v != 2) {
        if (_is_player) {
            show_debug_message("Canto da Sereia: selecione uma celula com navio (1 ou 2).");
        }
        return;
    }

    var ship_cells = Board_GetShipComponent(board, sx, sy);

    var has_alive = false;
    for (var i = 0; i < array_length(ship_cells); i++) {
        var cx = ship_cells[i][0];
        var cy = ship_cells[i][1];
        if (board.cells[cx][cy] == 1) {
            has_alive = true;
            break;
        }
    }

    if (!has_alive) {
        if (_is_player) {
            show_debug_message("Este navio ja foi completamente destruido. Nao pode ser curado.");
        }
        return;
    }

    var healed = 0;
    for (var j = 0; j < array_length(ship_cells); j++) {
        var hx = ship_cells[j][0];
        var hy = ship_cells[j][1];

        if (board.cells[hx][hy] == 2) {
            board.cells[hx][hy] = 1;
            healed++;
        }
    }

    if (_is_player) {
        show_debug_message("Canto da Sereia curou " + string(healed) + " celula(s) deste navio.");
    } else {
        show_debug_message("IA usou Canto da Sereia e curou " + string(healed) + " celula(s) de um navio.");
    }
}


// -------- Olho de Proteu --------
// Scaneia uma area 3x3 e mostra quantas celulas com navio existem ali.
// (nao ataca, so revela informacao via debug por enquanto)

function Card_CreateScanner() {
    return Card_Create(
        "scanner",
        "Olho de Proteu",
        "Scaneia uma area 3x3 em busca de navios.",
        Card_PlayScanner
    );
}

function Card_PlayScanner(_game, _is_player) {

    var board, target;

    if (_is_player) {
        // centro vem do clique no modo mira
        if (_game.click.board != "enemy") {
            show_debug_message("Scanner: clique em uma celula do inimigo.");
            return;
        }
        target = _game.click;
        board  = _game.enemy_board;
    } else {
        // IA usa scanner no tabuleiro do jogador
        if (is_undefined(_game.ai_card_target)) return;
        target = _game.ai_card_target;
        board  = _game.player_board;
    }

    var cx = target.x;
    var cy = target.y;
    var size = board.grid_size;

    var hits = [];
    var total_found = 0;

    // varre area 3x3 em volta do centro
    for (var gx = cx - 1; gx <= cx + 1; gx++) {
        for (var gy = cy - 1; gy <= cy + 1; gy++) {

            if (gx < 0 || gy < 0 || gx >= size || gy >= size) continue;

            var v = board.get_cell(board, gx, gy);

            // considera navio em celulas 1 (inteiro) ou 2 (acertado)
            if (v == 1 || v == 2) {
                array_push(hits, [gx, gy]);
                total_found++;
            }
        }
    }

    _game.scanner_hits   = hits;
    _game.scanner_active = true;

    if (_is_player) {
        show_debug_message("Olho de Proteu: " + string(total_found) + " celula(s) de navio detectadas.");
    } else {
        show_debug_message("IA usou Olho de Proteu e detectou " + string(total_found) + " celula(s).");
    }
}


// =========================
// Funcoes de gerencia de cartas
// =========================

// Adiciona uma carta aleatoria para jogador ou IA
function BattleshipGame_GiveRandomCard(_game, _is_player) {

    var r = irandom(2); // 0,1,2
    var card;

    switch (r) {
        case 0: card = Card_CreateTrident(); break;
        case 1: card = Card_CreateHeal();    break;
        case 2: card = Card_CreateScanner(); break;
    }

    if (_is_player) {
        array_push(_game.player_cards, card);
        show_debug_message("Jogador recebeu carta: " + card.name);
    } else {
        array_push(_game.enemy_cards, card);
        show_debug_message("IA recebeu carta: " + card.name);
    }
}

// Usa a carta na posicao _index da mao do jogador
// (a logica de definir alvo fica no jogo)
function BattleshipGame_PlayPlayerCard(_game, _index) {

    if (_index < 0 || _index >= array_length(_game.player_cards)) return;

    // so pode usar carta se ainda nao usou neste turno
    if (_game.card_used_this_turn) {
        show_debug_message("Ja usou uma carta neste turno.");
        return;
    }

    var card = _game.player_cards[_index];

    // TRIDENTE -> mira no inimigo
    if (card.id == "trident") {
        if (!_game.player_turn || _game.placing_ships || _game.game_over) return;

        _game.trident_aiming     = true;
        _game.trident_card_index = _index;
        show_debug_message("Modo Tridente: clique no inimigo.");
        return;
    }

    // HEAL -> mira no jogador
    if (card.id == "heal") {
        if (!_game.player_turn || _game.placing_ships || _game.game_over) return;

        _game.heal_aiming     = true;
        _game.heal_card_index = _index;
        show_debug_message("Modo Cura: clique em um navio seu.");
        return;
    }

    // SCANNER -> mira no inimigo
    if (card.id == "scanner") {
        if (!_game.player_turn || _game.placing_ships || _game.game_over) return;

        _game.scanner_aiming     = true;
        _game.scanner_card_index = _index;
        show_debug_message("Modo Scanner: clique em uma area do inimigo.");
        return;
    }
}




function Board_GetShipComponent(_board, _sx, _sy) {

    var size = _board.grid_size;
    var ship_cells = [];

    // matriz de visitados
    var visited = array_create(size);
    for (var i = 0; i < size; i++) {
        visited[i] = array_create(size, false);
    }

    var v0 = _board.cells[_sx][_sy];
    if (v0 != 1 && v0 != 2) {
        return ship_cells; // vazio
    }

    var stack = [];
    array_push(stack, [_sx, _sy]);

    while (array_length(stack) > 0) {

        var node = stack[array_length(stack) - 1];
        array_pop(stack);

        var cx = node[0];
        var cy = node[1];

        if (cx < 0 || cy < 0 || cx >= size || cy >= size) continue;
        if (visited[cx][cy]) continue;

        visited[cx][cy] = true;

        var v = _board.cells[cx][cy];
        if (v != 1 && v != 2) continue;

        array_push(ship_cells, [cx, cy]);

        array_push(stack, [cx - 1, cy]);
        array_push(stack, [cx + 1, cy]);
        array_push(stack, [cx, cy - 1]);
        array_push(stack, [cx, cy + 1]);
    }

    return ship_cells;
}