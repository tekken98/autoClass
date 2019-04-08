func! MapKey(mapname,first,last)
    let s = ':inoremap ' . a:mapname . ' ' . a:first .'<Esc>o'.a:last .'<UP><ESC>A '
    exec s
endf
call MapKey('if','if','endif')
call MapKey('for','for','endfor')
call MapKey('fc','func!','endfunc')
