syntax match fun "\(<SID>\)\?\w\+("he=e-1  display contained 
syntax match fu "(.*)"  contained 
syn cluster vimCommentGroup add=fun
highlight link fun Type
