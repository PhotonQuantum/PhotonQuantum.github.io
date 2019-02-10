---
title: 从中文编程说起
date: 2018-02-23 17:24:00
tags:
  - 想法
  - 时评
categories:
  - 键盘侠
---

## 原委

最近在 Github 的 C# Repo 上看到了一个很搞笑的 [issue](https://github.com/dotnet/csharplang/issues/993)，因为内容太长了，恕无法贴出全文 233 大体上是在建议微软为 C#、F#、VB.net 提供一个中文变体，然后关于中文编程的必要性和实现进行辩论。在中国编程圈子里这也算是个老生常谈的话题了，也时常有人在研究实现实验性的编程语言。虽然我对于中文程序语言的必要性不置可否，但是这个 issue 暴露出了一些长久存在于国人身上的问题，我想对此谈谈自己的看法。

<!--more-->

## 只空想不动手

在这个 issue 下面有一些好心人在给这名用户一些解释说明：
> qrli: Company has to earn money to keep going. If you pay a big bill, someone will do it for you. You cannot ask someone to do you a favor for free.
And, computer language is not natural language. E.g. Your math symbols are not Chinese, your numbers are not Chinese, but you have no problem with them, right?
We generally view it as non-sense. If you really want it, you can create an editor plugin to translate keywords to Chinese and display them.

同时还有日本友人的留言:
> ufcpp: 中国だけでなく、日本でも同様の問題があります。多くのプログラミング言語が英語をベースにしていて、日本語話者にとってプログラミングの難しさの一因になっています。
当然、日本でも「日本語プログラミング言語」が欲しいという声はあります。実際になでしこというプログラミング言語があります。しかし、日本語プログラミング言語を作れるのはやっぱり日本語話者だけでしょう。中国語ネイティブなC#が欲しければ、それは中国語話者が作るべきで、他力本願でマイクロソフトに頼むものではないと思います。
ちなみに、日本語プログラミング言語は、存在こそあるものの、実際のところあまり流行はしていません。


也有一些建设性的回复：
> nobodxbodon: I agree that it's up to Chinese speakers to develop programming languages in Chinese. I heard about なでしこ before, and seems it's very useful for certain user group and certain tasks. I'm also trying to develop a simple script language, hopefully using Chinese grammar/tokens, to solve simple tasks, as a baby step towards Chinese PL.


这是 issue 提交者的回复：
>@qrli
你是中国人吗? 怎么对中文编程的话题这么熟悉?看起来你没明白我表达的重点.你是在抵制中文编程吧.
实现母语编程怎么可能没有意义? C#用的字符已经非常接近英语自然语言,也就是越来越母语化,如果这个星球上的人都能用他们自己的母语编程,软件生态将空前的强大和发展.
你完全不知道量变带来的质变是怎样的,就急着否定它?
我设想的是在编程语言的基础上实现本地化和母语化, 不是用插件实现.
你不过是站在你自己的角度考虑罢了,你没站在微软这种大企业的角度和市场的角度考虑.你不知道生态发达会是怎样一番景象,并且,你想要阻止对编程感兴趣和热心的人.
并且,阿拉伯数字和数学符号没必要中文化.

>@ufcpp 朋友你好,
我表达的意思是,本地化和母语化,就像一款国际化的软件会提供多种版本一样,


这里就不摘取更多的评论了。看到这些讨论，我突然在想：这个人在此之后有没有任何的下一步动作呢？我去翻了一下他的 Repo 列表。

有。

![qwas982 repo](/images/qwas982_repo.png)

如果这也算有的话。

所以从头到尾，这个人一直都在谈他的构想，然后想说服所有人来帮他做，没有给出任何有建设性的意见。在 Github，大家本来都用代码说话，别人没有义务来为你无偿实现代码。即使不是在 Github，要实现一项产品也不是在论坛上发一段话就可以实现的，得自己付出力量去找合作，找资本，然后自己把整个公司/社区运行起来，给出有说服力的产品，大家才有可能来尝试你的东西。别人没有义务来为你实现代码，也没有义务来使用你的产品。

其实，类似这样的思想是中国科研圈，特别是计算机领域的一个通病。从理论高度来谈一个项目的必要性谁都会做，但是要实现一个高质量的成品需要有真学识的人长期的付出投入。问题在于，现在空想家太多而实干者太少，这样的结果就是量产出一个个外强中干的空有名号的空壳产品。从 China OS 到 ~~国产~~印字 CPU，到现在火热的 AI，提着大名号的项目不计其数，国家为它们投入无数的资源，而这些投入换来的却是一个个套壳成品与开源项目抄袭丑闻。现在人人都在做中国梦，但沉溺在梦中不想苏醒，只会吹起一个个精美绝伦的泡沫，而在其破碎的瞬间在痛苦中醒来。当梦的泡沫遮蔽了真正实干者的光芒，当劣币驱逐良币，中国的科研就不可能真正全面走入世界一流之列，这也是最可悲的未来。

## 规范与妥协

根据 Github 的 Guideline：
> Issues are a great way to **keep track of tasks, enhancements, and bugs** for your projects. They’re kind of like email—except they can be shared and discussed with the rest of your team. Most software projects have a **bug tracker** of some kind. GitHub’s tracker is called Issues, and has its own section in every repository.

同时，issue 相关联的 repo(csharplang) 自己的规范：

> - Discussion should be relevant to C# language design. Issues that are not will be summarily closed.
  - Choose a descriptive title for the issue, that clearly communicates the scope of discussion.

> Design Process
In many cases it will be necessary to **implement and share a prototype of a feature in order to land on the right design, and ultimately decide whether to adopt the feature**. Prototypes help discover both implementation and usability issues of a feature. A prototype should be implemented in a fork of the Roslyn repo and meet the following bar:
Parsing (if applicable) should be resilient to experimentation: typing should not cause crashes.
**Include minimal tests demonstrating the feature at work end-to-end**.
Include minimal IDE support (keyword coloring, formatting, completion)

很明显，这个 issue 根本就和现有项目的进度、bug，或者是"enhancements"没有任何关联。即使看作是语言设计的讨论，也没有给出任何的 Prototype，还有长达 3 个屏幕才能读完的汉字内容，完全就不符合约定俗成的交流规范。

还有很多国人在一些明显写着要求使用英文讨论相关问题的国外论坛使用中文，然后以“中国人就要说中文”为理由拒绝执行规范。这就像小孩撒泼一样无赖，同时其结果也会像大多数人面对小孩撒泼的结果——不理睬——一样。

当你要求别人为你妥协的时候，你也要学会向他人妥协。言论自由不是为你违反规范后的辩解特制的挡箭牌，也不会禁止别人在你拒绝妥协后将你的 issue close 或者把你 ban 掉。

## 自尊背后的自卑

> 现在,人们看不到编程的前景,并且,因为进入这个领域的大多是**精英学者**,他们已经思维固化,认为实现中文编程汉语编程没有意义,他们已经**唯英语编程马首是瞻**,对英文编程依耐性很高,认为编程已经没有别的路可走,没有别的可能性了,因此他们不想研究中文编程汉语编程,更不会来实现,因为他们已经**被严重西化**,他们下一步要做的就是抛弃他们的母语,和承载于母语上的文化.你问他们国学是什么,他们不会知道,就算知道这个名字,他们也说不出什么是国学.对国学涵盖的广泛文化内涵一概不知.为什么,因为国学也是一种思想,而他们学的思想是西方人的文化.是西方人的**西学**.并且,因为**西方人已经建立了庞大的程序世界**,各种条件齐全,他们拿来就用,所以他们懒得再重新建立新的程序世界,是的,这样看起来没什么不好,但是,根据物质守恒定律,得到了什么,就得付出相应的代价,就得失去什么,天下没有免费的午餐,天上不会掉馅饼.其代价就是我前面说的.**迷失自我,不知自己是哪国人,不知道自己是什么种族,渐渐地无法理解生养自己的文化**.那么,**我们醒悟后的人**,应该跟着他们的屁股走吗?与他们一起堕落被同化吗?**不**.

很激烈的，充满感情的陈辞，我似乎能看见这名作者在电脑后打字时颤抖的双手。在面对“外文编程”这个“侵入”中华传统文化的造物的时候，其内心的“国人自尊”产生了非常强的反抗。有人曾经说过，如果太过于强调自尊其实是自卑的另一种表现。就像简爱一样，因为有屈辱的过往，国人的内心其实处在非常消极自卑的状态，而体现在了过度自尊上。同时，强调所谓“精英学者”，看似是对部分“不顾百姓的上层人士”的批驳，其实是对自己无力改变事物的消极抵抗。因为自己无法改变编程社区现状，就将他人扣上帽子进行批驳，然后把自己拉到“人民”的一边来壮大自己的道德力量。

要让别人看得起你，你自己首先得看得起你自己。这样看来，中国人的心理基础离大国还差得远。

>@rgwan
我在这里发这个倡议讨论的是 中文版 C# 之实现的可行性,顺便讨论下中文编程的的意义,你却要我去证明你讲的那一套,**你是在命令我吗?你不知道什么叫讨论,探讨,探索是吗?**
你认为不好,不高效,也不省事,那就随你呀,这是你的自由,只不过**不要来强加给我就行**,
我也没有强加给别人什么,如果是要一个劲地非要硬是把我的原意解读为,我是在要求别的开发团队来实现我的意志,那请便.

。。或许大部分的高素质中国人都没有自卑问题吧。。这也许就是个个例

## 敌我意识

>既然贴出了我回复你们对我的"谩骂,嘲讽和羞辱",那咋不把你们自己 **羞辱谩骂嘲讽他人**的评论也贴出来呢 ?果然是 **小人行径** .
我需要澄清一下,这几个账号 pigfromChina bctnry(当然,还有一些) **是在这里反对我的观点并进行人身攻击最多的** .我初始的时候,并没有在意他们的攻击,但是这反而 **让他们得寸进尺**. 我觉得有必要说明下他们的 **丑恶** 行径.
pigfromChina 他只是贴出了我回复他们对我的"谩骂,嘲讽和羞辱",但并没有把他们自己,羞辱谩骂嘲讽他人的评论也贴出来呢?他们的行为如何,我无须多言.
目前,这里有;
反对中文编程,
中立,
支持中文编程,
野蛮土匪,
**这几大类人在这个 iss 里**.不知**你是哪类**

好的，我们仿佛又回到了那个时代，人与人之间又要开始划左划右，争个你死我活，贴大字报批斗示众。
无论是在微博还是在任何中文社交平台上，我们对各种“党争”已经见怪不怪了。这样的习惯看来从 萌~~wen~~化 Revolution 给国人的心中种下二分敌我观的种子之后一直继承到了今天。简单地把所有人划为几类，大大方便了逻辑判断，也利于合法化自己对他人的攻击，如果别人反驳就可以用自己的道德大旗来抵挡，真的是非常方便的自欺欺人的手段。二分化的简单思路，扣帽子的习惯，阻止别人来和你站到一条线上（因为别人害怕被你的“大义”捆绑），也阻止有道德有思想的人和你交流（生怕被你攻击，也懒得理你）。当互联网环境充斥着这类人时，其结果就是充斥着不择手段的攻击与诋毁，不停挑战人性的下限（就和几十年前一个结果）。
要让国人在互联网上彻底开化，首先就要彻底去除 萌~~wen~~化 Revolution 的影响。

>duangsuse: 不要给自己臆造幻想中的敌人, 认为别人粗鲁的人首先应该审视自己.

## 关于真正的中文编程

话说回来，如果真的要讨论中文编程，易语言虽然被很多人说得很不堪，但其实也是个不错的选择。。至少在国内而言

另外，有宝岛人提出了一种优雅的[中文 perl 变体](https://github.com/audreyt/lingua-sinica-perlyuyan)。

```plain
# The Sieve of Eratosthenes - 埃拉托斯芬篩法
use Lingua::Sinica::PerlYuYan;

  用籌兮用嚴。井涸兮無礙
。印曰最高矣  又道數然哉。
。截起吾純風  賦小入大合。
。習予吾陣地  並二至純風。
。當起段賦取  加陣地合始。
。陣地賦篩始  繫繫此雜段。
。終陣地兮印  正道次標哉。
。輸空接段點  列終註泰來。
```
```plain
#!/usr/bin/env perl
use Lingua::Sinica::PerlYuYan;

用警兮用嚴。

印道
一至一
哉兮

印編曰雜申
      雜申矣
又纖曰龍鼠矣
  又曰
    一矣

亂曰
國無人莫我知兮    又何懷乎故都
既莫足與為美政兮  吾將從彭咸之所居

資曰
印重一至一兮
重起一至十合始印終
```
```plain
use Lingua::Sinica::PerlYuYan;

註俄農式乘法
無警兮

          用
         通兮
        副俄農
       始吾起純
      衰又純添合
     賦諸兮吾純果
    兮當起純衰大壹
   合始純衰賦整純衰
  除貳兮純添賦貳乘純
 添兮純果賦純果加純添
倘壹等純衰模貳終純果終

use Test::More tests => 1;
is 俄農(18,23), 414;
```

真正正确的面对中文编程的态度，也是很多国人缺少的实干的态度。
