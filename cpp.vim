function! Map()
    inoremap #" #include ""<Left>
    inoremap #< #include <><Left>
    inoremap ?? <Esc>:s/\/\///g<CR>==
    inoremap ;; <Esc>A;
    inoremap {{ <Esc>i{}<Esc>O
endf

function! UnMap()
    iu #"
    iu #<
    iu ??
    iu ;;
    iu {{
endfunction

if exists("myInsertClass")
    finish
else
    let myInsertClass=1
    call Map()
endif

imap <F2> <Esc>:call InsertClass()<CR>
map <F2> :call InsertClass()<CR>
map <F4> :w<CR>:call UpdateClassFunc()<CR>
imap <F4> <ESC><F4>
"set path+=/usr/include/c++/7/
"set path+=/usr/include/x86_64-linux-gnu/c++/7/
set path+=/usr/include/GL
set path+=/usr/local/include/
set completefunc=CompleteClassFunction
set completeopt=menu,noinsert,preview
map <F8> :let g:breakpoint = expand('<cword>') <CR>:exec 'breakdel func'. g:breakpoint<CR>
map <F9> 0W:let g:breakpoint = expand('<cword>') <CR>:exec 'breakadd func'. g:breakpoint<CR>
imap <F12> <Esc><F12>
map <F12> :w<CR>:make<CR>
map <F5>  :call MarkWin()<CR>
imap <F10> <Esc>:call InsertSnipplet()<CR>
map <F7> :call AddYankToSnipplets()<CR>

map <Right> :call PageDown(g:MarkWinId)<CR>
map <Left> :call PageUp(g:MarkWinId)<CR>
imap <Right> <Esc>:call PageDown(g:MarkWinId)<CR>a
imap <Left> <Esc>:call PageUp(g:MarkWinId)<CR>a
map <UP> <S-UP>
map <DOWN> <S-DOWN>
imap <UP> <S-UP>
imap <DOWN> <S-DOWN>

func! MapKey(name,first)
    let s = ':inoremap ' . a:name . ' ' . a:first .' <Esc>o{}'.'<UP><UP><Esc>f(a'
    exec s
endfunc

call MapKey('if','if ()')
call MapKey('for','for ()')
call MapKey('sw','switch ()')

func! PageDown(winid)
    let curid=win_getid()
    call win_gotoid(a:winid)
    exec "normal "
    call win_gotoid(curid)
endf
func! PageUp(winid)
    let curid=win_getid()
    call win_gotoid(a:winid)
    exec "normal " 
    call win_gotoid(curid)
endf
func! MarkWin()
    let nr = winnr('$')
    if nr == 1 
        vsplit       " need first split then win_getid
    endif
    let g:MarkWinId = win_getid()
    wincmd x
endf


func! UpdateTags()
    let g:cppCmdAdd='ctags --extra=+q  --fields=+a+S -a  --c++-kinds=mcfp --language-force=c++ *.h'
    let g:cppCmd = 'cpp a.cpp -o my.cpp'
    let g:ctagsCmd = 'ctags --extra=+q --fields=+a+S  --c++-kinds=mcfp --language-force=c++ my.cpp '

    execute "!".g:cppCmd
    execute "!".g:ctagsCmd
    execute "!".g:cppCmdAdd
endfun
"	'string':'std::__cxx11::basic_string'
func! FindWordInDict(w,n)
    let dict = {
                \ 	'':'std::',
                \	'vector':'class:vector',
                \	'ifstream':'std::basic_istream',
                \	'string':'::basic_string'
                \}
    let ret = get(dict,a:w,a:w. ":" . a:n)
    return ret
endfunc

func! FindWordClass(w)
    if a:w == '' 
        return ''
    endif
    if searchdecl(a:w) == 0
        let line = getline('.')
        let lt = split(line,'\s')
        let line =  substitute(lt[0],'<.*$',"",'g')
        let line =  substitute(lt[0],'&',"",'g')
        let line =  substitute(line,'\s',"",'g')
        if len(lt) > 2
            if lt[1] =~ "::"
                return FindWordInDict("class",line)
            else
                return FindWordInDict(line,lt[1])
            endif
        else
            if lt[0] =~ "::"
                return FindWordInDict("class",line)
            else
                return FindWordInDict(line,'')
            endif
        endif

    else
        return ''
    endif
endfun

func! CompleteWord()
    let pos = getcurpos()
    let w =  FindCursorWord()
    let result  = FindWordTag(FindWordClass(w))
    call setpos('.',pos)
    let l = 0
    if strlen(g:restword) > 1 
        let l = strlen(g:restword) - 1
        exe "normal " . l . "X"
        exe "normal " . "x"
    endif
    if strlen(g:restword) == 1 
        exe "normal " . "x"
    endif
    let pos = getcurpos()
    let pos[2] +=1
    call setpos('.',pos)
    call complete(col('.'),result)
    call feedkeys(g:restword)
    return ''
endf

func! FindWordTag(w)
    let s:className = a:w
    let popList = []
    let ss = []
    for a in readfile('tags')
        let flag=0
        "if (match(a,"timeval")) == 0
        "call MyTest(a)
        "endif
        if  match(a ,"^_") != 0  
            if s:className != '' 
                if  match(a,s:className) > 0 
                    let flag = 1
                endif
            else 
                if  match(a,"namespace:std") > 0   
                            \ || s:className == '' && match(a,"file:") > 0
                    let flag = 1
                endif
            endif
        endif
        if flag == 1
            let re = ProcessTagItem(a)
            if re != {}
                call add(popList,re)
            endif
        endif
    endfor
    "echo popList
    return popList
endfunc

func! MyTest(a)
    echo a:a
endf
func! ProcessTagItem(item)
    "if (match(a:item,"isalpha")) == 0
    "	call MyTest(a:item)
    "endif
    let lst = substitute(a:item,'/^\t\+','/^ ','')
    let lst = split(lst,'\t')
    let dec = substitute(lst[2],'/^\s*','','')
    let dec = substitute(dec ,';\?\$\/\;"','','')
    if lst[0] =~ '::'
        return {}
    endif
    if len (lst) > 5
        let info = {'word':lst[0],'info': dec  .' ['. lst[3] .'] ' . lst[4].' [' . lst[5] . ']','dup':1}
    else 
        if len(lst) > 4
            let info = {'word':lst[0],'info': dec  .' ['. lst[2] .'] ' . lst[3].' [' . lst[4] . ']','dup':1}
        endif
        if len(lst) > 3
            let info = {'word':lst[0],'info': dec  .' ['. lst[1] .'] ' . lst[2].' [' . lst[3] . ']'}
        endif
    endif
    return info
endf

func! FindRWord(s)
    let ct = strlen(a:s)
    while  ct >= 0
        let ch = strgetchar(a:s,ct)
        if nr2char(ch) == '(' || nr2char(ch) == ','
                    \ ||  nr2char(ch) == ' '
                    \ ||  nr2char(ch) == '='
            break
        endif
        let ct -= 1
    endwhile
    return ct
endf

fun! FindCursorWord()
    let pos = getcurpos()
    let line = getline(".")
    let col = pos[2]
    if col == 0  || len(line) == 0
        return ""
    endif
    " sdfdf.
    " sddfd.df
    " 
    let s = strpart(line,0,col-1)
    let s= substitute(s,'[\t ]\+',' ','g')
    let c = strridx(s,'.')
    " func(class,class)
    " find (
    " return sth.
    " sth
    " not from . call
    if c < 0 
        let c = FindRWord(s)
        let s = strpart(s,c,len(s))
        let g:restword  = s
        return ''
    endif

    let ct = c-1
    while  ct > 0
        let ch = strgetchar(s,ct)
        if nr2char(ch) == '(' || nr2char(ch) == ','
                    \ ||  nr2char(ch) == ' '
                    \ ||  nr2char(ch) == '='
            break
        endif
        let ct -= 1
    endwhile

    let lp = ct
    let word = strpart(s,lp + 1, c - lp - 1)
    "let s= substitute(s,'[\t ]\+',' ','g')
    let g:restword = strpart(s,c+1,len(s))
    return word
endf

fun! CompleteClassFunction(findstart,base)
    if a:findstart
        let line = getline('.') 
        let start = col('.') - 1
        while start >0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        let g:currentword = FindCursorWord()
        if g:currentword == ''
            return -3
        endif
        return start
    else
        if a:base == ''
            let answer = g:currentword
            if answer == ''
                return -3
            endif
        else
            let answer = a:base
        endif
        let class = FindWordClass(answer)
        if class	== ''
            return -3
        endif
        let res = FindWordTag(class)
        return res
    endif
endfun 


function! UpdateClassFunc()
    let result = search('^\s*class\s\+.*','b') 
    let classname = getline(".")
    let clsname = matchlist(classname,'class\s\+\(\a\+\)')
    let cname=""
    if len(clsname) > 0
        let cname = clsname[1]
    endif
    call search('{')
    let s:begin  = line(".") + 1
    exec "normal " . "%"
    let s:end = line(".") - 1
    let lines = getline(s:begin,s:end)
    let cppFile = expand('%<') . ".cpp"
    call UnMap()
    call OpenBuffer(cppFile)
    let flag = 0
    for a in lines
        let a = substitute(a,'//.*','','g')
        if  a == "" 
            continue
        endif
        if matchstr(a,'{') !="" 
            let flag += 1
            continue
        elseif matchstr(a,'}') !=""
            let flag -= 1
            continue
        endif
        if flag > 0 
            continue
        endif
        call InsertFunc(a,cname)
    endfor
    call search(cname)
    call Map()
endfunction

function! OpenBuffer(name)
    if bufexists(a:name) 
        let winid = win_findbuf(bufnr(a:name))
        if len(winid) > 0 
            let winnr = winnr('$')
            let curwin = 0
            while curwin < winnr
                wincmd w
                if bufname('%') == a:name
                    break
                endif
                let curwin +=1
            endwhile
            if curwin == winnr
                exec "buffer " . a:name
            endif
        else
            exec "vsplit " . a:name
        endif 
    else
        exec "vsplit " . a:name
    endif
    let fname = matchstr(a:name,"[^.]*")
    let inc = "#include \"" . fname . ".h\""
    if search(inc) == 0
        call append(line('.'),inc)
    endif
endfunction
"a : function name
"n : classname
function! InsertFunc(a,n)
    if matchstr(a:a,')\s*;') == ""  
        return
    endif
    let l = substitute(a:a,'\s*(\s*','(','g')
    let l = substitute(l,'\s\+',' ','g')
    let l = substitute(l,'\s*)\s*',')','g')
    let l = matchlist(l,'[ \t]*\(.*\)[ ]\([^( ]\+\)\((.*\);')
    if len(l) < 2 
        let l = matchlist(a:a,'\([ \t]*\)\([^( ]\+\)\((.*\);')
        if  len(l) > 2
            let l[1] = ""
        endif
    else
        let l[1] = l[1] . " " 
    endif
    if len(l) > 2 
        let l[2]  = substitute(l[2],'^\s\+','','')
        let l[3]  = substitute(l[3],'^\s\+','','')
        let target = l[1] . a:n . "::" . l[2] . l[3] 
        let target= substitute(target,'^\s\+','','')
        let other = substitute(target,'\~','\\\~','')
        let other = substitute(other,'\*','\\\*','')
        if search(other,'nw')
            return
        endif
        exec "normal G"
        if search('//'. toupper(a:n) . ' BEGIN','w')  == "" 
            let lst = [   '//' . toupper(a:n) . ' BEGIN',
                        \ target,
                        \ '{',
                        \ '}',
                        \ '//' . toupper(a:n) . ' END' ]
        else
            let lst = [  target,
                        \ '{',
                        \ '}']
        endif
        call append(line('.'),lst)
    endif
endfunction

function! InsertClass()
    let s:name = input("type class name : ")
    if  s:name == ''  
        let s:name ="name"
    endif
    let l = getline('.')
    let l = substitute(l,'\s\+$','','g')
    if  l == ""
        exec 'normal dd'
    endif
    let lst=['class ' .  s:name,
                \ '{',
                \ 'private:',
                \ 'public:',
                \ '//constructor',
                \ '' . s:name . "();",
                \ '' . s:name . "(const ". s:name . "& s);",
                \ '' .s:name . "& operator=(const ". s:name . "& s);",
                \ '~' . s:name . "();",
                \ 'public:',
                \ '//maniulator',
                \ '//accessor',
                \ '};' ]
    call append(line('.') - 1,lst)
    exec "normal " . string(len(lst)) . '=='
    call search("private")
endfunction

func! InsertSnipplet()
    let c = 0
    let g:snipdict ={}
    let filecontent = readfile(expand("~/.vim/ftplugin/c.snip"))
    for a in filecontent
        let c += 1
        let name =  matchlist(a ,'//BEGIN\s\+\(\w\+\)')
        if len(name) > 0 
            let sn = name[1]
            let begin = c
            continue
        endif
        let name =  matchlist(a ,'//END\s\+\(\w\+\)')
        if len(name) > 0
            let sn = name[1]
            let en = c - 2
            let g:snipdict[sn] = {'begin': begin , 'end': en}
            continue
        endif
    endfor
    let lst = ['select snipplets:']
    let sel = ['hold']
    let c = 0
    let width = 8
    let s = ''
    for a in keys(g:snipdict)
        let c+=1
        let s = s .  string(c) . '.' . a . " "
        if  c  >= width
            let c = 0
            call add(lst, s)
            let s = ''
        endif
        call add(sel,a)
    endfor
    if  c <  width
            call add(lst, s)
    endif
    let  sn = inputlist(lst)
    let content = filecontent[g:snipdict[sel[sn]]['begin']:g:snipdict[sel[sn]]['end']]
    call append(line('.') - 1, content)
endf

func! FindSnippletName(name)
    let n = toupper(a:name)
    let filecontent = readfile(expand('~/.vim/ftplugin/c.snip'))
    for a in filecontent
        if matchstr(a,'//BEGIN\s\+'.n . '\s*$') != ""
            return "find"
        endif
    endfor
    return ""
endf
func! AddYankToSnipplets()
    let lst=[]
    try 
        let lst=getreg('""',1,1)
        call AddToSnipplets(lst)
    endtry
endfunc
func! AddToSnipplets(lines)
    if  len(a:lines) < 1 
        echo "no selection"
        return 
    endif
    let snipname = input("input snip name:")
    let find =  FindSnippletName(snipname)
    if  find == "" 
        echo "no find"
    else
        echo "\nalread have " . snipname
        return
    endif
    split ~/.vim/ftplugin/c.snip
    call cursor(1,1)
    call search('//BEGIN') 
    let be = '//BEGIN '
    let ne = '//END '
    call append(line('.') - 1,be .toupper(snipname))
    "exec 'normal O' . be . toupper(snipname)
    call append(line('.') - 1,ne . toupper(snipname))
    call append(line('.') - 2 ,a:lines)
    :wq
endf
