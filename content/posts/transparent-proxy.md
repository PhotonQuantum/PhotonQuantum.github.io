---
title: 透明代理
date: 2019-08-20 20:06:00
tags:
  - 技术
  - 计算机
categories:
  - 技术杂谈
---
# 概述
最近我新收了一台 Apple TV 3，遂发现垃圾苹果没有给出任何代理设置，导致无法观看大部分海外节目。为了解决这个问题，有必要搭建一个透明代理网关，实现免配置代理。实测搭建后可以完美收看所有节目，并且局域网中的设备都可以无感 fq。

# 硬件
- Raspberry Pi 一个
- 网线
- 任意路由器

本来我想直接购买智能路由，在路由上跑个代理，但是发现路由器配置普遍不强，有高性能 ARM CPU 的路由器价格动辄上千。如果 CPU 频率不够高，很容易成为代理速度的瓶颈，使用体验又会很差。所以不如直接花小几百买个树莓派跑代理，总成本低，性能还更好。

我使用了 Raspberry Pi 3B，其他型号应该也可以，差别不大。要注意的是 4 以下的型号 Ethernet 带宽只有 100M，由于所有数据无论走不走代理都要从派上过，对土豪和局域网串流来说这带宽是不够用的，建议一步到位买个最新的 4，或者购买 NanoPi Neo Plus 2 等有 1Gbps 的设备。同理，不建议使用无线，稳定性也不行，直接上有线吧。

路由器的话普通的和智能的都能用，但是一定要注意其是否有 **设置网关** 的功能。如果有的话是最好，没有的话就需要关闭路由器自己的 DHCP Server，由派来告知局域网设备网关地址。市面上大部分路由器都是可以关闭 DHCP 的。

# 实现
## Archlinux ARM
作为 Archlinux 教成员，强烈推荐在派上安装 Archlinux ARM。Archlinux 是一个滚动更新的发型版，秉持 KISS(Keep It Simple Stupid) 原则，在嵌入式系统上部署是再好不过了。包非常新，而且有强大的 AUR 系统，不会有 Raspbian 等系统会有的上古神包问题。和自带 Raspbian 不同，Archlinux Arm 默认不带图形界面，可以节省下不小的 Overhead。实测运行状态下内存占用在 100m 左右，load 在 0.2 以下。

Archlinux ARM 有对 Raspberry Pi 3 的官方支持，请查阅 [官方文档](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3)。以下配置都以 Archlinux ARM 为准。

## Clash
强力推荐 [Clash](https://github.com/Dreamacro/clash)，支持多种协议，自带 HTTP、SOCKS5、REDIR 代理，还带有一个简易的抗污染 DNS。而且，已经有不少代理服务提供商在给出 Clash 订阅配置文件了，更有提供了分流策略的商家，可以节省大量配置时间。

Clash 并不在官方 Repository 中，需要自行到 aur 下载。
```
git clone https://aur.archlinux.org/clash-bin.git
cd clash-bin
```
记得修改 PKGBUILD 文件，把 arch 从 x86-64 改成 armv7h，tar 文件地址里的 amd64 改成 armv7，sha256sums 的最后一个改成 SKIP。然后打包安装。
```
makepkg -si
```

关于标准配置不再赘述，假设已经部署基本代理和分流配置，REDIR 监听在 *\<REDIR_PORT\>* ，SOCKS5 监听在 *\<SOCKS_PORT\>* 。接下来需要配置简易的防污染 DNS。

Clash 有多种 DNS 模式，其中：

- redir-host
首先查询不可信 DNS，如果返回了海外的 IP，则查询可信 DNS 并返回可信结果，如果返回国内 IP，就直接返回不可信结果。另外，此模式下所有的请求在转发时都发送 Host，而不是 IP，这样即使得到了污染 IP，远端仍然能解析出正确的 IP。
- fake-ip
直接返回虚 IP，当收到代理请求时再让远端解析成正确 IP。

为了防止设备本地的 DNS Cache 被弄脏，这里使用 redir-host 模式。在配置文件里加这么一段：
```
dns:
  enable: true
  enhanced-mode: redir-host
  fallback: ['udp://127.0.0.1:<DNSCRYPT_PROXY_PORT>']
  ipv6: false
  listen: 0.0.0.0:<CLASH_DNS_PORT>
  nameserver: [223.5.5.5, 'tls://dns.rubyfish.cn:853']
```
*nameserver* 中可以使用任意喜欢的国内 DNS。注意：*\<DNSCRYPT_PROXY_PORT\>* 是之后将配置的 dnscrypt\_proxy 的监听端口，*\<CLASH_DNS_PORT\>* 是 Clash 的抗污染 DNS 的监听端口。如果想让 Clash 跑在普通用户上，记得安排一个高端口。

将配置文件保存在 ~/.config/clash/config.yml，随后就可以通过 systemd 启动 Clash 服务。
```
sudo systemctl enable --now clash@<user>
```
其中，*\<user\>* 是你的用户名，比如 alarm。

## DnsCrypt-Proxy
这是一个 DoT & DoH 客户端，可以通过 TLS/HTTPS 协议查询到可信的 DNS 结果，用来给 Clash 提供可信 DNS。这个包在官方仓库中，可以直接安装。
```
sudo pacman -S dnscrypt-proxy
```

配置文件在 /etc/dnscrypt-proxy/dnscrypt-proxy.toml。之后进行简单的配置修改（下面的内容是标准的 diff 输出）
```
30c30
< # server_names = ['scaleway-fr', 'google', 'yandex', 'cloudflare']
---
>  server_names = ['google', 'cloudflare']
36c36
< listen_addresses = ['127.0.0.1:53', '[::1]:53']
---
> listen_addresses = ['127.0.0.1:<DNSCRYPT_PROXY_PORT>']
95c95
< # proxy = "socks5://127.0.0.1:9050"
---
> proxy = "socks5://127.0.0.1:<SOCKS_PORT>"
193c193
< fallback_resolver = '9.9.9.9:53'
---
> fallback_resolver = '223.5.5.5:53'
220c220
< netprobe_address = "9.9.9.9:53"
---
> netprobe_address = "223.5.5.5:53"
```
记得把 *\<SOCKS_PORT\>* 改成 Clash 的 Socks5 监听端口，并且 *\<DNSCRYPT_PROXY_PORT\>* 和 Clash 中设置的一致。

然后就可以直接启动服务了。
```
sudo systemctl enable --now dnscrypt-proxy
```

## iptables
之后就需要配置 iptables，将所有的入站流量 redirect 到 Clash 上，并且劫持 DNS 请求到 Clash DNS 上了。

改写 nat 表：
```
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp -j REDIRECT --to-ports 9090
sudo iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-ports 9653
sudo iptables -t nat -A OUTPUT -d 127.0.0.1/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports 9653
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
```

然后持久化配置（记得要有 root 权限）：
```
iptables-save > /etc/iptables/iptables.rules
```

随后启动 systemd 服务以在每次重启后恢复配置：
```
sudo systemctl enable --now iptables
```

## 设置静态 IP
因为马上就要将 DHCP 指向派，就不能指望通过 DHCP 来获得树莓派的 IP、Gateway 等信息了。

修改 systemd-networkd 设置（/etc/systemd/network/eth.network）：
```
[Match]    
Name=eth*    
    
[Network]    
DHCP=no    
DNSSEC=no    
DNS=223.5.5.5    
Address=<STATIC_IP>/24    
Gateway=<ORIGIN_GATEWAY>
```
把 *\<STATIC_IP\>* 改成想指派给树莓派的 IP，*\<ORIGIN_GATEWAY\>* 改成原路由器 IP。

然后重启派，在新 IP 上连接就可以了。 

## 设置网关
根据实际情况，二选一即可。

### 直接在路由设置
如果路由器有默认网关设置，直接把网关设置成 *\<STATIC_IP\>* 就可以了。

### dhcpd
如果路由器不能设置默认网关，就需要在本地启动一个新的 DHCP Server，来告知局域网内机器新的网关。

这里我们直接利用 systemd-networkd 提供的 DHCP Server，需要修改 /etc/systemd/network/eth.network 来启动它：
```
[Match]    
Name=eth*    
    
[Network]    
DHCP=no    
DHCPServer=yes    
DNSSEC=no    
DNS=223.5.5.5    
Address=<STATIC_IP>/24    
Gateway=<ORIGIN_GATEWAY>
    
[DHCPServer]    
PoolOffset=5    
EmitDNS=yes    
DNS=<STATIC_IP>
EmitRouter=yes    
EmitTimezone=no
```

随后，关闭路由器的 DHCP，重启树莓派，如果一切顺利，就大功告成了。

# 尾声
整个过程是有些繁琐的，其实挺容易弄错的（特别是 DHCP 服务器和静态 IP 分配时）。如果遇到问题，可以查询下方的 Troubleshooting 部分，也可以在下面评论。

# Troubleshooting
## Archlinux ARM
### 无法登录 Archlinux ARM 的 root 账户
Archlinux ARM 默认配置 OpenSSH 禁止 root 登录，只需用 alarm 账户登录，随后用 su 登入 root 即可。

### 没有 sudo 命令
``` bash
pacman -S sudo
```

### 缺少 blabla 命令
可以通过 pkgfile 包来查询命令包含在哪个包里，随后安装。
```
sudo pacman -S pkgfile
sudo pkgfile --update
```

例：需要 dig 命令
```
$ pkgfile dig
extra/bind-tools
community/epic4
$ sudo pacman -S bind-tools
```

## dnscrypt-proxy
### 无法监听端口
记得关闭 systemd-resolved，防止抢端口

## 任何一步之后连不上网了
将计算机的 IP 连接方式换成静态，手动输入 IP、Gateway、Mask，然后进路由重启 DHCP 恢复网络，重启树莓派连进去看看发生了什么。
如果派连不上，用 USB TTL 连接进去（你可能需要 minicom）看看怎么回事。

常见的问题有：

- 网关或者静态 IP 设置被其他 daemon 动掉了，或者配置有错
```
ip addr show
ip route
```
看看路由和 IP 是不是配置错了。如果发现 ip route 的返回里有 DHCP 字样，或者 ip addr show 得到的 IP 有错，说明 systemd-networkd 没配置好，再检查一下，或者没有重启树莓派。

- iptables 规则没有应用
检查 iptables 服务有没有被 enable。

- clash 没有启动
查阅 Clash - 无法启动

## Clash
### 无法启动
```
sudo systemctl status clash@<user>
```
根据报错排查，有可能是端口被占用的问题，也可能是配置文件格式错误。

# 进阶
其实 Clash 的 DNS 抗污染实现不是很优雅，会将连接速度尚可而又未被污染的部分海外网站解析到更远的 CDN 节点，这种情况往往发生在有香港节点的网站上。要完全避免这个问题，需要从根本出发，主动探测域名是否被污染。

安利一波 [Calorina Project](https://gitlab.com/NickCao/calorina)，它通过多种策略探测不可信 DNS 解析得到的 IP 是否正确，来判断是否使用可信 DNS 进行解析。Archlinux 用户可以从 [AUR](https://aur.archlinux.org/packages/calorina-git) 安装。

当前这个包存在内存泄漏问题，泄漏的根源在 Golang 上游，暂时没有解决办法。因此，此法暂时不作推荐，待泄漏问题解决后，再更新相关操作。

# 后话
啊 QAQ 我果然还是不适合写这种教程类文章，总觉得博客里写这种像 ArchWiki 一样的文章感觉很奇怪 TAT

# Changelog
- 2019-08-21 改用 systemd-networkd 设置静态 IP 和 DHCP Server，不再使用 dhcpcd 和 isc-dhcp-server。(小声：systemd 要吃掉一切了嘛 qaq）
