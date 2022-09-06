" エディタ設定 (同様な処理 ( :!mkdir -p %:h ))
" set number "行番号を表示する
set title "編集中のファイル名を表示
syntax on "コードの色分け
set tabstop=2 "インデント設定
set shiftwidth=2 "自動インデントでずれる幅
set autoindent "改行時に前の行のインデントを継続する
set smartindent "改行時に入力された行の末尾に合わせて次の行のインデントを増減する

" vim ディレクトリ作成 ( :!mkdir -p %:h )
augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)  " {{{
    if !isdirectory(a:dir) && (a:force ||
    \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}

" ノーマルモードへの移行と保存
inoremap <silent> ii <ESC>:<C-u>w<CR>

" inswertモードの時のカーソル移動の設定
imap <C-p> <Up>
imap <C-n> <Down>
imap <C-b> <Left>
imap <C-f> <Right>
imap <C-a> <Home>
imap <C-e> <End>
imap <C-d> <Del>
