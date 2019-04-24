let name =expand("%<")
let head = toupper(name) . "_H"
let ls = [ "#ifndef " . head,
            \ "#define " . head,
            \ "",
            \ "#endif" ]
call append(line('.') - 1,ls)
exec 'normal 2k'
