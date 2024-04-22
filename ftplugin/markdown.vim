" Author: KITAGAWA Yasutaka <kit494way@gmail.com>
" Description: Table of contents of markdown file.
if exists('b:loaded_toc')
  finish
endif
let b:loaded_toc = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

function s:toc_source() abort
  let res = systemlist('toc --vimgrep '.expand('%:p'))
  return map(res, {_, val -> s:split_toc(val)})
endfunction

function s:split_toc(line) abort
  let xs = split(a:line, ':')
  if len(xs) == 4
    return xs[1:]
  endif

  let [_, lnum, col] = xs[:2]
  let text = join(xs[3:], ':')
  return [lnum, col, text]
endfunction

function s:goto_cur_header() abort
  let [_, lnum, _, _, _] = getcurpos()
  let header = s:headers[lnum - 1]

  " move to previous window
  execute 'wincmd p | b '.header['buf']

  call setpos('.', [header['buf'], header['lnum'], header['col'], 0])
endfunction

function s:display_toc() abort
  let l:toc = s:toc_source()
  let curwin = winnr()
  let l:toc_window_width = max(map(copy(l:toc), {_, val -> strdisplaywidth(val[2])})) + 2
  let min_toc_window_width = 20
  if getwinvar(curwin, '&number') || getwinvar(curwin, '&relativenumber')
    let number_width = getwinvar(curwin, '&numberwidth')
    let l:toc_window_width = l:toc_window_width + number_width
    let min_toc_window_width = min_toc_window_width + number_width
  endif
  let l:toc_window_width = max([l:toc_window_width, min_toc_window_width])

  let s:headers = []
  let header_texts = []
  let curbuf = bufnr()
  for [lnum, col, text] in l:toc
    let [s, _, _] = matchstrpos(text, '#\+', 0)
    let header_text = substitute(s[1:], '#', ' ', 'g')..substitute(text, '^#\+\s\+', '', '')
    call add(s:headers, {
      \ 'buf': curbuf,
      \ 'lnum': lnum,
      \ 'col': col,
      \})
    call add(header_texts, header_text)
  endfor

  " create buffer for Toc
  if !exists('s:toc_buffer') || !bufexists(s:toc_buffer)
    execute 'vnew +setlocal\ buftype=nofile\ bufhidden=hide\ noswapfile'
    execute 'vert resize '.l:toc_window_width
    let s:toc_buffer = bufnr()
  elseif empty(win_findbuf(s:toc_buffer)) " if hidden buffer
    execute 'vs | vert resize '.l:toc_window_width.' | b '.s:toc_buffer
  endif

  call setbufvar(s:toc_buffer, '&buftype', 'nofile')
  call setbufvar(s:toc_buffer, '&bufhidden', 'hide')
  call setbufvar(s:toc_buffer, '&swapfile', 0) " noswapfile

  nnoremap <silent> <buffer> <CR> :call <sid>goto_cur_header()<CR>

  call deletebufline(s:toc_buffer, 1, '$')
  call setbufline(s:toc_buffer, 1, header_texts)
endfunction

if !exists('g:clap_provider_toc')
  let s:toc = {}

  function! s:toc.source() abort
    let res = systemlist('toc --vimgrep '.expand('#'.g:clap.start.bufnr.':p'))
    return map(res, {_, val -> join(split(val, ':')[1:], ':')})
  endfunction

  function! s:toc.sink(selected) abort
    let [lnum, column; _] = split(a:selected)
    noautocmd call cursor(lnum, column)
  endfunction

  let g:clap_provider_toc = s:toc
endif

command! -buffer Toc call s:display_toc()

let &cpoptions = s:save_cpo
unlet s:save_cpo
