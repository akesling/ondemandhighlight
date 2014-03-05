" Highlight a word from inside vim. The color is chosen at random but
" persisted across sessions.

" By Kartik Agaram -- http://akkartik.name -- ondemandhighlight@akkartik.com
" Experimenting with an idea by Evan Brooks: https://medium.com/p/3a6db2743a1e
" Discussion: http://www.reddit.com/r/programming/comments/1w76um/coding_in_color

let highlight_file = &viewdir."/highlights"
if !filereadable(highlight_file)
  call system("mkdir -p ".&viewdir)
  call system("echo 'call clearmatches()' > ".highlight_file)
endif
autocmd BufReadPost,WinEnter * silent! exec "source ".highlight_file

function! s:highlight(x)
  let l:wrap = &wrap | set nowrap
  exec ":new ".g:highlight_file
    silent exec "%!grep -v '\\<".s:group(a:x)."\\>'"
    normal G
    exec "normal ohighlight ".s:group(a:x)." ctermfg=".s:randomColor()
    if match(a:x, '\W') == -1
      exec "normal ocall matchadd('".s:group(a:x)."', '\\<".a:x."\\>')"
    else
      exec "normal ocall matchadd('".s:group(a:x)."', '".a:x."')"
    endif
  write | bdelete
  if l:wrap | set wrap | endif
  exec "source ".g:highlight_file
endfunction

function! s:unhighlight(x)
  let l:wrap = &wrap | set nowrap
  exec ":new ".g:highlight_file
    silent exec "%!grep -v '\\<".s:group(a:x)."\\>'"
  write | bdelete
  if l:wrap | set wrap | endif
  exec "source ".g:highlight_file
endfunction

function! s:group(x)
  return 'highlight_'.strpart(system("echo '".a:x."'|md5sum"), 0, 8)
endfunction

function! s:randomColor()
  return system("echo $RANDOM") % &t_Co  " num colors
endfunction

command! -nargs=1 Highlight call s:highlight(<q-args>)
command! -nargs=1 Unhighlight call s:unhighlight(<q-args>)

map - :Highlight <C-r><C-w><CR>
map _ :Unhighlight <C-r><C-w><CR>

" Scenarios considered:
"   should instantly update colors
"   shouldn't change the window in any other way (nowrap suppresses scrolling on new)
"   should overrule existing syntax highlighting (matchadd)
"   quitting and restarting should preserve colors
"   should work in multiple vim sessions at once (bdelete)
"   repeatedly highlighting a single word shouldn't grow the highlights file (grep -v)
"   repeatedly highlighting a single word should give uniformly random colors
"   should start up with non-existent viewdir
"   should handle phrases with special chars, except single quotes (md5sum)
"   should continue to highlight on both windows after :split
"
" Minor issues:
"   Color might sometimes be hard to see. Just highlight again.