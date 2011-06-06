" Vim filetype plugin file
" Language:	    XQuery
" Maintainer:	David Lam <dlam@dlam.me>
" Last Change:  2011 Jun 2
"
" Notes: 
"    -Makes keys like gd and <C-]> work better when editing XQuery files 
"     by temporarily adding the hyphen - to the 'iskeyword' variable
"     (one could add it to 'iskeyword' permanently... but that makes the 
"     basic movement keys move a bit too far)
"
"    -Sets options that are useful when editing XQuery (like 'set comments')

"    -Sets a few variables to make matchit.vim and taglist.vim work 
"     better with XQuery
"
"    -Sets the omnicomplete function to xquerycomplete.vim, which completes 
"     XQuery keywords and function names from 
"     http://developer.marklogic.com/learn/4.1/api-reference
"


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
"  finish
   delfunction xqueryft:XQueryTag
   delfunction xqueryft:XQueryGotoDeclaration
   delfunction xqueryft:Star
   delfunction xqueryft:BracketI
endif
let b:did_ftplugin = 1

" http://markmail.org/message/5vfzrb7ojvds5drx
autocmd InsertEnter *.xqy,*.xql,*.xqe,*.xq set iskeyword+=-
autocmd InsertLeave *.xqy,*.xql,*.xqe,*.xq set iskeyword-=-
"imap <C-c> <ESC>   "Because <C-c> dosent trigger InsertLeave (see help) 
inoremap <C-c> <C-c>:set isk-=-<cr>

"12/1/2010  Because XQueryTag() does not trigger InsertLeave when you come back
"           to the buffer you made the jump in via i_Ctrl-T or i_Ctrl-O or something
autocmd BufEnter *.xqy,*.xql,*.xqe,*.xq set iskeyword-=-   

if !exists("*xqueryft:XQueryTag")
    function! xqueryft:XQueryTag(is_tjump)
     
      set iskeyword+=-

      let l:is_xqVariable = synIDattr(synID(line('.'), col('.'), 0), "name") == 'xqVariable'

      let l:word_at_cursor = expand("<cword>")
      let l:WORD_at_cursor = expand("<cWORD>")

      "remove the namespace: part from word_at_cursor
      
      let l:dollar_index = match(l:word_at_cursor, '$')
      let l:colon_index  = match(l:word_at_cursor, ':')
      let l:word_at_cursor_without_namespace = strpart(word_at_cursor, l:colon_index)

      " if l:word_at_cursor appears to be a function namespace, set it to be
      " the function name so we can tagjump to it
      "
      if matchstr(l:WORD_at_cursor, l:word_at_cursor.':') != ""

        let l:orig_col = getpos('.')[2]
        call search(':')
        let l:word_at_cursor = expand("<cword>")
        " go back to where we were
        call cursor(line('.'), l:orig_col)
      endif
    
      " finally... do the tag jump 

      let l:tagtojumpto = (colon_index != -1) ? l:word_at_cursor_without_namespace :  l:word_at_cursor

      exec (a:is_tjump ? "tjump " : "tag ") . l:tagtojumpto

      set iskeyword-=-
    endfunction
endif

"  :h gd     
"  :h searchdecl()     searchdecl(expand("<cword>"), 0, 0)
"
if !exists("*xqueryft:XQueryGotoDeclaration")
    function! xqueryft:XQueryGotoDeclaration(is_goto_global)
      set iskeyword+=- | let @/='\<'.expand('<cword>').'\>' | set iskeyword-=- 

      if a:is_goto_global
        call searchdecl(@/, 1, 0)
      else
        call searchdecl(@/, 0, 0)
      endif

      "execute "match Search /" . @/ . "/"
      normal n
      normal N
    endfunction 
endif


if !exists("*xqueryft:Star")
    function! xqueryft:Star(goforward)
        set iskeyword+=- | let @/='\<'.expand('<cword>').'\>' | set iskeyword-=- 
        if a:goforward
            normal! n 
        else 
            normal! N
        endif
    endfunction
endif

if !exists("*xqueryft:BracketI")

    function! xqueryft:BracketI(iscapital)
        set iskeyword+=- 

        " TODO  find function equivalent for [i and [I 

        set iskeyword-=- 
    endfunction
endif


"  these from :h write-filetype-plugin
"
" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_mail_maps")

    if !hasmapto('xqueryft:XQueryTag')
        noremap <buffer> <C-]> :call xqueryft:XQueryTag(0)<CR>
        noremap <buffer> g<C-]> :call xqueryft:XQueryTag(1)<CR>
    endif

    if !hasmapto('xqueryft:XQueryGotoDeclaration')
        noremap <buffer> gd :call xqueryft:XQueryGotoDeclaration(0)<CR>
        noremap <buffer> gD :call xqueryft:XQueryGotoDeclaration(1)<CR> 
    endif

    if !hasmapto('xqueryft:Star')
        noremap <buffer> # :call xqueryft:Star(0)<CR>
        noremap <buffer> * :call xqueryft:Star(1)<CR>
    endif

"     if !hasmapto('xqueryft:BracketI')
"         noremap <buffer> [i :call xqueryft:BracketI(0)<CR>
"         noremap <buffer> [I :call xqueryft:BracketI(1)<CR>
"     endif

endif

" Comment blocks always start with a (: and end with a :)
" Works for XQDoc style start comments like (:~ too.
setlocal comments=s1:(:,mb::,ex::)
setlocal commentstring=(:%s:)

" Format comments to be up to 78 characters long  (from vim.vim)
if &tw == 0
  setlocal tw=78
endif

" Set 'formatoptions' to break comment lines but not other lines,  
" and insert the comment leader when hitting <CR> or using "o".     
"    see...  :h fo-table
setlocal formatoptions-=t formatoptions+=croql


if exists('&ofu')
  setlocal omnifunc=xquerycomplete#CompleteXQuery
endif

" from html.vim
if exists("loaded_matchit")
    let b:match_ignorecase = 1
    let b:match_words = '<:>,' .
    \ '(:),' .
    \ '{:},' .
    \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
    \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
    \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif

" :h matchit-extend  or...  http://vim-taglist.sourceforge.net/extend.html
"
"    Also, try 'ctags --list-kinds=all'   to see all the params for different
"    languages that you can pass in to this variable!
let tlist_xquery_settings = 'xquery;m:module;v:variable;f:function'

let b:undo_ftplugin = 'setlocal formatoptions<'
		\  . ' comments< commentstring< omnifunc<'
        \  . ' shiftwidth< tabstop<' 


" vim:sw=4 fdm=marker tw=80
