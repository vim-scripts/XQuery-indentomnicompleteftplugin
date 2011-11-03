" Vim indent file
" Language: xquery
" Maintainer:   david lam <dlam@dlam.me>
" Last Change:  2011 Jun 2
" Notes:    1) http://xqdoc.org/xquery-style.html   
"           2) http://xqdoc.org/xquery-style.pdf  (see ch.3 Indentation)
"           3) http://www.w3.org/TR/xquery/#id-grammar
"           4) :h v:var
"           5) :h expr-'
"  
" 
" Hacky indent script which attempts to conform to the 
" 'XQuery Style Conventions' here: http://xqdoc.org/xquery-style.html
"
" The indentation will generally work better when 
" FLOWR expressions are wrapped with parenthesis.
"
"   e.g.
"        let $hello := (
"          for $foo in $bars
"          return
"             $doo
"        )
"
"   vs. 
"        let $hello := for $foo in $bars
"                      return $doo
"
"
" Certain keywords like for/let/where/order/return/else will automatically
" indent to the correct location when typed out.
"
"

if exists("b:did_indent")
"    finish
     delfunction XQueryIndentGet
     delfunction s:StartsWithKeyword
     delfunction s:StartColumn
     delfunction s:PrevnonblankStartingWithXQueryKeyword
     delfunction s:PrevnonblankIgnoringComments
endif

runtime! indent/xml.vim

let b:did_indent = 1

setlocal autoindent  "usually people just line FLOWR's up etc.
setlocal indentexpr=XQueryIndentGet()
setlocal indentkeys=!^F,0(,0),0{,0},o,O,e,0=for,0=let,0=where,0=order,0=return,0=else,0=or,0=and

" for a closing </xmlTag>
setlocal indentkeys+=/

" OPTIONS
let g:xquery_use_xml_indent = 1

"  When the previous line starts/ends with these words, the next
"  line should be indent to the right 
"  
let s:xquerystartinwords = ['typeswitch', 'case', 'default']
let s:xqueryendinwords = ['return', 'then', 'else', ':=', '(', '{']

"  XQindent#MAXLOOKBACK: 
"  The maximum number of lines to lookback when trying to do indentation based
"  on context
"
"     XXX  5/2/2011 Decreasing this value from 10 may cause tests to fail, like #2
"
let s:MAXLOOKBACK = 10


" XQindent#XQueryIndentGet: 'indentexpr' for XQuery!"{{{
"
"       The expression must return the number of spaces worth of indent.
"  TODO It can return "-1" to keep the current indent 
"       (this means 'autoindent' is used for the indent).
"
function! XQueryIndentGet() 
      
    "\+ at end to require something in the assignment
    let l:STARTS_WITH_IF_OR_ELSE_IF_PAT   = '^\s*\<\%[else ]if\>'
    let l:ELSE_OR_ELSE_IF_PAT             = '^\s*\<else\%[ if]\>' 
    let l:STARTS_WITH_AND_OR_OR           = '^\s*\<\%(and\|or\)\>'
    let l:STARTS_WITH_RETURN              = '^\s*\<return\>'
    let l:STARTS_WITH_DECLARE             = '^\s*\<declare\>'
    let l:STARTS_WITH_DECLARE_FUNCTION    = '^\s*\<declare\>\s*\<function\>'
    let l:STARTS_WITH_IMPORT              = '^\s*\<import\>'

    let l:ENDS_WITH_THEN_PAT              = 'then\s*\%[(]\s*$'
    let l:INDENT_RIGHT_ENDING_PAT   = '\%(\<return\>\|\<then\>\|\<else\>\|\<order by\>\|:=\|(\|{\)\s*$' 
    let l:INDENT_RIGHT_STARTING_PAT = '^\s*\<\%(typeswitch\|case\|default\)\>' 
    let l:FLOWR_IN_RHS_PAT          = '^\s*\<let\>.*:=\s*\<\%(for\|let\)\>'

    " if the previous line was an assignment that should be continued on the next line,
    " so we want to align one &sw after the := 
    "
    "    FIXME 3/24/2011 Replace >  with a regex for an opening tag, ex. <open>
    "
    "     <[^/]\+> - pattern for a closing tag
    " 
    let l:OPEN_ASSIGNMENT_PAT = '^.\+:=.*\%(then\|<[^/]\+>\|{\)\s*$'
    let l:OPEN_SEQUENCE_PAT = '[[:alnum:]$:-]*([[:alnum:]$:_-]*,\s*$'

    let l:ASSIGNMENT_EQUALS_PAT = ':='
    let l:STARTS_WITH_TYPESWITCH_CASE_OR_DEFAULT_PAT = '^\s*\<\%(default\|case\)\>'
    let l:STARTS_WITH_THEN_PAT = '^\s*\<then\>'
    let l:PARAM_LIST_PAT = '(.*[^)],\s*$' 
    let l:LONE_CLOSING_PAREN_OR_BRACKET_PAT = '^\s*[)}]\%[;]\s*$'  " :h \%[]
    let l:CLOSING_PARENS_OR_BRACKETS_AT_START_OF_LINE_PAT = '^\s*[)}]\+'

    "let l:OPENING_$XML_TAG = '.\{-}<\a'  "these from $VIMRUNTIME/indent/xml.vim:23
    "let l:CLOSING_XML_TAG = '.\{-}</'
    let l:OPENING_XML_TAG = '^\s*<[^/]'  
    let l:CLOSING_XML_TAG = '^\s*</'

    let l:ENDS_WITH_COMMA_PAT = ',\s*$'


    " Search backwards for the previous non-empty line.
    let l:immediate_plnum = prevnonblank(v:lnum-1)
    let l:plnum = s:PrevnonblankIgnoringComments(v:lnum-1)
    let l:line  = getline(v:lnum)
    let l:pline = getline(l:plnum)
    let l:autoindent = indent(l:plnum) == -1 ? 0 : indent(l:plnum)

    " let l:syn_id_attr   = synIDattr(synID(v:lnum, col('.'), 0), "name")
    " let l:p_syn_id_attr = synIDattr(synID(l:plnum, col('.'), 0), "name")

    let l:start_col_syn_id_attr =
        \ synIDattr(synID(v:lnum, s:StartColumn(v:lnum), 0), "name")
    let l:p_start_col_syn_id_attr =
        \ synIDattr(synID(l:plnum, s:StartColumn(l:plnum), 0), "name")

    echomsg "/indent/xquery.vim:135  Entered XQueryIndentGet()" . "  v:lnum: " . v:lnum  . "  col: " . col('.')  . "  l:plnum: " . l:plnum . "  l:start_col_syn_id_attr: " . l:start_col_syn_id_attr . "  l:P_start_col_syn_id_attr: " . l:p_start_col_syn_id_attr  . "  l:line: " . l:line

    if l:immediate_plnum == 0
        " This is the first non-empty line, use zero indent.
        return 0    

    elseif l:line =~ l:STARTS_WITH_IMPORT  || l:line =~ l:STARTS_WITH_DECLARE
        echomsg "/indent/xquery.vim:142  Lines starting with declare/import should always have 0 indentation"
        return 0 

    elseif l:start_col_syn_id_attr == 'xqComment' || l:line =~ '^\s*:'

        echomsg '/indent/xquery.vim:147   Not changing indent for comment'
        return -1

    elseif l:line =~ '^\s*{'

        echomsg '/indent/xquery.vim:152  (test #9)  Autoindenting unconditionally'

        return l:autoindent

    elseif l:pline =~ l:ENDS_WITH_COMMA_PAT

        if l:pline =~ '^\s*\<let\>.*:='

            echomsg '/indent/xquery.vim:160  (test #8)  Previous line had a let followed by a := so indent right one &sw' 
            return l:autoindent + &sw

        elseif l:pline =~ l:OPEN_SEQUENCE_PAT

            echomsg "/indent/xquery.vim:165  Previous line was a open function call or open sequence, so shift right once (note: could also align param list)"
            return l:autoindent + &sw

        elseif l:pline =~ '^\s*\<for\>'

            echomsg '/indent/xquery.vim:170  ends-with-comma-but-starts-with-a-for'
            return matchend(l:pline, '\<in\>') + &sw + 3

        elseif l:pline =~ l:STARTS_WITH_DECLARE

            echomsg '/indent/xquery.vim.175  Aligning function or variable arguments'
            return matchend(l:pline, '(') 
        else
            echomsg "/indent/xquery.vim:178  pline ends with a comma, so autoindent"
            return l:autoindent
        endif

    elseif l:line =~ l:CLOSING_PARENS_OR_BRACKETS_AT_START_OF_LINE_PAT 

        " Align with the matching opening paren or bracket 
        " when ) or } indentkeys' above)
        " (note: vim uses \+ instead of + for the metacharacter)
        "
        "    TODO find a better way than doing 'normal x' to 
        "         reposition cursor on the paren...
        normal x
        "cursor(getpos('.')[1], getpos('.')[2]-1)

        try 
            if l:line =~ '^\s*)\+'
                let [m_lnum, m_col] = searchpairpos('(', '', ')', 'bnW')
            else
                let [m_lnum, m_col] = searchpairpos('{', '', '}', 'bnW')
            endif

            let l:rhs_paren_or_bracket_indent = 
              \ matchend(getline(m_lnum), l:ASSIGNMENT_EQUALS_PAT) + 1

            if getline(m_lnum) =~ l:STARTS_WITH_AND_OR_OR

                "If in a wrapped if expression, the matching opening paren
                "is probably on a different line, so find that one instead
                "and indent to it.

                let [if_lnum, if_col] = searchpos('^\s*if'  ,'bnW') 
                return s:StartColumn(if_lnum)

            elseif l:rhs_paren_or_bracket_indent == 0
                        \ || getline(m_lnum) =~ '[({]\+'
              let l:paren_indent = s:StartColumn(m_lnum) 
            else 
              let l:paren_indent = l:rhs_paren_or_bracket_indent
            endif

            echomsg '/indent/xquery.vim:219  indenting via searchpairpos()... ' . 'm_lnum: ' . string(m_lnum) . '  m_col: ' . string(m_col) . '  character under cursor: ' . getline('.')[col('.')] . '  l:paren_indent ' . l:paren_indent

        catch
            echomsg "/indent/xquery.vim:222   Exception! " . v:exception  . "  v:throwpoint:" . v:throwpoint
        endtry

        return l:paren_indent

    elseif l:line =~ l:ELSE_OR_ELSE_IF_PAT
                \ && l:pline !~ l:LONE_CLOSING_PAREN_OR_BRACKET_PAT

        " 3/11/2011  Indent if/else/elseif 
        "
        " The second test above ^^ for lone closing parent or bracket  
        " helps 'fix' blocks with deeply nested if/else if/else expressions 
        " (see #8 in INDENT_TESTS)

        let l:if_else_lnum = searchpair('\<if\>', '\<else if\>', '\<els\>', 'bnW')

        let l:if_col = match(getline(l:if_else_lnum), '\%[else ]if')

        echomsg '/indent/xquery.vim:240  Current line STARTS WITH an "else" or "else if", so indenting to the closest "if" or "else if" since they should align...   l:if_else_lnum:' . string(l:if_else_lnum) . '   l:if_col:' . string(l:if_col)

        return l:if_col

    elseif l:pline =~ l:FLOWR_IN_RHS_PAT

        echomsg "/indent/xquery.vim:246  Aligning FLOWR in rhs of LetClause"
        return matchend(l:pline, l:FLOWR_IN_RHS_PAT) - 3

    elseif l:pline =~ l:OPEN_ASSIGNMENT_PAT

        echomsg "/indent/xquery.vim:251 rhs looked like an 'open assignment', so align one space after the :="
        return matchend(l:pline, l:ASSIGNMENT_EQUALS_PAT) + &sw + 1

    elseif l:pline =~ l:INDENT_RIGHT_ENDING_PAT 
                \ || l:pline =~ l:INDENT_RIGHT_STARTING_PAT

        if l:pline =~ l:FLOWR_IN_RHS_PAT
            " 3/11/2011 find the := and start the indentation from there instead
            echomsg '/indent/xquery.vim:259  Let with an expression in the rhs, so indent to the right of the :='
            return matchend(l:pline, ':=') + &sw
        else 
            echomsg '/indent/xquery.vim:262  Previous line STARTED OR ENDED WITH a word or character where the next line should be indented RIGHT: ' . l:pline

            return l:autoindent + &sw 
        endif

    elseif s:StartsWithKeyword(l:plnum) && l:pline =~ l:PARAM_LIST_PAT
        
        " Align with previous sequence or ParamList if the line ends with 
        " a comma and starts with a keyword:
        "   
        "   let $gogoog := some:function('asdfsadF',
        "                                'ASfdasdF'

        echomsg "/indent/xquery.vim:275   Aligning with what might be a " . "ParamList or Sequence expression in the previous line  l:pline:"

        let l:column_before_opening_paren = match(l:pline, l:PARAM_LIST_PAT)
        return l:column_before_opening_paren + 1

    elseif (l:start_col_syn_id_attr =~ 'xml' || l:line =~ l:OPENING_XML_TAG || l:pline =~ l:OPENING_XML_TAG)
                \ && l:line !~ '^\s*{'
                \ && l:pline !~ l:LONE_CLOSING_PAREN_OR_BRACKET_PAT
                \ && l:plnum > 0

        " If we're within a tag, use $VIMRUNTIME/indent/xml.vim to indent  
        "
        "   4/4/2011  Note: DO NOT remove the l:pline comparison, its there 
        "             so it idents correctly after hitting enter after a tag

        if exists('*XmlIndentGet') 
            let xml_indent = XmlIndentGet(v:lnum,1)
            echomsg "/indent/xquery.vim:292 (test #'s 2 & 10 & 12)  Indenting w/ XmlIndentGet: " . xml_indent .  '    l:plnum:' . l:plnum
            return xml_indent
        else 
            return -1
        endif

    elseif l:line =~ l:STARTS_WITH_TYPESWITCH_CASE_OR_DEFAULT_PAT 
        
        " If inside a typeswitch, we want to align the case/default statements
        " instead of autoindenting.  l:INDENT_RIGHT_STARTING_PAT takes care of 
        " the initial typeswitch line

        echomsg '/indent/xquery.vim:304   Aligning case statements in typeswitch'

        let [l:pline_with_case, l:pcol_with_case] = searchpos('case', 'bnW')

        if l:pline_with_case == 0
            return -1
        else 
            return s:StartColumn(l:pline_with_case)
        endif

    elseif l:line =~ l:STARTS_WITH_THEN_PAT

        echomsg '/indent/xquery.vim:316  Line begins with then, align with if in pline   ' . l:plnum

        return match(l:pline, '\<if\>')


    elseif getline(l:immediate_plnum) =~ '^\s*:)\s*$'

        let ind = indent(l:immediate_plnum)

        echomsg '/indent/xquery.vim:325  immediate previous line was the end of a block comment end, so subtract one  ' . ind

        return ind == 0 ? 0 : ind - 1 
    else 
        " Do indentation based on the last line STARTING WITH AN XQuery KEYWORD  

        echomsg '/indent/xquery.vim:331   In final else() block!'

        let l:pwq_lnum = s:PrevnonblankStartingWithXQueryKeyword(v:lnum, v:lnum-1, 0)
        let l:start_col = s:StartColumn(l:pwq_lnum)

        if getline(l:pwq_lnum) =~ l:STARTS_WITH_DECLARE_FUNCTION
                    \ && l:pline !~ '[,]\s*$'

            echomsg '/indent/xquery.vim:339  Supposedly in function declaration, so do not perform indent'
            return -1
        else

            echomsg '/indent/xquery.vim:343  IN ELSE BLOCK - No indentation rules were met, so align with the previous line, or one that starts with an xquery keyword    l:start_col: ' . l:start_col . '  l:pwq_lnum: ' . l:pwq_lnum . '  l:autoindent: ' . l:autoindent

            let l:starts_with_keyword = s:StartsWithKeyword(v:lnum)

            if (l:pline =~ l:LONE_CLOSING_PAREN_OR_BRACKET_PAT 
                        \ || l:start_col_syn_id_attr =~ 'xml')
                        \ && !l:starts_with_keyword

                echomsg '/indent/xquery.vim:351   Dont indent to line with keyword if the immediate previous line was a closing paren/bracket, or inside an xml tag. Autoindenting instead.'

                return l:autoindent

            elseif getline(l:pwq_lnum) =~ l:STARTS_WITH_RETURN 

                "   Ex.
                "       let $dood := let $foo := 'asdf'
                "                    order by $somethingelse
                "                    return 'adsF'
                "                    let $googogo := '2'

                " i.  get the indent of the line starting with the return,
                " ii. keep moving back lines until we get to a line w/ SMALLER
                "     indentation than the line w/ the return from step i.
                "       

                let return_indent = indent(l:pwq_lnum)
                let ln            = l:pwq_lnum-1
                let l:start_lnum  = ln

                while (return_indent <= indent(ln) && ln >= 1) 
                    let ln = ln - 1
                endwhile

                " iii. ...and keep moving back until we get to a keyword line
                "
                while(!s:StartsWithKeyword(ln)) && ln >= 1
                    let ln = ln - 1
                endwhile
                                       

                if s:MAXLOOKBACK < v:lnum - ln
                    "  If we're looking back way too far, don't indent
                    return -1
                else 

                    echomsg '/indent/xquery.vim:388   (tests #4 & #5)  Previous keyword was a return, so indenting expression that *might* have a FLOWRs in its rhs...  indent(' . ln . '): ' . indent(ln) .  '    return_indent: ' . return_indent . '  curr line number: ' . v:lnum
                    return indent(ln) == 0 ? -1 : indent(ln)
                endif


            elseif l:starts_with_keyword
                echomsg '/indent/xquery.vim:394   (tests #14)  Line starts with keyword, so aligning with the previous keyword    pwq_lnum:' . l:pwq_lnum . '  l:start_col:' . l:start_col . '  l:autoindent:' . l:autoindent

                " 4/29/2011   and/or use double the indentation

                return (l:pwq_lnum == -1) ? l:autoindent : (l:start_col == -1) ? l:autoindent : l:start_col 
            else 

                echomsg '/indent/xquery.vim:401  No rules met, so NOT indenting'
                return -1
            endif

        endif

    endif

    echomsg "/indent/xquery.vim:409  weird, reached end of function WITHOUT returning indentation, so maybe an execption occurred. Not changing indentation   l:plnum:" . l:plnum

    return -1

endfunction
"}}}

"  XQindent#PrevnonblankStartingWithXQueryKeyword:"{{{
"  Returns the line number of the closest line starting with an xquery
"  keyword, or 0 if none is found.
"
"  TODO  compare the keyword at lnum if there is one, and figure out
"        what makes sense based on FLOWR
"
"    Ex. 
"       let $foo := 
"           fn:concat('Foo', ' value'))
"           (: this line should indent to the let ? :)
"           
"  Parameters: 
"       start_lnum 
"       curr_lnum 
"       depth
"
function! s:PrevnonblankStartingWithXQueryKeyword(start_lnum, curr_lnum, depth) 
    "echomsg '/indent/xquery.vim:242  Entered PrevnonblankStartingWithXQueryKeyword!  v:lnum:' . v:lnum . '  a:depth:' . a:depth . '  line: ' . getline(v:lnum) 

    let l:number_of_lines_back = a:start_lnum - a:curr_lnum

    if v:lnum == 0 || s:StartsWithKeyword(a:curr_lnum)
        return l:number_of_lines_back > s:MAXLOOKBACK ? 0 : a:curr_lnum
    else
        return s:PrevnonblankStartingWithXQueryKeyword(a:start_lnum, s:PrevnonblankIgnoringComments(a:curr_lnum - 1), a:depth+1)
    endif
endfunction
"}}}

"  XQindent#StartsWithKeyword: "{{{
"  Returns true if linenum starts with a few selected xquery keywords,
"  false otherwise,
"
"  3/11/2011  Removed 'if'/'else' since it uses searchpairpos()
"             and messed up indentation for other expressions
"   Ex.
"       let $test := 
"           if($something-is-true) then
"              'yes'
"           else (
"              'no'
"           )
"           let $something-else := ...
"
function! s:StartsWithKeyword(linenum) 

    let l:xquery_keywords = [
        \ 'for', 'let', 'where', 'order', 'return',  
        \ 'declare'
        \ ]

    " Ex. \(for\|let\|where\|order by\|return\)
    let l:xquery_keywords_regex = '\(' . join(l:xquery_keywords, "\\|") . '\)'
    let l:starts_with_xquery_keywords_regex = '^\s*' . l:xquery_keywords_regex 

    let l:starts_with_keyword =  
        \ (getline(a:linenum) =~ l:starts_with_xquery_keywords_regex) 

    return l:starts_with_keyword
endfunction
"}}}

"  XQindent#StartColumn: Returns the column of the first non blank word at lnum "{{{
function! s:StartColumn(linenum)
  return match(getline(a:linenum), '[^[:space:]]')
endfunction
"}}}

" XQindent#PrevnonblankIgnoringComments: Save as prevnonblank(), but ignores comments "{{{
function! s:PrevnonblankIgnoringComments(curr_lnum) 
    let l:plnum = prevnonblank(a:curr_lnum)
    let l:plcol = s:StartColumn(l:plnum)+1
    let l:syn_id_attr = synIDattr(synID(l:plnum, l:plcol, 0), "name")

    if a:curr_lnum == 0
        return 0
    elseif l:syn_id_attr == 'xqComment'
        return s:PrevnonblankIgnoringComments(l:plnum-1)
    else 
        return l:plnum 
    endif
endfunction
"}}}

let b:undo_indent = "setlocal indentexpr< indentkeys< autoindent<"

" vim:sw=4 fdm=marker tw=80
