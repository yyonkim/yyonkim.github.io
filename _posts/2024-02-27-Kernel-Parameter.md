---
share: true # means published from Obisidian
title: "Linux 주요 커널 파라미터 확인하기" # add (test) if this is a test doc
date : "2024-02-27" # publish date
tags : [kernel] # tags 
categories : [OS] # Category (Troubleshooting, OS, Language, Network, Kubernetes, Docker ...)
---


### systctl과 커널 파라미터

커널 특정 기능의 활성화/비활성화 여부를 제어하고 값을 커스터마이즈 하기 위해 커널 파라미터를 설정할 수 있습니다.
커널 파라미터는 /proc/cmdline 파일을 통해 커맨드 라인으로 제어할 수 있으며, 이렇게 설정된 값들은 GRUB2 부트로더에 의해 생성되는 boot/grub/grub.cfg 파일에 저장됩니다.


### 주요 커널 파라미터 확인 방법

/proc 파일시스템 디렉토리에 존재하는 파일들을 직접 수정 및 변경하는 방법으로 커널 파라미터를 조절하거나 sysctl 커맨드라인을 통해 제어할 수 있습니다.
`sysctl` man page: "Configure kernel parameters at runtime"

커널 설정값들을 조회하면 아래와 같이 다양한 값이 나타납니다.
```bash

~# sysctl -a
abi.vsyscall32 = 1
debug.exception-trace = 1
debug.kprobes-optimization = 1
dev.raid.speed_limit_max = 200000
dev.raid.speed_limit_min = 1000
dev.scsi.logging_level = 0
dev.tty.ldisc_autoload = 0
fs.aio-max-nr = 65536
fs.aio-nr = 0
fs.binfmt_misc.WSLInterop-late = enabled
fs.binfmt_misc.WSLInterop-late = interpreter /init
fs.binfmt_misc.WSLInterop-late = flags: P
fs.binfmt_misc.WSLInterop-late = offset 0
fs.binfmt_misc.WSLInterop-late = magic 4d5a
fs.binfmt_misc.WSLInterop = enabled
fs.binfmt_misc.WSLInterop = interpreter /init
fs.binfmt_misc.WSLInterop = flags: PF
fs.binfmt_misc.WSLInterop = offset 0
fs.binfmt_misc.WSLInterop = magic 4d5a
fs.binfmt_misc.status = enabled
fs.dentry-state = 32900 12060   45      0       3386    0
fs.dir-notify-enable = 1
fs.epoll.max_user_watches = 3634242
fs.fanotify.max_queued_events = 16384
fs.fanotify.max_user_groups = 128
fs.fanotify.max_user_marks = 135709
fs.file-max = 9223372036854775807
fs.file-nr = 1488       0       9223372036854775807
fs.inode-nr = 29476     0
fs.inode-state = 29476  0       0       0       0       0       0
fs.inotify.max_queued_events = 16384
[..]
```

이 중 IPv4 Forwarding을 설정하는 파라미터를 찾으려면 grep을 이용할 수 있으며, 값을 주지 않으면 조회가 되고 -w 옵션과 함께 값을 주면 설정이 됩니다.

```bash
:~# sysctl -a | grep ip_forward
net.ipv4.ip_forward = 0
net.ipv4.ip_forward_update_priority = 1
net.ipv4.ip_forward_use_pmtu = 0
```

net.ipv4.ip_foward는 0 또는 1을 가질 수 있는 파라미터이며, 이를 활성화 시키려면 아래와 같이 설정할 수 있습니다.

```bash
~# sysctl net.ipv4.ip_forward
1

~# sysctl -w net.ipv4.ip_forward=1
net.ipv4.ip_forward = 1

~# sysctl -a | grep ip_forward
net.ipv4.ip_forward = 1
```

이는 echo를 통해 /proc/sys/net/ipv4/ip_forward 파일에 직접 값을 준 것과 동일한 결과가 됩니다.

```bash
~# echo "1" > /proc/sys/net/ipv4/ip_forward

~# cat /proc/sys/net/ipv4/ip_forward
1
```

조정한 값을 영구적으로 설정하기 위해 /etc/sysctl.conf 파일에 쓰면 커널 파라미터의 기본값을 덮어쓰며 다시 시작할 필요 없이 즉시 영구적으로 적용됩니다.

```bash
~# cat /etc/sysctl.conf | grep ip_forward
net.ipv4.ip_forward=1

~# sysctl -p /etc/sysctl.conf
```


References:
https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/9/html/managing_monitoring_and_updating_the_kernel/configuring-kernel-parameters-permanently-with-sysctl_configuring-kernel-parameters-at-runtime