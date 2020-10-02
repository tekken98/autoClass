"TRAITS
"MyTest(a)
"Map()
"UnMap()
"TransCode(c)
"InsertHead(lst)
"CppFormat(key,value)
"CollectFunc()
"CppTraitsFunc()
"HighlightOpenGL()
"MapKey(name,first)
"PageDown(winid)
"PageUp(winid)
"MarkWin()
"UpdateTags()
"FindWordInDict(w,n)
"FindWordClass(w)
"CompleteWord()
"FindWordTag(w)
"ProcessTagItem(item)
"FindRWord(s)
"GetFuncDeclare(lines,pos)
"SearchAndInsertFunc(lines,classname)
"LocateFunc(line)
"UpdateClassFunc()
"OpenBuffer(name)
"InsertFunc(a,n)
"InsertClass()
"InsertSnipplet()
"FindSnippletName(name)
"AddYankToSnipplets()
"AddToSnipplets(lines)

func! MyTest(a)
    echo a:a
endf
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
    let g:MyJumped = 0
    call Map()
endif

let g:CollectFlag = 0
let  s:FucCache =[]
func! TransCode(c)
    let t = substitute(a:c,'\/\/','\\\/\\\/','g')
    let t= substitute(t,'\~','\\\~','')
    " just add \ to * 
    let t= substitute(t,'\*','\\\*','g')
    " add [] 
    let t= substitute(t,'[','\\\[','g')
    let t= substitute(t,']','\\\]','g')
    return t
endfunc

func! InsertHead(lst)
    let l = a:lst
    call cursor(1,1)
    call reverse(l)
    for a in l
       " search need some  transcode
       let t = TransCode(a['func'])
        if search(t,'nW') > 0
            continue
        endif
        call append(line('.'),a['func'])
        let g:CollectFlag =0
    endfor 
endfunc

func! CppFormat(key,value)
    let ss = a:value
    let ss = substitute(ss,'\n\+\|\t\+',' ','g')
    let ss = substitute(ss,'\s\+',' ','g')
    let ss = substitute(ss,'\s\+(','(','g')
    let ss = substitute(ss,'(\s\+','(','g')
    let ss = substitute(ss,'\s\+)',')','g')
    let ss = substitute(ss,')\s\+',')','g')
    let ss = substitute(ss,'{\|}','','g')
    return ss
endfunc

func! CollectFunc()
   if (&mod == 0) && (g:CollectFlag == 1)
        return s:FucCache
    endif
    "before { that could be \n and )  and spaces
    "let pat = '^\w\+\([^;]\+\n\?\)\+)[\n]*\s*{'
    let pat = '^\w\+\([^;)]\+\n\?#\?\)\+)\([\n]\|#\w\+\)*\s*{'
    let lst=[]
    call cursor(1,1)
    let s =''
    while search(pat,'W') > 0
        let n = line('.')
        let first = n
        while 1
            let line = getline(n)
            if matchstr(line,'{') != ''
                let s = s . line
                let s = '//' . s
                let s = CppFormat(0,s)
                let res = {'func':s,'row':first}
                call add(lst,res)
                let s = ''
                break
            endif
            " func() 
            " #endif
            " {
            if matchstr(line ,'^#') ==''
                let s = s .' ' . line
            endif
            let n += 1
        endwhile
        call cursor(n,1)
    endwhile
    let s:FucCache = lst
    let s:CollectFlag = 1
    return lst
endf

func! CppTraitsFunc()
    call cursor(1,1)
    let line = getline('.')
    if matchstr(line,'TRAITS') == ''
        call append(line('.') - 1,'//TRAITS')
    endif
    let lst = CollectFunc()
    call InsertHead(lst)
endfunc

function! HighlightOpenGL()
    syntax keyword glType attribute varying uniform in out
    syntax match glType /vec[234]/
    syntax match glType /mat[234]/
    syntax match glStatement /^#\a\+/
    highlight link glType Type
endf

function! HighlightC()
    "syntax keyword glType attribute varying uniform in out
    syntax keyword glType uchar ushort uint ulong cch
    highlight link glType cType
endf

if exists("g:OpenGL")
    call HighlightOpenGL()
else
    call HighlightC()
endif
au BufWrite :let g:CollectFlag=0



"set path+=/usr/include/c++/7/
"set path+=/usr/include/x86_64-linux-gnu/c++/7/
imap <DOWN> <S-DOWN>
imap <F2> <Esc>:call InsertClass()<CR>
imap <F4> <Esc>:w<CR>:call UpdateClassFunc()<CR>
imap <F5> <C-R>=CompleteWord()<CR>
imap <F10> <Esc>:call InsertSnipplet()<CR>
imap <F12> <Esc>:w<CR>:make<CR>
imap <Left> <Esc>:call PageUp(g:MarkWinId)<CR>a
imap <Right> <Esc>:call PageDown(g:MarkWinId)<CR>a
imap <UP> <S-UP>

map <DOWN> <S-DOWN>
map <F4> :w<CR>:call UpdateClassFunc()<CR>
map <F5> :call MarkWin()<CR>
map <F7> :call AddYankToSnipplets()<CR>
map <F10> :call CppTraitsFunc()<CR>
map <F12> :w<CR>:make test<CR>
map <Left> :call PageUp(g:MarkWinId)<CR>
map <Right> :call PageDown(g:MarkWinId)<CR>
map <UP> <S-UP>
set completefunc=CompleteClassFunction
set completeopt=menu,noinsert,preview
set path+=/usr/include/GL
set path+=/usr/include/x86_64-linux-gnu/c++/7
set path+=/usr/local/include/

func! MapKey(name,first)
    let s = ':inoremap ' . a:name . ' ' . a:first .' <Esc>o{}'.'<UP><UP><Esc>f(a'
    exec s
endfunc

call MapKey(',if','if ()')
call MapKey(',for','for ()')
call MapKey(',sw','switch ()')

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
    "let g:cppCmd = 'cpp a.cpp -o my.cpp'
    let g:cppCmd='ctags -R --extra=+q  --fields=+a+S --c++-kinds=cdfmnps --language-force=c++ /usr/include/c++/7/*'
    let g:cppCmdAdd='ctags --extra=+q  --fields=+a+S -a  --c++-kinds=cdfmnps --language-force=c++ *.h *.cpp'
    "let g:ctagsCmd = 'ctags --extra=+q --fields=+a+S  --c++-kinds=mcfp --language-force=c++ my.cpp '

    execute "!".g:cppCmd
    "execute "!".g:ctagsCmd
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
        let line =  substitute(line,'&',"",'g')
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
    let l = len(g:restword)
    let ft = 'v:val["word"] =~ "^' . g:restword . '"'
    call filter(result,ft)
    call complete(col('.')-l,result)
    "call feedkeys(g:restword)
    return ''
endf

func! FindWordTag(w)
    let s:className = a:w
    let popList = []
    let ss = []
    for a in readfile('tags')
        let flag=0
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

func! ProcessTagItem(item)
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
    if  c < 0 
        let c= strridx(s,'>')
        if  c > 0 
            if  s[c-1] == '-'
                let  c -= 1
            endif
        endif
    endif 
    if c < 0 
        let c = FindRWord(s)
        let s = strpart(s,c,len(s))
        let g:restword  = substitute(s,'\s*','','g')
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

func! GetFuncDeclare(lines,pos)
    let nLines = len(a:lines)
    "need first add 1
    let i = a:pos - 1
    let s = ''
    let result={}
    let flag = 0
    let flag_p=0
    "0 - (nlines-2)
    while( i <= nLines - 2)
        let i = i + 1
        let a = a:lines[i]
        let a = substitute(a,'//.*','','g')
        if  a == "" 
            continue
        endif
        if matchstr(a,":\s*$") !=""
            continue
            let s=''
        endif
        let ct = 0
        let ct = matchend(a,'{',ct) 
        while ( ct != -1) 
            let ct = matchend(a,'{',ct) 
            let flag += 1
            let flag_p=1
        endwhile
        let ct = matchend(a,'}',ct) 
        while ( ct != -1 ) 
            let ct = matchend(a,'}',ct) 
            let flag -= 1
            let flag_p=1
        endwhile
        if flag > 0  || flag_p == 1
            let flag_p = 0
            continue
        endif
        let s = s . a
        if matchstr(s,';\s*$') != ''
            " must i + 1
            let result = {'func':s,'pos':i + 1,'result':'yes'}
            return result
        endif
    endwhile
    let result = {'func':s,'pos':i,'result':'no'}
    return result
endfunc

func! SearchAndInsertFunc(lines,classname)
    let templatelist=[]
    let pos = 0
    
    while(1) 
        let result = GetFuncDeclare(a:lines,pos)
        if result['result'] == 'yes' 
            let pos = result['pos']
            let s = result['func']
            if match(s,"template") >= 0
                call add(templatelist,s)
            else
                call InsertFunc(s,a:classname)
            endif
        else
            break
        endif 
        let s = ''
    endwhile
    return templatelist
endfunc

func! LocateFunc(line)
    let row = line('.')
    let ss = a:line
    if matchstr(ss,'^\/\/') ==''
        exec "normal 'a"
        let g:MyJumped = 0
        return
    endif
    " something can't return
    let g:MyJumped = 1
    exec 'normal ma'
    " big fault
    let t = TransCode(ss)
    let l = CollectFunc()
    for a in l
        if matchstr(a['func'],t) != ''
            call cursor(row,1)
            call cursor(a['row'],1)
            break
        endif
    endfor
endfunc

function! UpdateClassFunc()
    " if  no search find return 0
    let cur= line('.')
    let saveline = getline('.')
    let savebufname = bufname("")
    let result = search('^\s*class\s\+.*','bW') 
    if  result == 0 || g:MyJumped == 1
        call cursor(cur,1)
        call LocateFunc(saveline)
        return 
    endif
    let classname = getline(".")
    let clsname = matchlist(classname,'class\s\+\(\a\+\)')
    let cname=""
    if len(clsname) > 0
        let cname = clsname[1]
    else
        return
    endif
    call search('{')
    let s:begin  = line(".") + 1
    let cursor = cur - s:begin
    exec "normal " . "%"
    let s:end = line(".") - 1
    let lines = getline(s:begin,s:end)
    call cursor(cur,1)
    let cppFile = expand('%<') . ".cpp"
    let curFile = expand('%')
    call UnMap()
    if cppFile != curFile 
        "call OpenBuffer(cppFile)
    endif
    let flag = 0
    let templatelist = []
    let s:templateFind = 0
    let templatelist = SearchAndInsertFunc(lines,cname)
        if (len(templatelist) > 0)
            call OpenBuffer(savebufname)
            let s:templateFind = 1
            for a in templatelist
                call InsertFunc(a,cname)
            endfor
        endif
    if match(saveline,"template") >=0 
        call OpenBuffer(savebufname)
    else
        if  match(cppFile,savebufname) >= 0 

        else
            call OpenBuffer(cppFile)
        endif
    endif
    let f =   GetFuncDeclare(lines,cursor)
    let other =FindClassFuncLocation (f['func'],cname)
    if other == 'no'
        if  match(cppFile,savebufname) < 0 
            call OpenBuffer(savebufname)
        endif
        let f =   GetFuncDeclare(lines,cursor)
        let other =FindClassFuncLocation (f['func'],cname)
    endif
    call search(other)

    "call search(cname)
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
    "not add include to self
    if (search(inc) == 0)  && (bufname("") != fname .'.h')
        call append(line('.')-1,inc)
    endif
endfunction

func! FindClassFuncLocation(a,n)
    let l = substitute(a:a,'\s*(\s*','(','g')
    let l = substitute(l,'operator\s\+','operator','g')
    let l = substitute(l,'\s\+',' ','g')
    let l = substitute(l,'^\s','','g')
    let l = substitute(l,'\s*)\s*',')','g')
    let l = substitute(l,'\s*)\s*',')','g')

    let l = matchlist(l,'[ \t]*\(.*\)[ ]\([^( ]\+\)\((.*\);')
    if len(l) < 1 
        let l = matchlist(a:a,'\([ \t]*\)\([^( ]\+\)\((.*\);')
        if  len(l) > 2
            let l[1] = ""
        endif
    else
        let l[1] = l[1] . " " 
    endif
    if len(l) > 2 
        let l[2]  = substitute(l[2],'^\s*','','')
        let l[3]  = substitute(l[3],'^\s*','','')
        if  l[1] =~ "friend"
            let p = substitute(l[1],'friend','','')
            let target = p . l[2].l[3]
        else
            let target = l[1] . a:n . "::" . l[2] . l[3] 
        endif
        let s:target= substitute(target,'^\s*','','')
        let other = substitute(target,'\~','\\\~','')
        " just add \ to * 
        let other = substitute(other,'\*','\\\*','g')
        if search(other,'nw')
            return other
        endif
        return 'no'
    endif
endfunc
"a : function name
"n : classname
function! InsertFunc(a,n)
    if matchstr(a:a,')\s*;') == ""  
        return
    endif
    if FindClassFuncLocation(a:a,a:n) == 'no'
        exec "normal G"
        let lst=[]
        if search('//'. toupper(a:n) . ' BEGIN','w')  == "" 
            let lst = [   '//' . toupper(a:n) . ' BEGIN',
                        \ s:target,
                        \ '{',
                        \ '}',
                        \ '//' . toupper(a:n) . ' END' ]
            if s:templateFind == 1
                call cursor(s:end + 1,1)
            endif
        else
            let lst = [  s:target,
                        \ '{',
                        \ '}']
        endif
        call append(line('.'),lst)
    endif
endfunction

function! InsertClass()
    let s:name = input("type class name : ")
    if  s:name == ''  
        return 
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
                \ '' . s:name . "(){};",
                \ '' . s:name . "(const ". s:name . "& s) = delete;",
                \ '' .s:name . "& operator=(const ". s:name . "& s) = delete;",
                \ '~' . s:name . "(){};",
                \ 'public:',
                \ '//maniulator',
                \ '//accessor',
                \ '};' ]

    call append(line('.') - 1,lst)
    call search(s:name)
    exec "normal " . string(len(lst) + 1) . '=='
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
    if sn == ''
        return
    endif
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
    if  len(a:lines) < 3 
        echo "too small snipplet"
        return 
    endif
    let snipname = input("input snip name:")
    if snipname == ''
        return 
    endif
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
