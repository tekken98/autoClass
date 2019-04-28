if did_filetype()
	finish
endif
if getline(1) =~ 'C++'
	setfiletype cpp
elseif getline(1) =~ 'vim:\s\+ft=cpp'
    setfiletype cpp
elseif getline(1) =~ 'vim:\s\+ft=opengl'
    let g:OpenGL = 1
    setfiletype cpp
endif
