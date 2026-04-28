# shell escaping
s/'/'"'"'/g

# U+0080–U+00FF Latin-1 Supplement
# U+00A0 NO-BREAK SPACE
s/ . . ./.../g
s/. . ./.../g
s/ / /g
s/©/(C)/g
# U+00AD SOFT HYPHEN
s/­//g
s/®/(R)/g
s|¼|1/4|g
s|½|1/2|g
s|¾|3/4|g
s/À/A/g
s/Á/A/g
s/Â/A/g
s/Ã/A/g
s/Ä/A/g
s/Å/A/g
s/Æ/AE/g
s/Ç/C/g
s/È/E/g
s/É/E/g
s/Ê/E/g
s/Ë/E/g
s/Ì/I/g
s/Í/I/g
s/Î/I/g
s/Ï/I/g
s/Ð/D/g
s/Ñ/N/g
s/Ò/O/g
s/Ó/O/g
s/Ô/O/g
s/Õ/O/g
s/Ö/O/g
s/Ø/Oe/g
s/Ù/U/g
s/Ú/U/g
s/Û/U/g
s/Ü/U/g
s/Ý/Y/g
s/Þ/Th/g
s/ß/ss/g
s/à/a/g
s/á/a/g
s/â/a/g
s/ã/a/g
s/ä/a/g
s/å/a/g
s/æ/ae/g
s/ç/c/g
s/è/e/g
s/é/e/g
s/ê/e/g
s/ë/e/g
s/ì/i/g
s/í/i/g
s/î/i/g
s/ï/i/g
s/ð/dh/g
s/ñ/n/g
s/ò/o/g
s/ó/o/g
s/ô/o/g
s/õ/o/g
s/ö/o/g
s/ø/oe/g
s/ù/u/g
s/ú/u/g
s/û/u/g
s/ü/u/g
s/ý/y/g
s/þ/th/g
s/ÿ/y/g

# U+0100–U+017F Latin Extended-1
s/Ā/A/g
s/ā/a/g
s/Ă/A/g
s/ă/a/g
s/Ą/A/g
s/ą/a/g
s/Ć/C/g
s/ć/c/g
s/Ĉ/C/g
s/ĉ/c/g
s/Ċ/C/g
s/ċ/c/g
s/Č/C/g
s/č/c/g
s/Ď/D/g
s/ď/d/g
s/Đ/D/g
s/₫/d/g
s/Ē/E/g
s/ē/e/g
s/Ĕ/E/g
s/ĕ/e/g
s/Ė/E/g
s/ė/e/g
s/Ę/E/g
s/ę/e/g
s/Ě/E/g
s/ě/e/g
s/Ĝ/G/g
s/ĝ/g/g
s/Ğ/G/g
s/ğ/g/g
s/Ġ/G/g
s/ġ/g/g
s/Ģ/G/g
s/ģ/g/g
s/Ĥ/H/g
s/ĥ/h/g
s/Ħ/H/g
s/ħ/h/g
s/Ĩ/I/g
s/ĩ/i/g
s/Ī/I/g
s/ī/i/g
s/Ĭ/I/g
s/ĭ/i/g
s/Į/I/g
s/į/i/g
s/İ/I/g
s/ı/i/g
s/Ĳ/IJ/g
s/ĳ/ij/g
s/Ĵ/J/g
s/ĵ/j/g
s/Ķ/K/g
s/ķ/k/g
s/ĸ/q/g
s/Ĺ/L/g
s/ĺ/l/g
s/Ļ/L/g
s/ļ/l/g
s/Ľ/L/g
s/ľ/l/g
s/Ŀ/L/g
s/ŀ/l/g
s/Ł/L/g
s/ł/l/g
s/Ń/N/g
s/ń/n/g
s/Ņ/N/g
s/ņ/n/g
s/Ň/N/g
s/ň/n/g
s/ŉ/'"'"'n/g
s/Ŋ/Ng/g
s/ŋ/ng/g
s/Ō/O/g
s/ō/o/g
s/Ŏ/O/g
s/ŏ/o/g
s/Ő/O/g
s/ő/o/g
s/Œ/OE/g
s/œ/oe/g
s/Ŕ/R/g
s/ŕ/r/g
s/Ŗ/R/g
s/ŗ/r/g
s/Ś/S/g
s/ś/s/g
s/Ŝ/S/g
s/ŝ/s/g
s/Ş/S/g
s/ş/s/g
s/Š/S/g
s/š/s/g
s/Ţ/T/g
s/ţ/t/g
s/Ť/T/g
s/ť/t/g
s/Ŧ/T/g
s/ŧ/t/g
s/Ũ/U/g
s/ũ/u/g
s/Ū/U/g
s/ū/u/g
s/Ŭ/U/g
s/ŭ/u/g
s/Ů/U/g
s/ů/u/g
s/Ű/U/g
s/ű/u/g
s/Ų/U/g
s/ų/u/g
s/Ŵ/W/g
s/ŵ/w/g
s/Ŷ/Y/g
s/ŷ/y/g
s/Ÿ/Y/g
s/Ź/Z/g
s/ź/z/g
s/Ż/Z/g
s/ż/z/g
s/Ž/Z/g
s/ž/z/g
s/ſ/s/g

# U+2010 HYPHEN
s/‐/-/g
# U+2013 EN DASH
s/–/-/g
# U+2014 EM DASH
s/—/--/g
# U+2018 LEFT SINGLE QUOTATION MARK
s/‘/'"'"'/g
# U+2019 RIGHT SINGLE QUOTATION MARK
s/’/'"'"'/g
# U+201C LEFT DOUBLE QUOTATION MARK
s/“/"/g
# U+201D RIGHT SINGLE QUOTATION MARK
s/”/"/g
# U+2026 HORIZONTAL ELLIPSIS
s/…/.../g
# U+202F NARROW NO-BREAK SPACE
s/ / /g
# U+2032 PRIME
s/′/'"'"'/g
# U+2033 DOUBLE PRIME
s/″/"/g
# U+2212 MINUS SIGN
s/−/-/g
