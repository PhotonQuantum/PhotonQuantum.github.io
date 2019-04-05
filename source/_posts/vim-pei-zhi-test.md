---
title: Vim 配置 - 测试
date: 2019-04-06 02:23:16
tags:
  - 技术
  - 计算机
  - Vim
categories:
  - 技术杂谈
---
> ** This is a test article **

到现在我才发现，这个博客至今从来没有写过任何关于技术的文章欸（大概是因为我太懒+技术太烂）！我用 Vim 其实已经用了很久了，从接触 Linux 开始我就没用过 Nano 或者是其他的编辑器，因为 Vim 无以比拟的键盘与终端操作的便利性真的让人无法离开。因为大约一周之前 Archlinux 被我在安装新的 X Server 的时候搞炸了，所以趁这个机会重新整理了一下我使用 Vim 的配置和心得。在这里分享一下，也做一下记录和备份。

<!-- more -->

## 正确使用 Vim

很多人质疑说，在 21 世纪，我们根本没有必要使用这种带模式的文本编辑器。这种说法我就不太认同。毕竟，一般人在使用类似 VSCode 的编辑器的时候，都或多或少地接触了模式编辑的概念：使用键盘的时候为 Insert 模式，使用鼠标的时候为 Normal 模式。而鼠标很多时候并不是一个很好的定位工具，因为文本的特殊性，使用键盘来定位内容比使用鼠标更为快捷和精准，并且用终端的时候，鼠标控制更是不可能的。

还有的人热衷于配置 Vim 将其当作一个全能的 IDE 使用，也有人就此抨击说 Vim 永远也做不到类似大型 IDE 一般的体验。就我个人而言，Vim 的定位就不是一个 IDE，该用 IDE 的时候就用专业的产品，而 Vim 这种工具更像瑞士军刀，启动加载快捷操作方便，在修改一般文本配置文件和写一些小型的脚本语言工具的时候有着 IDE 无法比拟的优势。很多时候如果只是想写一些个人使用的小 Python 脚本或者写一个原型，再去开 IDE 就太浪费时间了。

然后说到很多人纠结的 Emacs 和 Vim 之争，其实 Emacs 的定位也和 Vim 有着根本的不同。Emacs 是一个非常庞大完整的系统，有 Org-mode、多媒体支持、网络插件等等的功能，还有人在使用 Emacs 来放映电影，查看 PDF 文档，甚至泡咖啡。而 Vim 则更专职文本编辑，并没有太多除了文本编辑以外的功能，其使用用途也更单一。当然也不是说 Vim 不能用来泡咖啡（你可以写个 Python 脚本来和咖啡机通信），但是它本来就不是用来干这种事情的。所以 Emacs 和 Vim 并没有绝对的优劣，只是看各人的需求如何了。

## Vim 的衍生分支—— NeoVim

在现在，Vim 的开发已经分裂成了两大派别。其一是原始的 Vim 项目，现在处于 8.0 版本。另外还有 NeoVim，是一位开发者对 Vim 陈旧的开发思想感到不满而全新 Fork 出的分支。可以说，NeoVim 对 Vim 的进步起到了极大的推动作用，无论是 Async 操作还是 Timer 等特性，都是 NeoVim 首先实现，然后 Vim 主线再跟进的。此外，NeoVim 对除 VimL 外的外部开发语言的良好支持，对 Terminal 的内嵌，和对外部程序开放的嵌入接口，都给 NeoVim 的扩展带来了无限的可能。

在 NeoVim 的基础上，套壳 GUI 开始蓬勃发展，很多 GUI 有着非常惊艳的效果，比如基于 Electron 的 Oni 和基于 Go 的 gonvim。它们都大幅改进了 NeoVim 的界面，给 Vim 增加了许多“现代化”的元素，打造“21 世纪的模式编辑器”。
![Oni](/images/oni.png)
![gonvim](/images/gonvim.png)

因为时间关系，我还没来得及试用这两款 Frontend， 所以下文的配置是针对传统的 GUI 方案——NeoVim-Qt 撰写的，并没有用到什么全新的黑科技。如果有时间，我一定会试用一下这些全新的工具的。

## 我的 Vim 配置

### 在配置之前
很多人在刚刚上手使用 Vim 的时候就很喜欢上网去找各种 Vim 发行版（比如 [SpaceVim](https://github.com/SpaceVim/SpaceVim) 或者 [EverVim](https://github.com/LER0ever/EverVim)）直接使用，或者看到一篇教程之后安装一大堆 Plugin。这种使用方法是错误的，因为在完全熟悉 Vim 本来的操作之前就用各种附加工具，就相当于还不会走路的时候学跑步，学出来的样子肯定是非常奇怪的。如果过早就陷入了玩配置的过程中，就无法习得 Vim 的正确高效使用方法，因此很多人有着几千行的 .vimrc，还只会不停按着 jkhl 来导航。为了避免这种情况，请先练习 Vim 自带的教程，打开方式是 :Tutor 。

当你熟悉各种 Vim 的基本操作之后，可以看别人的 Vim 配置教程。在下文中，我不会给出我自己的整个配置文件，而是会分门别类地介绍我正在使用的设置和插件。确保你完全懂得自己写下的配置文件的意义，你才能拥有真正属于自己的 Vim 配置，并且能避免各种奇奇怪怪的问题。

> Tip: 下文所写的配置只保证能在 NeoVim 中正常使用，其中一些插件确认使用了 NeoVim 独有的特性，并且请确保你已经安装了 Python3 插件以支持 Neovim 的 Python 特性。NeoVim 的配置文件 **不是 .vimrc，是 .config/neovim/init.vim，或者是针对 GUI 的 .config/neovim/ginit.vim！**

### 插件管理
配置 Vim 的时候，或多或少会使用到一些插件，而一个好的插件管理器能避免大量的麻烦，并把插件关系整理得井井有条。很多人应该都听说过 Vundle、vim-plug 这类的管理器，而在现在我更推荐 dein.vim。其作者 [Shougo](https://github.com/Shougo) 曾经在 [issue 135](https://github.com/Shougo/dein.vim/issues/135) 比较过 dein.vim 与 vim-plug 的区别。

简单地来说就是：
- 比 vim-plug 更快
- 支持更多的 lazy 加载特性
- 支持缓存
- 支持插件合并
- 可加载本地插件
- 支持除了 git 之外的其他版本控制系统
- 支持通知功能
- 没有命令支持
- 没有安装进度 buffer

dein.vim 可以配置成在启动 vim 的时候安装不存在的插件，而且安装的速度也很快，配置文件管理起来也很优雅。当然，vim-plug 也是很好的选择，如果个人比较喜欢的话可以选用。

> dein.vim: [Github 地址](https://github.com/Shougo/dein.vim)
> vim-plug: [Github 地址](https://github.com/junegunn/vim-plug)

### 外观
![one](/images/vim-one-md.png)
对于每天都使用的编辑器，使用一个适合的主题很重要。我个人比较喜欢 [one]("https://github.com/rakr/vim-one") 的白色主题。
```plain
ColorScheme one
set background=dark
set background=light
```

然后改造 Vim 的状态栏，为其添加一条色彩鲜艳的 Powerline。（Powerline 的 Vim 版已经失去支持，现在仍在活跃开发的有 [lightline](https://github.com/itchyny/lightline.vim) 和 [airline](https://github.com/vim-airline/vim-airline)。相对来说，lightline 更加轻量，而 airline 开箱即用，和其他很多插件都有自带整合。airline 还可以安装 [airline-themes](https://github.com/vim-airline/vim-airline-themes) 获取各类主题。
```plain
let g:airline_theme='one'
```
如果你的字体打过补丁，还可以开启 powerline font 特性进一步美化显示。
```plain
let g:airline_powerline_fonts=1
```
因为有了 airline，默认的状态显示就可以关掉了
```plain
set noshowmode
```

除此之外，还有一些其他的小设置，可以根据个人喜好配置。
```plain
" 显示行号
set number
" 高亮当前行
set cursorline
```

> 未完待续...
