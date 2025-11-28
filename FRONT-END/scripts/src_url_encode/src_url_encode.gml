function src_url_encode() {
    return "";
}

function url_encode(str) {
    var map = {
        " " : "%20",
        "!" : "%21",
        "\"" : "%22",
        "#" : "%23",
        "%" : "%25",
        "&" : "%26",
        "'" : "%27",
        "(" : "%28",
        ")" : "%29",
        "+" : "%2B",
        "," : "%2C",
        "/" : "%2F",
        ":" : "%3A",
        ";" : "%3B",
        "=" : "%3D",
        "?" : "%3F",
        "@" : "%40"
    };

    var out = "";
    var len = string_length(str);

    for (var i = 1; i <= len; i++) {
        var ch = string_char_at(str, i);
        if (ds_map_exists(map, ch)) {
            out += map[? ch];
        } else {
            out += ch;
        }
    }
    return out;
}
