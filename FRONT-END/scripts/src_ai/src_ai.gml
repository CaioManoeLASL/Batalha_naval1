
// ---------------------------------------------
// Função "no-op" para o modo fácil
// ---------------------------------------------
function AI_NoOp_OnResult(_ai, _board, _x, _y, _hit) {
    // não faz nada
}

// ---------------------------------------------
// FÁCIL – tiro totalmente aleatório
// ---------------------------------------------
function AI_Easy_Create() {
    return {
        difficulty    : "facil",
        choose_target : AI_Easy_ChooseTarget,
        on_result     : AI_NoOp_OnResult
    };
}

function AI_Easy_ChooseTarget(_ai, _board) {

    var size = _board.grid_size;
    var gx, gy;

    repeat (500) {
        gx = irandom(size - 1);
        gy = irandom(size - 1);

        if (_board.is_attackable(_board, gx, gy)) {
            return [gx, gy];
        }
    }

    return [0, 0];
}

// compatibilidade com nome antigo, se usar em algum lugar
function AI_Random_Create() {
    return AI_Easy_Create();
}

// ---------------------------------------------
// MÉDIO – aleatório + caça ao redor de acertos
// ---------------------------------------------
function AI_Medium_Create() {

    var list = ds_list_create();

    var _ai = {
        difficulty    : "medio",
        choose_target : AI_Medium_ChooseTarget,
        on_result     : AI_Medium_OnShotResult,
        target_list   : list
    };

    return _ai;
}

function AI_Medium_ChooseTarget(_ai, _board) {

    if (ds_list_size(_ai.target_list) > 0) {
        var pos = _ai.target_list[| 0];
        ds_list_delete(_ai.target_list, 0);
        return pos;
    }

    return AI_Easy_ChooseTarget(_ai, _board);
}

function AI_Medium_OnShotResult(_ai, _board, _x, _y, _hit) {

    if (!_hit) return;

    var size = _board.grid_size;

    var neighbors = [
        [_x - 1, _y],
        [_x + 1, _y],
        [_x, _y - 1],
        [_x, _y + 1]
    ];

    for (var i = 0; i < array_length(neighbors); i++) {

        var nx = neighbors[i][0];
        var ny = neighbors[i][1];

        if (nx < 0 || ny < 0 || nx >= size || ny >= size) continue;

        if (_board.is_attackable(_board, nx, ny)) {
            var pos = [nx, ny];
            ds_list_add(_ai.target_list, pos);
        }
    }
}

// ---------------------------------------------
// DIFÍCIL – igual médio, mas com padrão "xadrez"
// ---------------------------------------------
function AI_Hard_Create() {

    var list = ds_list_create();

    var _ai = {
        difficulty    : "dificil",
        choose_target : AI_Hard_ChooseTarget,
        on_result     : AI_Medium_OnShotResult, // reusa caça
        target_list   : list
    };

    return _ai;
}

function AI_Hard_ChooseTarget(_ai, _board) {

    if (ds_list_size(_ai.target_list) > 0) {
        var pos = _ai.target_list[| 0];
        ds_list_delete(_ai.target_list, 0);
        return pos;
    }

    var size = _board.grid_size;
    var gx, gy;

    repeat (500) {
        gx = irandom(size - 1);
        gy = irandom(size - 1);

        if ((gx + gy) mod 2 != 0) continue;

        if (_board.is_attackable(_board, gx, gy)) {
            return [gx, gy];
        }
    }

    return AI_Easy_ChooseTarget(_ai, _board);
}
