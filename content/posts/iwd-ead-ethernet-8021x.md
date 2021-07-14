---
title: iwd (ead) 配置有线以太网 802.1x 验证
date: 2021-07-14 22:14:00
tags:
  - 技术
  - 计算机
categories:
  - 技术杂谈
---

> 本文针对上海交大网络特化，但适用于所有启用 802.1X 的有线以太网。以后可能会考虑把本文的精简版放到专门的教程页面。

想必会通过 iwd 这个关键词搜索或者点进本文的都是 Archlinux/Gentoo/NixOS 折腾尝鲜人，装了 iwd 想连 802.1X 身份验证的以太网，然后汝发现 Wiki 上写的都是针对 wpa_supplicant 的步骤，吃了闭门羹。所以本文会比较偏专业向。如果汝配了半天配不过来，建议还是老实 wpa_supplicant 加 network manager 一键配（但是似乎证书也不是那么好一键配置，也可以参考各企业或者组织自己的教程，大概率也是针对 wpa_supplicant 的。

## 太长不看版

如果汝熟知 iwd 与 nm/systemd-networkd 并已经成功配置了 WiFi EAP 认证的：

将 WiFi 版的配置复制到 /var/lib/ead/default.8021x，随后启动 ead systemd 服务并照常配置 network manager/systemd-network/任意网络管理器 即可。

## Linux 上有线网的 802.1X

IEEE 802.1X 是 IEEE 制定关于用户接入网络的认证标准，是一种企业级的网接入认证方案。它比较常见的场景是在无线网下管理接入，上海交大全校此前覆盖的无线网即是通过这套方案接入，很多企业的无线网也是这样。但是有时候这套方案也会用于有线以太网，不如说有线网是它最早的使用场景，只不过之后用的人很少罢了。

在 Linux 下，802.1X 现有的认证实现都是无线网守护程序，包括 wpa_supplicant 和 iwd。wpa_supplicant 和早期的 iwd 的实现方式都是将有线网接口转换为虚拟无线 ap，然后再走这个虚拟的无线设备完成认证的。但是似乎新版的 iwd 有一套新的实现，咱没翻到相关文档，实现也没看出个所以然，所以此处不表（

## iwd

这里照抄 ArchWiki 上的介绍。

> iwd (iNet wireless daemon，iNet 无线守护程序) 是由英特尔（Intel）为 Linux 编写的一个无线网络守护程序。该项目的核心目标是不依赖任何外部库，而是最大程度地利用 Linux 内核提供的功能来优化资源利用。
>
> iwd 可以独立工作，也可以和 ConnMan、systemd-networkd 和 NetworkManager 这样更完善的网络管理器结合使用。

总而言之，iwd 是 wpa_supplicant 的现代替代，体积小实现干净配置简单，比 wpa_supplicant 一大坨不明所以的配置和命令行工具高到不知道哪里去了。如果汝日常习惯命令行/systemd unit 连无线，或者喜欢用 netctl/systemd-networkd 之类的无 gui 网络管理器的用户，咱强烈建议试用，毕竟配置文件干净，iwctl 的命令行也很好用。具体 iwd 的配置还是参见各发行版自己的文档。 Btw, [iwd(ArchWiki)](https://wiki.archlinux.org/title/Iwd)（逃

然而这里有一个问题。如果汝已经搜过了 iwd wired 8021x 等关键词的话可能已经发现，网上相关的资料少得可怜.. 咱搜了很久，只搜到几个问题和邮件列表的讨论，没一篇说了怎么配置，而文档也只有 `man ead` 里的寥寥数笔。怀疑是因为 iwd 并没有把开发重心放在上面，这个用途也比较罕见，导致相关文档基本是空白。不过可以了解到的事实是：iwd 有一个独立的工具叫 ead (Ethernet authentication daemon) 来完成以太网的 802.1X 认证，通过标准 dbus 接口控制，启动后会自动监听在线的网络设备并应答鉴权包。

所以咱决定直接翻 iwd 的代码，然后发现了这些东西：[wired/network.c](https://git.kernel.org/pub/scm/network/wireless/iwd.git/tree/wired/network.c#n125) 和 [wired/ethdev.c](https://git.kernel.org/pub/scm/network/wireless/iwd.git/tree/wired/ethdev.c#n243)。

总之，当 ead 启动后，会自动读取 /var/lib/ead/default.8021x 的内容，以 iwd 标准格式读取 `Security` 段下以 `EAP` 开头的各个 field。这个配置文件的格式参照 [这个文档](https://iwd.wiki.kernel.org/networkconfigurationsettings)。特别关注其中 "802.1x (WPA/WPA2 Enterprise) settings" 一段，因为基本只有这段的配置会被 ead 读取。随后，以管理员权限启动 ead (顺便，Archlinux 的 iwd/ead 的二进制文件的位置很怪，在 /usr/lib/iwd/ 下)，其就会自动完成所有有线网络接口下的 802.1X 认证了。

当然，这里建议通过 systemd unit 启动 ead 服务 (`sudo systemd enable --now ead`)，如果发行版没有打包进去的话可以参考 [wired/ead.service.in](https://git.kernel.org/pub/scm/network/wireless/iwd.git/tree/wired/ead.service.in) 写一个 systemd unit。

如果汝使用的是 Gentoo ，要注意安装 iwd 的时候需要开启 `wired` flag 才会编译 ead。

## 交大相关配置

这边假定汝使用的是 systemd-networkd，如果使用了其他的网络管理器就按照相应的文档配置。配置宗旨就是启用相应设备并启动 dhcpv4 & dhcpv6 服务。

在 `/etc/systemd/network/` 目录下创建 `20-wired.network`，或者沿用汝先前的网络配置，并添加以下内容

``` ini
[Match]
Name=<interface>

[Network]
DHCP=yes
```

将其中的 `<interface>` 改为汝的有线网卡设备接口，可以用 `ip link` 命令找到所有的接口，其中 `eth?` 或者 `enp*` 类似物即是有线以太网设备了。

然后在 `/var/lib/ead/` 下创建 `default.8021x` 文件（ead 目录可能不存在，需要用户自己以管理员权限创建），添加以下内容

``` ini
[Security]
EAP-Method=PEAP
EAP-Identity=<username>@sjtu.edu.cn
EAP-PEAP-CACert=/etc/ssl/certs/Go_Daddy_Root_Certificate_Authority_-_G2.pem
EAP-PEAP-ServerDomainMask=radius.net.sjtu.edu.cn
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=<username>
EAP-PEAP-Phase2-Password=<password>
```

将其中的 `<username>` 和 `<password>` 分别置为汝的 jAccount 账户（不包括 @sjtu.edu.cn）和密码。

其实，将这个文件原样复制到 `/var/lib/iwd/SJTU.8021x` 并添加以下内容，启动 iwd 服务，就可以自动连接 SJTU 校园 WiFi 了。

``` ini
[Settings]
Autoconnect=true
```

## 总结

以上内容都是基于 Archlinux 的，由于咱手边没有 Gentoo/NixOS 等 ~~异教徒~~ 系统，无法验证所有系统的配置是否一致。如果汝是 ~~异教徒~~，只要记住按照 WiFi 的认证设置格式编写 ead 目录下的 `default.8021x` 配置文件，并启动 ead 服务即可。

如果联网失败，重点排查 ead 是否启动，systemd-networkd 是否工作正常，dhcp 服务器是否启动，以及网络接口是否处于 UP 状态。当然，也有可能是 ead 自己的 bug，在这种情况下，可以关闭 ead 的 systemd 服务，并通过 `sudo (/usr/lib/iwd/)ead -d` 以 debug 模式启动 ead，看看有没有什么错误日志，随机应变（

如果汝发现本文有错误，或是想提供其他系统的配置流程，欢迎发邮件给咱或者在下方评论（