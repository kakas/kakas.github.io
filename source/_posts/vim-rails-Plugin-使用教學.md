title: vim-rails Plugin 使用教學
author: kakas
tags:
  - rails
  - vim
  - tutorial
categories:
  - Rails
  - ''
date: 2016-10-25 20:02:00
---
這套由 tpope 所開發的 Plugin 我覺得對 Rails 的開發很有幫助，介紹給大家。

片長約 20 分鐘，建議可以用 1.5 倍速觀看。

[vim rails 介紹 （推薦 1.5 倍速觀看） - YouTube](https://www.youtube.com/watch?v=ZKM7ZLQVsbw)


## 補充資料

github：[tpope/vim-rails: rails.vim: Ruby on Rails power tools](https://github.com/tpope/vim-rails)

說明檔：[vim-rails/rails.txt at master · tpope/vim-rails](https://github.com/tpope/vim-rails/blob/master/doc/rails.txt)

vim-rails 有整合 Ctag，所以其實只要在 vim 裡面下 `:Ctags` 就可以了，若想額外設定的話可以在 vimrc 裡面設定 Ctag 譬如：

`let g:rails_ctags_arguments = ['--languages=ruby --exclude=.git --exclude=log .']`



## 心得

原來拍個介紹影片比想像中難幾百倍，現在回頭看一下 RailsCasts 拍的品質真的很棒、而且又清楚，不知道怎麼做到的，之後有機會想學一下剪接，一鏡到底真的會一直吃螺絲，一邊操作一邊講更難，寫了逐字稿好像也沒什麼用，稍微背一下流程應該可以更好，不過我懶了，為了拍這個已經花了兩天，還是學會剪接後再來拍下一集。