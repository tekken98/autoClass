"TRAITS
"**
"MapKey(mapname,first,last)
"
"
"<SID>InsertHead(lst)
"
"
"TraitsFunc()
"
func! MapKey(mapname,first,last)
    let s = ':inoremap ' . a:mapname . ' ' . a:first .'<Esc>o'.a:last .'<UP><ESC>A '
    exec s
endf
call MapKey(',if','if','endif')
call MapKey(',for','for','endfor')
call MapKey(',fc','func!','endfunc')
map <F8> :let g:breakpoint = expand('<cword>') <CR>:exec 'breakdel func'. g:breakpoint<CR>
map <F9> 0W:let g:breakpoint = expand('<cword>') <CR>:exec 'breakadd func'. g:breakpoint<CR>
map  <F10> :call TraitsFunc()<CR>

func! <SID>InsertHead(lst)
    "call sort(lst)
    let res = []
    for a in a:lst
        let  s =  a .'$'
        if search(s,'w') > 0 
            continue
        endif
        call add(res,a)
    endfor 
    call cursor(1,1)
    call append(line('.'),res)
endfunc
func! TraitsFunc()
    let lst=[]
    call cursor(1,1)
    let line = getline('.')
    if matchstr(line,'TRAITS') == ''
        call append(line('.') - 1,'"TRAITS')
    endif
    call cursor(1,1)
    while search('^func','W') >0
        let line = getline('.')
        let res = split(line , ' ')
        if len(res) > 1
            call add(lst,'"' . res[1])
        else
            return 
        endif
    endwhile
    call <SID>InsertHead(lst)
endfunc
