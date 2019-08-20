---
title: Vim 下使用 Microsoft Python Language Server 补全
date: 2018-12-01 12:54:00
tags:
  - 技术
  - 计算机
categories:
  - 技术杂谈
---

> 自从上次咕咕咕之后，博客又长草了三个月（逃。当然，我也没想到咕咕咕之后写的第一篇文章竟然是一篇技术文。等等，我最初开这个博客的目的就是写点杂七杂八的技术吧？那我写一些技术类的东西也不会显得奇怪吧？呐？不会吧？（一个作着文青梦的理工生突然醒悟）啊，意识流的内容我也没想断更，具体以后会写什么东西还是随缘 233

## 初衷
首先我是个 Vim 教徒，在 Vim 下写 Python 也写了一年多了。自然，Python 补全肯定是一直在用的。我之前用的一直是基于 Jedi 的补全方案，效果也不错，就是补全出现速度稍微有一点～点慢。不过由于用了异步的补全框架 [ncm2/ncm2](https://github.com/ncm2/ncm2)，所以觉得海星（这里先提一个醒，我之前一直在用的 [Shougo/deoplete](https://github.com/Shougo/deoplete.nvim) 有坑，用起来觉得超级卡，还甩锅 Jedi，等换了 ncm2 之后丝般顺滑...）。

<!-- more -->

最近发现微软造了个新轮子，把 VS Studio 里的 Python 语义补全拿出来了，听说效果很不错，而且已经有 Emacs 社区的大神成功将其引入 Emacs（中文：[Emacs China](https://emacs-china.org/t/microsoft-python-language-server/7665) 英语：[vxlabs](https://vxlabs.com/2018/11/19/configuring-emacs-lsp-mode-and-microsofts-visual-studio-code-python-language-server/)）。听已经用上的人说，补全速度极快，而且由于用的是 C#，后台是多线程进行分析的，效率很高。这激起了我想在 Vim 上吃上微软 Python 补全螃蟹的欲望。

## LSP
既然 Microsoft Python Language Server（下称 mspyls）是微软实现的，它的通讯接口自然是微软自己提出的 Language Server Protocol（下称 lsp）。这个协议正在逐渐成为各类补全服务的通用统一协议。对于 lsp 的详细介绍，可以从[这个](https://langserver.org/)地方了解。简单地来说，它可以让语言分析实现和前台的 IDE 或者文本编辑器分离，让文本编辑部分和语言补全分析部分解耦，从而可以任意搭配。也就是说，如果我想在 Vim 上补全 Python，我既可以用 mspyls，也可以用 jedi。反过来，如果我想用 mspyls 补全，我既可以用 Vim，也可以用 Emacs， 当然 VSCode 和 Atom 什么的都可以。正是因为这个原因，mspyls 有强大的泛用性，可以很容易地在 Vim 上跑起来。
细节上来说，LSP 基于 JSON-RPC，可以通过 stdio 通信，也可以用 tcp 通信（所以 IDE 和语言服务可以跑在不同的机器上哦～）。关于现在有哪些语言服务能用，以及有多少编辑器可用，都可以在 [langserver](https://langserver.org/) 上查到。

## 编译 mspyls
由于我用着 Linux，所以下面的指令只适用 Linux，Windows 平台的话编译过程应该没差多少吧，网上应该也有不少的资料。
首先安装 .net core，Archlinux 下就可以直接 sudo pacman -S dotnet-sdk 一键解决（吹爆我大 Archlinux 神教！）
然后 git clone https://github.com/Microsoft/python-language-server
进入刚刚 clone 下来的 repo，到 src/LanguageServer/Impl 下，然后

``` bash
$ dotnet build -c Release
Microsoft (R) Build Engine version 15.9.20.62826 for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 51.1 ms for /home/lightquantum/ms_pyls/python-language-server/src/Analysis/Engine/Impl/Microsoft.Python.Analysis.Engine.csproj.
  Restore completed in 91.75 ms for /home/lightquantum/ms_pyls/python-language-server/src/LanguageServer/Impl/Microsoft.Python.LanguageServer.csproj.
  Microsoft.Python.Analysis.Engine -> /home/lightquantum/ms_pyls/python-language-server/output/bin/Release/Microsoft.Python.Analysis.Engine.dll
  Microsoft.Python.LanguageServer -> /home/lightquantum/ms_pyls/python-language-server/output/bin/Release/Microsoft.Python.LanguageServer.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:07.36
```

不出意外，就可以在 ../../../output/bin/Release 下找到 Microsoft.Python.LanguageServer.dll，用 dotnet Microsoft.Python.LanguageServer.dll 命令运行一下，没有报错（也没有回显 - -）就成功了！

## LanguageClient-neovim
在 Neovim 上其实已经有很多 LSP 的客户端插件了，个人用下来最完全体的，是 [autozimu/languageclient-neovim](https://github.com/autozimu/languageclient-neovim)。
首先，安装插件就不细说了，vim-plug 或者 dein 都是可以的（就是 Vundle 已经停止维护了，如果还在用 Vundle 的话，还是尽快切换成前两者吧），针对选择困难症，我无脑推荐 dein。为什么？因为我用的就是 dein（233
之后，需要对插件进行一些配置，将 Python 的默认语言服务从 Jedi 实现改成 mspyls。

**记得修改<...>到你刚刚编译的目录！**

```
let g:LanguageClient_serverCommands = {
    \ 'python': ['/usr/bin/dotnet', 'exec', '/<...>/output/bin/Release/Microsoft.Python.LanguageServer.dll']
\ }
let g:LanguageClient_loggingFile = "/tmp/LC.log"
let g:LanguageClient_loggingLevel = "DEBUG"
```

由于微软的 LSP 实现稍微有一点方言（微软：对，我说什么就是什么，sorry，我提的协议我就可以为所欲为～），所以需要在初始化时传入一点参数。
在项目目录下（或者是要编辑的 py 文件的同目录下创建 .vim/settings.json，然后写入

```json
{
  "enabled": true,
  "initializationOptions": {
    "displayOptions": {
      "preferredFormat": "plaintext",
      "trimDocumentationLines": true,
      "maxDocumentationLineLength": 0,
      "trimDocumentationText": true,
      "maxDocumentationTextLength": 0
    },
    "interpreter": {
      "properties": {
        "InterpreterPath": "<...>",
        "UseDefaultDatabase": true,
        "Version": "<...>"
      }
    }
  }
}
```

**还是记得改 <...>！InterpreterPath 就是 Python 解释器的路径，Linux 下一般是 /usr/bin/python，可以用 whereis 命令来找。Version 就是 Python 版本，我个人是 3.7.0。**

其实是有一种方法，可以对 Python 全局设定 LSP 参数，不用创建局部的配置文件。然而，我比较懒不想配置了 233，各位可以去 LanguageClient 的 Github 页面，参照例子修改 233

> 补充 例子在 [yaml](https://github.com/autozimu/LanguageClient-neovim/wiki/yaml-language-server) 页面里，里面的 Method 2 就是了

这之后不要忘了装一个补全框架，Vim 默认的实现其实挺不顺手的。个人建议用一些异步的实现，比如之前提到的 ncm2。记得查看插件的 Github Repo，有一些依赖和配置建议。不看的话很有可能会报出一大堆错啊 233
如果你用了 ncm2，还可以对补全设定加上一些小 tweaks。我个人用的配置是

```
" 这里是对于 Multiple Cursors 插件的 workaround，没有这个插件的话就不用了
function g:Multiple_cursors_before()
  call ncm2#lock('multiple_cursors')
endfunction
function g:Multiple_cursors_after()
  call ncm2#unlock('multiple_cursors')
endfunction
" 不要自动插入补全结果，不要自动选中第一补全，只有一个补全项的时候也显示出来
set completeopt=noinsert,menuone,noselect
" 所有 Buffer 都启用 ncm2
autocmd BufEnter  *  call ncm2#enable_for_buffer()
" Tab 键轮选
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" 退出补全的时候自动关闭补全菜单
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
" 有补全菜单的时候回车时，不仅关闭补全菜单，再加上一个回车（默认行为是吃掉这个回车，很多时候代码写快了，一个回车按下去没有反应还是很烦心的）
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
```

## 结论
不出事故的话，补全应该已经可以用了～（虽然我觉得，应该有不小的概率会出毛病，我之前就调了两个钟头... 因为会出问题的地方太多了，我也不清楚具体会有哪些环节出问题 QAQ 如果出了问题，就只能一点点查了。而且好像 Vim 上的 mspyls 基本没人研究，资料应该挺少的 emm）
试了一下，发现... 诶？速度好像是可以，基本是秒出补全，半秒都没有，估计只有几十毫秒的 lag。可是这为啥每次补全之前的初始化要那么久啊？一个小的脚本需要四五秒之后才能开始补全，大的项目的话，有人初始化整整初始化了 4 个小时- -。还有，好像有些 module 的补全提示有点问题，比如 requests 的 get 方法拿到的对象，补全都是 built-in functions，根本没有在能用的方法... 还有各种奇奇怪怪的 import 问题，可以在 repo 的 issues 下看到。
巨硬你怎么回事？说好的 intelliSense 呢？你这个一点都不 intelli 吧？嘛算了，毕竟还是个 alpha，有各种问题还是很正常的。说不定过个半年，就会完善了吧～反正先留着配置，到时候出了新版本，reset 然后 clone 一下，再编译一下，也能无缝升级。坐等微软补完这个引擎，养肥了就能体验完全体的 intelliSense for Python 了～
这里另外推荐一些别的插件，如果用 jedi 补全的话，可以不用 lsp 实现，直接装 ncm2/ncm2-jedi 就可以了，lint 和 autofix 的话，个人喜欢 ALE。高亮增强的话，[numirias/semshi](https://github.com/numirias/semshi) 看起来不错。

> 到此，本次博客除草就结束了！之后我还会持续关注 mspyls 的，如果补全效果有好转，也许我还会再写一篇文章补充的。关于其他的 Vim for Python 配置，有机会我也会介绍一下的～ 图咱就懒得上了，毕竟补全也没啥图嘛 233
> 其实吧，我最近的心理状况不是很好，学业上也碰到了不小的问题... 说不定下周又要切换到忧郁模式了 QAQ 嘛，我的近况就下周再更吧。
