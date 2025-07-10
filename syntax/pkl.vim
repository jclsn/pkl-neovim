if exists("b:current_syntax")
  finish
endif

syn clear
syn sync fromstart

" PKL supports non-Unicode identifiers. So we modify the keyword character
" class to include them:
syn iskeyword @,48-57,192-255,$,_

" Declare variables fo identifiers and qualified identifiers
let s:id = '\%(\K\+[_$]*\K*\d*[_$]*\)'
let s:qid   = '\%(' . s:id . '\+\.*\%(' . s:id . '*\.\?\)*\)'


" --- Shebang ---
syn region	pklShebang	start="^\s*#!" end="$" keepend oneline
exe $'syn match	pklDecorator     "@{s:id}\{{1,}}"'

" --- Comments ---
syn match	pklComment	"\/\{2}.*"
syn match	pklDocComment	"\/\{3}.*"
syn region	pklMultiComment	start="\/\*" end="\*\/" keepend fold

" --- Strings ---
syn region	pklString	start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=pklEscape,pklUnicodeEscape,pklStringInterpolation oneline
syn region	pklMultiString	start=+"""+ skip=+\\."+ end=+"""+ contains=pklEscape,pklUnicodeEscape keepend fold
syn match	pklEscape	"\\[\\nt0rbaeuf"']\?" contained containedin=pklString,pklMultiString
syn match	pklUnicode	"[0-9A-Fa-f]\+" contained

" --- String interpolation---

" Standard interpolation
syn region	pklStringInterpolation matchgroup=pklDelimiter
	  \ start=+\\(+ end=+)+ contains=pklNumbers,pklOperator,pklIdentifier,pklFunction,pklParen,pklString
	  \ contained containedin=pklString,pklMultiString oneline
" Unicode escape sequences
syn region	pklUnicodeEscape matchgroup=pklDelimiter
	  \ start=+\\u{+ end=+}+ contains=pklUnicode
	  \ contained containedin=pklString,pklMultiString

" -- Custom string delimiters ---
for x in range(1, 5)
  exe $'syn region pklString{x}Pound start=+{repeat("#", x)}"+ end=+"{repeat("#", x)}+ contains=pklStringInterpolation{x}Pound,pklEscape{x}Pound oneline'
  exe $'hi def link pklString{x}Pound String'

  exe $'syn region pklMultiString{x}Pound start=+{repeat("#", x)}"""+ end=+"""{repeat("#", x)}+ contains=pklStringInterpolation{x}Pound,pklEscape{x}Pound keepend fold'
  exe $'hi def link pklMultiString{x}Pound String'

  exe $'syn match pklEscape{x}Pound "\\{repeat("#", x) }[\\nt0rbaeuf"'']\?" contained containedin=pklString{x}Pound,pklMultiString{x}Pound'
  exe $'hi def link pklEscape{x}Pound SpecialChar'

  exe $'syn region pklStringInterpolation{x}Pound matchgroup=pklDelimiter start=+\\{repeat("#", x)}(+ end=+)+ contains=pklNumbers,pklOperator,pklIdentifier,pklFunction,pklParen,pklString contained containedin=pklString{x}Pound,pklMultiString{x}Pound oneline'

  exe $'syn region pklUnicodeEscape{x}Pound matchgroup=pklDelimiter start=+\\{repeat("#", x)}u{{+ end=+}}+ contains=pklUnicode contained containedin=pklString{x}Pound,pklMultiString{x}Pound'
  exe $'hi def link pklUnicodeEscape{x}Pound SpecialChar'
endfor

" --- Keywords ---
syn keyword	pklBoolean       false true
syn keyword	pklClass         outer super this module
exe $'syn match	pklClass         "\<new\>\s*{s:qid}*" contains=pklType'
syn keyword	pklConditional   if else when
syn keyword	pklConstant      null
syn keyword	pklException     throw
syn keyword	pklInclude       amends
syn match	pklInclude       "\<import\*\?\>"
exe $'syn match	pklInclude       "\<extends\>\s*{s:qid}*" contains=pklType'
exe $'syn match	pklInclude       "\<as\>\s*{s:qid}*" contains=pklType'
syn keyword	pklKeyword       function let out
exe $'syn match	pklKeyword       "\<is\>\s*\%({s:qid}\||\)*" contains=pklType'
syn keyword	pklModifier      abstract const external fixed hidden local open
syn keyword	pklReserved      case delete override protected record switch vararg
syn keyword	pklRepeat        for in
syn keyword	pklSpecial       nothing unknown
syn keyword	pklStatement     trace
syn match	pklStatement     "read[?|\*]\?"
exe $'syn match	pklStruct        "\<typealias\>\s*{s:id}*\s*=\?\s*\%(\*\?{s:qid}?\?\||\)*" contains=pklType'
exe $'syn match	pklStruct        "\<class\>\n*\s*{s:id}*" contains=pklType'

" --- Types ---
exe $'syn match	pklType "\<typealias\>\s\+\zs{s:id}\+\s*=\?\s*\%(\*\?{s:qid}?\?\||\)*" contained contains=ALLBUT,pklIdentifier,pklUnicode'
exe $'syn match	pklType "\<class\>\s\+\zs{s:id}\+" contained'
exe $'syn match	pklType "\<new\>\s\+\zs{s:qid}" contained'
exe $'syn match	pklType "\<extends\>\s\+\zs{s:qid}\+" contained'
exe $'syn match	pklType "\<as\>\s\+\zs\%(\*\?{s:qid}?\?\||\)\+" contained'
exe $'syn match	pklType "\<is\>\s\+\zs\%({s:qid}\||\)\+" contained'
" These two match types in parentheses. They work, but are very slow
" exe $'syn match	pklType "|\{{1}}\s*\%(\*\?{s:qid}?\?\||\)\+" contained contains=pklOperator,pklParameterizedType'
" exe $'syn match	pklType "\%(\*\?{s:qid}<\?{s:qid}*>\??\?\||\)*\s*|\{{1}}\s*\%(\*\?{s:qid}?\?\||\)\+" contained contains=pklOperator,pklParameterizedType'

exe $'syn region	pklParameterizedType start="{s:id}*\zs\*\?{s:id}\s*<\_s*" skip="->" end=">" '
      \ 'keepend extend contained contains=ALLBUT,pklIdentifier,pklUnicode,pklFunction'

" --- Identifiers ---

" Include all unicode letters and an additional : plus another identifier that
" is matched by pklObjectDeclaration
execute $'syn match pklIdentifier "{s:id}:\?\s*\*\?{s:qid}*" contains=' .
      \ 'pklObjectDeclaration,pklKeyword,pklBoolean,pklClass,pklConditional,pklConstant,' .
      \ 'pklException,pklModifier,pklReserved,pklRepeat,pklSpecial,pklInclude,' .
      \ 'pklType,pklStruct,pklObjectTypes,pklMisTypes,pklMiscTypes,pklCollections'

" Include declarations with a . like Type.TypeNames
execute $'syn match pklObjectDeclaration ":\s*\zs\%((\?\s*<*\*\?{s:qid}>*\s*|\?\s*)\?\)\+"' .
      \ ' contains=pklType,pklParameterizedType,pklParameterizedType,pklOperator,pklParen,pklKeyword'


" Explicitely make keywords identifiers with backticks
syn region	pklIdentifierExplicit	start=+`+ end=+`+

syn match	pklOperator     ",\||\|+\|*\|->\|?\|-\|=" contained containedin=pklType

" --- Numbers ---
" decimal numbers
syn match	pklNumbers	display transparent "\<\d\|\.\d" contains=pklNumber,pklFloat,pklOctal
syn match	pklNumber	display contained "\d\%(\d\+\)*\>"
" hex numbers
syn match	pklNumber	display contained "0x\x\%('\=\x\+\)\>"
" binary numbers
syn match	pklNumber	display contained "0b[01]\%('\=[01]\+\)\>"
" octal numbers
syn match	pklOctal	display contained "0o\o\+\>" 

"floating point number, with dot, optional exponent
syn match	pklFloat	display contained "\d\+\.\d*\%(e[-+]\=\d\+\)\="
"floating point number, starting with a dot, optional exponent
syn match	pklFloat	display contained "\.\d\+\%(e[-+]\=\d\+\)\=\>"
"floating point number, without dot, with exponent
syn match	pklFloat	display contained "\d\+e[-+]\=\d\+\>"

" --- Brackets, operators, functions ---
syn region	pklParen	matchgroup=pklBrackets start='(' end=')' contained contains=ALLBUT,pklUnicode
syn region	pklBracket	matchgroup=pklBrackets start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,pklUnicode
syn region	pklBlock	transparent matchgroup=pklBrackets start="{" end="}" contains=ALLBUT,pklUnicode fold

exe $'syn match	pklFunction	"\<\h{s:id}*\>\ze\s*[?|\*]\?(" contains=pklType'

" --- Highlight links ---
hi def link	pklBoolean                       Boolean
hi def link	pklBrackets                      Delimiter
hi def link	pklClass                         Statement
hi def link	pklCollections                   Type
hi def link	pklComment                       Comment
hi def link	pklConditional                   Conditional
hi def link	pklConstant                      Constant
hi def link	pklDecorator                     Special
hi def link	pklDelimiter                     Delimiter
hi def link	pklDocComment                    Comment
hi def link	pklEscape                        SpecialChar
hi def link	pklException                     Exception
hi def link	pklFloat                         Number
hi def link	pklFunction                      Function
hi def link	pklInclude                       Include
hi def link	pklKeyword                       Keyword
hi def link	pklMiscTypes                     Type
hi def link	pklModifier                      StorageClass
hi def link	pklMultiComment                  Comment
hi def link	pklMultiString                   String
hi def link	pklNumber                        Number
hi def link	pklNumbers                       Number
hi def link	pklObjectTypes                   Type
hi def link	pklObjectDeclaration             Type
hi def link	pklOctal                         Number
hi def link	pklParameterizedType             Type
hi def link	pklRepeat                        Repeat
hi def link	pklReserved                      Error
hi def link	pklShebang                       Comment
hi def link	pklSpecial                       Special
hi def link	pklStatement                     Statement
hi def link	pklString                        String
hi def link	pklStruct                        Structure
hi def link	pklSTLType                       Type
hi def link	pklType                          Type
hi def link	pklUnicodeEscape                 SpecialChar

let b:current_syntax = "pkl"
