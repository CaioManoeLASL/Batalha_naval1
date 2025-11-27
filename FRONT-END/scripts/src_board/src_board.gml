function Board_Create(_grid_size) {
    var _cells = array_create(_grid_size);
    for (var i = 0; i < _grid_size; i++) {
        _cells[i] = array_create(_grid_size, 0); // 0 = água
    }

    var _board = {
        grid_size : _grid_size,
        cells     : _cells,

        // Métodos do tabuleiro
        get_cell  : Board_GetCell,
        set_cell  : Board_SetCell,
        toggle_ship : Board_ToggleShip,
        count_ships : Board_CountShips,
        place_random_ships : Board_PlaceRandomShips,
        is_attackable : Board_IsAttackable,
        receive_shot  : Board_ReceiveShot,
		all_ships_sunk : Board_AllShipsSunk,
		place_default_fleet : Board_PlaceFleetDefault
    };

    return _board;
}

function Board_GetCell(_board, _x, _y) {
    return _board.cells[_x][_y];
}

function Board_SetCell(_board, _x, _y, _value) {
    _board.cells[_x][_y] = _value;
}

// 0 = água, 1 = navio, 2 = acerto, 3 = erro
function Board_ToggleShip(_board, _x, _y) {
    var v = _board.get_cell(_board, _x, _y);
    if (v == 1) v = 0; else v = 1;
    _board.set_cell(_board, _x, _y, v);
}

function Board_CountShips(_board) {
    var count = 0;
    for (var ix = 0; ix < _board.grid_size; ix++) {
        for (var iy = 0; iy < _board.grid_size; iy++) {
            if (_board.cells[ix][iy] == 1) count++;
        }
    }
    return count;
}

function Board_PlaceRandom_Single(_board) {

    repeat (1000) {
        var ix = irandom(_board.grid_size - 1);
        var iy = irandom(_board.grid_size - 1);
        if (_board.cells[ix][iy] == 0) {
            _board.cells[ix][iy] = 1;
            return;
        }
    }
}

function Board_PlaceRandomShips(_board, _amount) {
    for (var i = 0; i < _amount; i++) {
        Board_PlaceRandom_Single(_board);
    }
}

function Board_CanPlaceLine(_board, _start_x, _start_y, _len, _horizontal) {

    var size = _board.grid_size;

    if (_horizontal) {
        if (_start_x + _len - 1 >= size) return false;
    } else {
        if (_start_y + _len - 1 >= size) return false;
    }

    for (var ix = 0; ix < _len; ix++) {
        var gx = _start_x + (_horizontal ? ix : 0);
        var gy = _start_y + (_horizontal ? 0 : ix);

        if (_board.cells[gx][gy] != 0) {
            return false;
        }
    }

    return true;
}

function Board_PlaceLine(_board, _start_x, _start_y, _len, _horizontal) {

    for (var ix = 0; ix < _len; ix++) {
        var gx = _start_x + (_horizontal ? ix : 0);
        var gy = _start_y + (_horizontal ? 0 : ix);
        _board.cells[gx][gy] = 1;
    }
}

function Board_PlaceRandom_Line(_board, _len) {

    var size = _board.grid_size;

    repeat (1000) {

        var horizontal = (irandom(1) == 0);
        var sx = irandom(size - 1);
        var sy = irandom(size - 1);

        if (Board_CanPlaceLine(_board, sx, sy, _len, horizontal)) {
            Board_PlaceLine(_board, sx, sy, _len, horizontal);
            return;
        }
    }
}

function Board_GetTOffsets(_rotation) {

    var r = _rotation mod 4;

    switch (r) {
        case 0: // T "apontando para baixo"
            return [
                [-1, 0],
                [ 0, 0],
                [ 1, 0],
                [ 0, 1],
                [ 0, 2]
            ];
        case 1: // T apontando para a esquerda
            return [
                [ 0, -1],
                [ 0,  0],
                [ 0,  1],
                [-1,  0],
                [-2,  0]
            ];
        case 2: // T apontando para cima
            return [
                [-1, 0],
                [ 0, 0],
                [ 1, 0],
                [ 0, -1],
                [ 0, -2]
            ];
        case 3: // T apontando para a direita
            return [
                [ 0, -1],
                [ 0,  0],
                [ 0,  1],
                [ 1,  0],
                [ 2,  0]
            ];
    }

    return [];
}

function Board_CanPlaceT(_board, _cx, _cy, _rotation) {

    var size = _board.grid_size;
    var offsets = Board_GetTOffsets(_rotation);

    for (var i = 0; i < array_length(offsets); i++) {
        var ox = offsets[i][0];
        var oy = offsets[i][1];
        var gx = _cx + ox;
        var gy = _cy + oy;

        if (gx < 0 || gy < 0 || gx >= size || gy >= size) return false;
        if (_board.cells[gx][gy] != 0) return false;
    }

    return true;
}

function Board_PlaceT(_board, _cx, _cy, _rotation) {

    var offsets = Board_GetTOffsets(_rotation);

    for (var i = 0; i < array_length(offsets); i++) {
        var ox = offsets[i][0];
        var oy = offsets[i][1];
        var gx = _cx + ox;
        var gy = _cy + oy;
        _board.cells[gx][gy] = 1;
    }
}


function Board_PlaceRandom_T(_board) {

    var size = _board.grid_size;

    repeat (1000) {
        var cx = irandom(size - 1);
        var cy = irandom(size - 1);
		var rot = irandom(3);

        if (Board_CanPlaceT(_board, cx, cy, rot)) {
            Board_PlaceT(_board, cx, cy, rot);
            return;
        }
    }
}

function Board_PlaceFleetDefault(_board) {

    // 3 navios de 1 casa
    for (var i = 0; i < 3; i++) {
        Board_PlaceRandom_Single(_board);
    }

    // 2 navios de 2 casas
    for (var j = 0; j < 2; j++) {
        Board_PlaceRandom_Line(_board, 2);
    }

    // 1 navio de 3 casas
    Board_PlaceRandom_Line(_board, 3);

    // 1 navio de 4 casas
    Board_PlaceRandom_Line(_board, 4);

    // 1 navio em T (5 casas)
    Board_PlaceRandom_T(_board);
}


// só pode atacar se ainda for 0 ou 1
function Board_IsAttackable(_board, _x, _y) {
    var v = _board.get_cell(_board, _x, _y);
    return (v == 0 || v == 1);
}

// retorna true se foi acerto
function Board_ReceiveShot(_board, _x, _y) {
    var v = _board.get_cell(_board, _x, _y);

    if (v == 1) {
        _board.set_cell(_board, _x, _y, 2); // acerto
        return true;
    }
    else if (v == 0) {
        _board.set_cell(_board, _x, _y, 3); // erro
        return false;
    }

    // já foi atacado antes
    return false;
}

function Board_AllShipsSunk(_board) {
    for (var ix = 0; ix < _board.grid_size; ix++) {
        for (var iy = 0; iy < _board.grid_size; iy++) {
            if (_board.cells[ix][iy] == 1) {
                return false;
            }
        }
    }
    return true;
}

