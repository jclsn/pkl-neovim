if exists("b:current_syntax")
  finish
endif

syn clear
syn sync fromstart

" --- Shebang ---
syn region	pklShebang	start="^\s*#!" end="$" keepend oneline

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
syn match	pklClass         "\<new\>\s*\K*" contains=pklType
syn keyword	pklConditional   if else when
syn keyword	pklConstant      null
syn keyword	pklException     throw
syn keyword	pklInclude       amends as
syn match	pklInclude       "import\*\?"
syn match	pklInclude       "\<extends\>\s*\K*" contains=pklType
syn keyword	pklKeyword       function let out
syn match	pklKeyword       "\<is\>\s*\%(\k\|\.\||\)*" contains=pklType
syn keyword	pklModifier      abstract const external fixed hidden local open
syn keyword	pklReserved      case delete override protected record switch vararg
syn keyword	pklRepeat        for in
syn keyword	pklSpecial       nothing unknown
syn keyword	pklStatement     trace
syn match	pklStatement     "read[?|\*]\?"

syn match	pklStruct        "\<typealias\>\s*\K*" contains=pklType
syn match	pklStruct        "\<class\>\s*\K*" contains=pklType
syn match	pklDecorator     "@[a-zA-Z]\{1,}"

" --- Identifiers ---

" Include many non-Latin identifiers:
"
" \u00C0-\u02AF	Latin Extended, IPA, Spacing Modifier Letters, Greek & Coptic
" \u0370-\u1FFF	Greek Extended, Cyrillic, Armenian, Hebrew, Arabic, Syriac, etc.
" \u2C00-\uD7AF	Glagolitic, Georgian, Coptic, Armenian, Hebrew, Arabic supplements, etc.
" \uF900-\uFAFF	Chinese, Japanese, Korean
" \uFB00-\uFEFF	Alphabetic Presentation Forms, Hebrew, Arabic Presentation Forms, etc.
let s:unicode_letters = '\u00C0-\u02AF\u0370-\u1FFF\u2C00-\uD7AF\uF900-\uFAFF\uFB00-\uFEFF'

execute $'syn match pklIdentifier "\%([$_A-Za-z{s:unicode_letters}]\)\%([$_0-9A-Za-z{s:unicode_letters}]*:*\s*\K*\)"' .
      \ ' contains=' .
      \ 'pklObjectDeclaration,pklKeyword,pklBoolean,pklClass,pklConditional,pklConstant,' .
      \ 'pklException,pklInclude,pklModifier,pklReserved,pklRepeat,pklSpecial,pklStatement,' .
      \ 'pklType,pklStruct,pklObjectTypes,pklMisTypes,pklMiscTypes,pklCollections'

" Include declarations like Identifier: SomeObject
execute $'syn match pklObjectDeclaration "\%([$_A-Za-z{s:unicode_letters}]\)\%([$_0-9A-Za-z{s:unicode_letters}]*:*\s*\zs\K*\)"' .
      \ ' contains=pklType,pklParen,pklKeyword'

" Include declarations with a . like Type.TypeNames
execute $'syn match pklObjectDeclaration "\%([$_A-Za-z{s:unicode_letters}]\)\%([$_0-9A-Za-z{s:unicode_letters}]*:\{{1}}\s*\zs\K\+.\{{1}}\K\+\)"' .
      \ ' contains=pklType,pklOperator,pklParen,pklKeyword'

" Explicitely make keywords identifiers with backticks
syn region	pklIdentifierExplicit	start=+`+ end=+`+

" --- Types ---
syn keyword	pklType
	  \ UInt UInt8 UInt16 UInt32 UInt64 UInt128
	  \ Int Int8 Int16 Int32 Int64 Int128
	  \ String
	  \ Float
	  \ Boolean
	  \ Number
syn match	pklType ":\s*\zs\K\+\%[\K||]*\ze\s*="
syn match	pklType "\<typealias\>\s\+\zs\K\+\d*" contained
syn match	pklType "\<class\>\s\+\zs\K\+\d*" contained
syn match	pklType "\<new\>\s\+\zs\K\+\d*" contained
syn match	pklType "\<extends\>\s\+\zs\K\+\d*" contained
syn match	pklType "\<is\>\s\+\zs\%(\k\|\.\||\)\+" contained
syn region	pklType start="<" end=">" 
      \ contains=
      \ pklOperator,
      \ pklParen,
      \ pklTypeArrows,
      \ pklObjectTypes,
      \ pklType,
      \ pklCollections,
      \ pklMiscTypes,
      \ pklString 
syn match	pklOperator     ",\||\|+\|*\|->\|?" containedin=pklType

syn keyword	pklCollections
	  \ List Listing
	  \ Map Mapping
	  \ Set

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
syn region	pklParen	matchgroup=pklBrackets start='(' end=')' contains=ALLBUT,pklUnicode
syn region	pklBracket	matchgroup=pklBrackets start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,pklUnicode
syn region	pklBlock	transparent matchgroup=pklBrackets start="{" end="}" contains=ALLBUT,pklUnicode fold

syn match	pklFunction	"\<\h\w*\>\ze\s*("

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
hi def link	pklOctalZero                     Number
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
