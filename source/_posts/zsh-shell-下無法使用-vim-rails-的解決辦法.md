title: zsh shell 下無法使用 vim-rails 的解決辦法
author: kakas
tags:
  - vim
  - rails
categories:
  - 疑難雜症
date: 2017-03-29 20:04:00
---
## 更新 2016/01/03

發現有另外一招也可以用，所以這一招不管用試試看另外一招即可

`sudo mv /etc/zshenv /etc/zshrc`

這樣的話可以讓 vim 正確的吃到 zsh 的 $PATH



## 先說結論

若你在 zsh shell `$ echo $PATH`，與在 vim 裡面 `:!echo $PATH` 的值不一樣，你可以試試看在 .vimrc 裡面指定 shell 為 bash。

`set shell=/bin/sh`



## 解決經過

前幾天看到這篇 [Effective Rails Development with Vim](http://www.sitepoint.com/effective-rails-development-vim/) 後，就一直想試試看 [tpope/vim-rails](https://github.com/tpope/vim-rails) 但是昨天試了各種 `R` command 都沒辦法用，因為我一但在 vim 裡面輸入 `R` command，譬如 `:Rserver` 就會跳出

```shell
Warning: You're using Rubygems 2.0.14 with Spring. Upgrade to at least Rubygems 2.1.0 and run `gem pristine --all` for better startup performance.
Could not find rdoc-4.2.0 in any of the sources
Run `bundle install` to install missing gems.

shell returned 7

Press ENTER or type command to continue
```

但是我跳出 vim，在 zsh 檢查版本

```shell
$ gem --version
2.5.1
```


**幹！很新啊。**

瘋狂爬文一天，試過

1. 重新安裝 vim
2. 修改 .zshrc
3. 修改 .bashrc
4. 修改 .bash_profile
5. gem update --system
6. gem pristine --all


**以上方法全部都沒用**

就在最後，在 stack overflow 爬到 vim 執行 script 不吃 .zshrc，檢查一下 vim shell 的設定，發現是 zsh，後來在 .vimrc 加入 `set shell=/bin/sh` 就解決了。


遇到這種問題真的好頭痛，也找不太到人問，解決過程中，一直搞不太懂那些 $PATH 到底要怎麼設定，看來必須找個時間再好好充實一下知識了。