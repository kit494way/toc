" Author: KITAGAWA Yasutaka <kit494way@gmail.com>
" Description: Table of contents of markdown file.

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:toc = {}

function! s:toc.source() abort
  let res = systemlist('toc --vimgrep '.expand('#'.g:clap.start.bufnr.':p'))
  return map(res, {_, val -> join(split(val, ':')[1:], ':')})
endfunction

function! s:toc.sink(selected) abort
  let [lnum, column; _] = split(a:selected)
  noautocmd call cursor(lnum, column)
endfunction

call clap#register('toc', s:toc)

let &cpoptions = s:save_cpo
unlet s:save_cpo
