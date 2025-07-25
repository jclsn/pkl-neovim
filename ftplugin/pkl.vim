" Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"   https://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" comment with two slashes
setlocal commentstring=//\ %s
" List of valid comment operators
setlocal comments=s1:/*,mb:*,ex:*/,n://,n:///
" Formatoptions providing multi-line comment wrapping
setlocal formatoptions+=croql
" Always expand tabs
setlocal expandtab
" Shiftwidth is two spaces
setlocal shiftwidth=2
" Use syntax folding
setlocal foldmethod=syntax

let s:yegappan_lsp_exists = exists("*LspCustomRequest")
let s:coc_exists = exists("*coc#rpc#request")

if (s:yegappan_lsp_exists)
	command! PklSync call g:LspCustomRequest('pkl/syncProjects', 0)
	command! -nargs=1 PklDownloadPackage call g:LspCustomRequest('pkl/downloadPackage', <f-args>)
elseif (s:coc_exists)
	command! PklSync call g:coc#rpc#request('pkl/syncProjects', 0)
	command! -nargs=1 PklDownloadPackage call g:coc#rpc#request('pkl/downloadPackage', <f-args>)
endif
