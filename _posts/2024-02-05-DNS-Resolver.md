---
share: true
pin: true
title: DNS Resolver와 네임서버 설정 방법
date: 2024-02-05
tags:
  - DNS
categories:
  - Network
---


# DNS Resolver ?

> 특정 OS 에서 DNS nameserver를 변경하여 고정적으로 사용하는 방법은?

DNS는 인터넷에서 도메인 이름을 IP 주소로 변환하거나 IP 주소를 도메인 이름으로 변환하는 데 사용되는 시스템이다. DNS Resolver는 주어진 도메인 이름에 대해 해당하는 IP 주소를 찾아주는 서버나 소프트웨어를 의미한다. DNS Resolver는 사용자가 웹 브라우저에 도메인을 입력하면, 해당 도메인의 IP 주소를 찾아주어 통신이 가능하게 한다:[1]

DNS 쿼리는 주로 UDP(포트 53) 프로토콜을 사용하지만, 대용량 데이터나 캐시를 초과하는 경우 TCP를 사용할 수도 있다.
DNS Resolver는 DNS 서버에 직접적으로 쿼리를 보내기 위해 네트워크 구성 및 사용자 설정에 따라 DNS 서버 정보를 얻고 쿼리를 수행한다. 일반적으로 네트워크 관리자는 DHCP 서버를 통해 호스트에게 적절한 네트워크 구성 정보를 제공하도록 구성하며, 네트워크에서 호스트에게 IP 주소, 서브넷 마스크, 게이트웨이 등과 같은 네트워크 구성 정보를 동적으로 할당하는데 DHCP 프로토콜을 사용한다. DNS Resolver는 이러한 네트워크 설정을 기반으로 DNS 서버 정보를 얻고 쿼리를 수행한다.

아래는 대표적으로 많이 사용되는 DNS Resolver 소프트웨어이다. 

1. **BIND (Berkeley Internet Name Domain):**
    - BIND는 가장 오래된 DNS 소프트웨어 중 하나로, 많은 서버에서 사용된다.
    - 유연하고 강력한 기능을 제공하며, 많은 옵션과 설정이 가능하다.
2. **Unbound:**
    - Unbound는 빠르고 경량화된 DNS Resolver로 알려져 있다.
    - 캐싱과 안전한 DNSSEC(도메인 이름 시스템 보안 확장) 지원 등을 특징으로 한다.
    - 대부분의 리눅스 배포판에서 사용 가능하며, 쉽게 설정할 수 있다.
3. **dnsmasq:**
    - dnsmasq는 경량 DNS 및 DHCP 서버이자 캐시 메커니즘을 갖춘 소프트웨어이다.
    - 주로 가정 내에서 소규모 네트워크 환경에서 사용되며, 간단하고 설정이 용이하다.
4. **systemd-resolved:**
    - systemd-resolved는 systemd의 일부로 제공되는 DNS Resolver 이다.
    - 많은 최신 리눅스 배포판에서 systemd를 사용하므로, systemd-resolved가 자주 활용된다.
    - DNSSEC와 함께 작동하며, 네트워크 관리와 통합된 기능을 제공한다.
5. **knot Resolver:**
    - Knot Resolver는 빠르고 안정적인 DNS Resolver로 알려져 있다.
    - 캐싱과 DNSSEC를 지원하며, 모듈화된 아키텍처를 갖추고 있다.
6. **netplan** :[2]
	- Ubuntu에서 네트워크 구성을 관리하는 도구 중 하나로, YAML 형식의 설정 파일을 사용하여 네트워크 설정을 정의한다.
	- 설정파일: `/etc/netplan/01-netcfg.yaml` 
	- 변경사항 적용 방법: `sudo netplan apply`
	- .yaml 예시(이렇게 설정하면 해당 네트워크 인터페이스가 DHCP를 통해 IP 주소를 받으면서, Google Public DNS (8.8.8.8, 8.8.4.4)를 DNS Resolver로 사용하게된다.)
	-  Ubuntu 20.04 이후 버전에서부터는 `systemd-resolved`의 설정 파일(`/etc/systemd/resolved.conf`)을 직접 편집하는 것이 권장된다.
```bash
network:
  version: 2
  renderer: networkd
  ethernets:
    enn5:
      dhcp4: true
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```


## 어떤 DNS Resolver가 현재 활성화되어 있는지 확인하는 법

**systemd-resolved 사용 시:**
- `systemctl status systemd-resolved`
**BIND 사용 시:**
- `named -v`
**Unbound 사용 시:**
- `unbound -V`
**dnsmasq 사용 시:**
- `dnsmasq -v`
**netplan**
- `netplan status [interface]`


# DNS Resolver 모드, Stub? Uplink?

DNS Resolver의 "Uplink Mode"와 "Stub Mode"는 Resolver가 DNS 쿼리를 처리하는 방식을 나타낸다.
일반적으로 /etc/resolv.conf 및 /etc/systemd/resolved.conf 에서 모드를 변경할 수 있다. 

**Uplink Mode:**
업링크(Uplink) 모드에서는 DNS Resolver가 로컬에서 DNS 쿼리를 수신하고, 이를 상위 레벨의 DNS 서버(업링크 서버)로 전달한다.
업링크 서버는 특정 도메인에 대한 쿼리를 해결하기 위해 상위 계층의 DNS 서버에 다시 쿼리를 보내는 역할을 한다.
로컬에서 받은 응답은 Resolver에 의해 캐시되어 다음에 동일한 쿼리가 있을 때 빠른 응답을 가능하게 한다.

    - 사용자가 "www.example.com"에 대한 DNS 쿼리를 하면 로컬 DNS Resolver가 이를 받는다.
    - Uplink 모드에서는 Resolver가 "www.example.com"에 대한 DNS 정보를 상위 레벨 DNS 서버로 전달한다.
    - 상위 DNS 서버는 "www.example.com"의 IP 주소를 알려주고, 이 응답은 로컬 DNS Resolver에 캐시된다.

**Stub Mode:**
기본적으로 /etc/resolv.conf는 로컬 호스트 스텁(Stub) 리졸버를 가리킨다. systemd-resolved에서 `DNSStubListener=yes`가 기본값인 것이 이에 해당하며, 이는 로컬에서 DNS 쿼리를 수신하는 역할을 한다. Stub 리졸버는 업링크 모드와 달리 상위 계층의 DNS 서버에 쿼리를 직접 보내지 않고 지정한 DNS 서버로 바로 쿼리를 보낸다. 즉, Stub 모드에서는 로컬에서 DNS 쿼리를 처리하며, 이를 특정 외부 DNS 서버로 바로 전달한다. 이를 변경하려면 다른 내용으로 파일을 다시 만들거나 로컬 호스트 스텁 리졸버가 아닌 다른 곳을 가리키도록 해야한다. 

    - 사용자가 "www.example.com"에 대한 DNS 쿼리를 하면 로컬 DNS Resolver가 이를 받는다.
    - Stub 모드에서는 Resolver가 "www.example.com"에 대한 DNS 정보를 사용자가 지정한 외부 DNS 서버(예: 8.8.8.8)로 전달한다.
    - 외부 DNS 서버(스텁 서버)는 "www.example.com"의 IP 주소를 알려주고, 이 응답은 로컬 DNS Resolver에 캐시된다.


즉, Uplink Mode에서는 상위 DNS 서버로의 전달이 주요한 역할이며, Stub Mode에서는 특정 외부 DNS 서버로의 전달이 주요한 역할이다.


## 현재 DNS Resolver 모드를 확인하려면

```bash
~$ resolvectl

Global
       Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: stub --------> 현재 모드
     DNS Servers: 8.8.8.8 -----> resolved.conf에 정의한 nameserver
```


## 서버 재부팅 이후에도 resolv.conf 파일이 지정한 DNS 서버를 포함하게 하려면
서버를 다시 시작하면 사용자 지정 DNS 서버 주소가 있는 resolv.conf 파일에 대한 수동 수정 내용이 손실된다. 재부팅 시 resolv.conf 파일이 dhclient 파일에 지정한 DNS 서버만 포함하도록 업데이트 해야 한다.

1. /etc/dhcp/dhclient.conf 파일을 편집하거나 만든다

2. 도메인 이름 서버를 재정의하기 위해 파일에 supersede 명령을 추가하고 xxx.xxx.xxx.xxx 부분을 변경한다.
```bash
supersede domain-name-servers xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx;
```

3. 수정 후 재부팅 시 resolv.conf 파일이 dhclient 파일에 지정한 DNS 서버만 포함하도록 업데이트 한다

4. 인터페이스별 구성파일(/etc/sysconfig/network-scripts/ifcfg-) 에서 PEERDNS 파라미터를 yes로 설정

5. 재부팅

--- 또는 ---

1. /etc/sysconfig/network-scripts/ifcfg-eth0 파일에서 DNS1, DNS2에 원하는 네임서버 주소를 포함한다
```bash
DEVICE=eth0
BOOTPROTO=dchp
[..]
DNS1=8.8.8.8
DNS2=8.8.4.4
```

2. 인터페이스별 구성파일(/etc/sysconfig/network-scripts/ifcfg-) 에서 PEERDNS 파라미터를 yes로 설정

**만일 Ubuntu 20.04 이전 버전의 netplan.io 일 경우, DNS 서버 값을 재정의하려면 아래의 단계가 필요하다**
1. Netplan은 일반적으로 /etc/netplan 디렉토리에 구성 파일을 저장한다.
   
2. /etc/netplan/99-custom-dns.yaml 파일을 생성한 다음 플레이스홀더 DNS 서버 IP를 원하는 주소로 변경한다. (인터페이스 이름 확인이 필요한 경우 `ip a`)
```yaml
network:
  version: 2
  ethernets:
    ens5: ------------> 인터페이스 확인할 것
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1] ---> 이부분을 원하는 주소로 변경한다
      dhcp4-overrides:
        use-dns: false
        use-domains: false
```

3. 다음의 명령을 실행한다.
```bash
netplan generate
```

4. 이렇게 변경한 이후에도 /etc/resolve.conf에 여전히 스텁 리졸버 ip가 표시되며 예상된 결과이다. 스텁 리졸버 IP는 운영 체제에 로컬이다. 백그라운드에서 스텁 리졸버는 앞의 99-custom-dns.yaml 파일에 지정한 DNS 서버를 사용한다.
   
5. 인스턴스 재부팅
   
6. systemd-resolve 명령을 실행하여 시스템이 의도한 DNS 서버 IP 주소를 올바르게 수신하는지 확인한다
```
systemd-resolve --status
```


References:
[1] https://www.nslookup.io/learning/what-is-a-dns-resolver/
[2] https://netplan.readthedocs.io/en/stable/netplan-status/
[3] https://repost.aws/knowledge-center/ec2-static-dns-ubuntu-debian
