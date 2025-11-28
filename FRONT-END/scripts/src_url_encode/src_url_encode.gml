/// @function scr_url_encode(text)
/// @param text

function scr_url_encode(text)
{
    var out = "";
    var c;

    for (var i = 1; i <= string_length(text); i++)
    {
        c = ord(string_char_at(text, i));

        // Letras, números e _ - . ~ não precisam de encoding
        if (
            (c >= 48 && c <= 57)  || // 0-9
            (c >= 65 && c <= 90)  || // A-Z
            (c >= 97 && c <= 122) || // a-z
            c == 45 || c == 46 || c == 95 || c == 126 // - . _ ~
        ) {
            out += chr(c);
        }
        else {
            out += "%" + string_format(c, 2, 0);
        }
    }

    return out;
}
