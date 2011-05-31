" Vim filetype plugin file
" Language:	XQuery
" Maintainer:	David Lam <dlam@dlam.me>
" Last Change:  2010 Jun 30
" URL:		 
"
" Notes: 
"    Makes gd, gD, <C-]> work right for XQuery!
"
" Links:
"    http://www.xqdoc.org/xquery-style.html
"    :h usr_41.txt   or  :h script
"
" Todo:
"    - 2/18/2011  b:undo_ftplugin needs to remove mappings too
"    - 3/4/2011   xqueryft:XQueryGotoDeclaration  needs to highlight 
"                 the word like xqueryft:Star does
"    - 3/8/2011   :h b:match_words
"    - 5/18/2011  <C-w> ] 
"

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  "finish
  delfunction xqueryft:XQueryTag
endif
let b:did_ftplugin = 1

runtime indent/xquery.vim

" http://markmail.org/message/5vfzrb7ojvds5drx
autocmd InsertEnter *.xqy,*.xql,*.xqe,*.xq set iskeyword+=-
autocmd InsertLeave *.xqy,*.xql,*.xqe,*.xq set iskeyword-=-
"imap <C-c> <ESC>   "Because <C-c> dosent trigger InsertLeave (see help) 
inoremap <C-c> <C-c>:set isk-=-<cr>

"12/1/2010  Because XQueryTag() does not trigger InsertLeave when you come back
"           to the buffer you made the jump in via i_Ctrl-T or i_Ctrl-O or something
autocmd BufEnter *.xqy,*.xql,*.xqe,*.xq set iskeyword-=-   

"   11/30/2010  
"
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

        "echomsg '/ftplugin/xquery.vim:63  l:orig_col:' . string(l:orig_col)

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

endif


" :h matchit-extend  or...  http://vim-taglist.sourceforge.net/extend.html
"
"    Also, try 'ctags --list-kinds=all'   to see all the params for different
"    languages that you can pass in to this variable!
let tlist_xquery_settings = 'xquery;m:module;v:variable;f:function'


" Comment blocks always start with a (: and end with a :)
" Works for XQDoc style start comments like (:~ too.
setlocal comments=s1:(:,mb::,ex::)
setlocal commentstring=(:%s:)

" for html tags?
"setlocal matchpairs+=<:>

" Format comments to be up to 78 characters long  (from vim.vim)
if &tw == 0
  setlocal tw=78
endif

" when doing indents using indentexpr=XQueryIndentGet, 
" use two spaces of indentation...!
setlocal shiftwidth=2

" Set 'formatoptions' to break comment lines but not other lines,  
" and insert the comment leader when hitting <CR> or using "o".     
"    see...  :h fo-table
setlocal formatoptions-=t formatoptions+=croql


if exists('&ofu')
  "  :h ft-syntax-omni
  " setlocal omnifunc=syntaxcomplete#Complete
  setlocal omnifunc=xquerycomplete#CompleteXQuery
endif

" copied from html.vim!
"   7/14/2010   Added b:match_words that match parens and brackets
"  
if exists("loaded_matchit")
    let b:match_ignorecase = 1
    let b:match_words = '<:>,' .
    \ '(:),' .
    \ '{:},' .
    \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
    \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
    \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif

" 8/27/2010   :h undo_ftplugin
let b:undo_ftplugin = 'setlocal formatoptions<'
		\  . ' comments< commentstring< omnifunc<'
        \  . ' shiftwidth< tabstop<' 
