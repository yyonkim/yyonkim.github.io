---
share: true
title: Linux 네트워크 패킷 필터링 (Network Packet Filtering)
date: 2024-02-28
tags:
  - network
categories:
  - OS
---



## 네튿워크 패킷 필터링이 필요한 경우?

> OS 레벨의 네트워크 패킷 필터링은 아래와 같은 상황에서 사용될 수 있습니다.

- 특정 Port를 닫거나 열고 싶을 때
- 특정 Port로 향하는 트래픽을 다른 Port로 리디렉션(포워딩) 하기
- 특정 Port에 대한 액세스를 IP로 제한하기
- 특정 IP로 향하는 아웃바운드 트래픽을 Block 하기


## 서버 포트 상태 확인

먼저 원격 server1의 eth0 네트워크 인터페이스에 대해 간단히 curl 명령을 이용해 포트를 체크해봅니다.

```bash
~$ curl (server1 IP주소):(포트번호)
```

출력 결과는 아래 중 하나가 반환될 수 있습니다.

1. 연결 성공
- 특정 포트에서 Listen 중인 서비스가 있을 경우 `app on port (포트번호)` 와 같이 해당 서비스로부터 데이터 또는 적절한 응답이 반환됩니다.

2. 연결 거부(Connection Refused): 서비스 없음/방화벽/네트워크
- 서버가 해당 포트에서 서비스를 제공하지 않거나 방화벽/네트워크 장비로 인해 연결이 막힌 경우 `"Failed to connect to (server1) port (6000) after 4 ms: Connection refused`" 와 같은 오류 메시지가 반환될 수 있습니다.

3. 타임아웃(Connection Timeout): 서버 응답하지 않음
- 서버가 응답하지 않아 일정 시간 내에 연결이 이루어지지 않은 경우 타임아웃 오류가 발생할 수 있습니다.

4. DNS 오류(Name Resolution Failed): 호스트 이름/IP 찾을 수 없음
- 호스트 이름이나 IP 주소를 찾을 수 없는 경우 `"Could not resolve host: server1"` 과 같은 DNS 에러 메시지가 반환될 수 있습니다.

5. 네트워크 오류: 네트워크 문제
- 네트워크 문제로 인해 연결이 실패한 경우 `"Failed to connect to server1 port 3000: Network is unreachable"` 과 같은 에러 메시지가 반환될 수 있습니다.



## 네트워크 인터페이스 (eth0) 에 네트워크 패킷 필터링 적용하기

우선 eth0 에 대한 iptables 규칙을 확인합니다.

```bash

# 네트워크 인터페이스 확인

~$ ip a

# iptables 규칙 확인

~$ iptabls -L

Chain INPUT (policy ACCEPT)

target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)

target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)

target     prot opt source               destination    

➜ root@data-002:~$ iptables -L -t nat

Chain PREROUTING (policy ACCEPT)

target     prot opt source               destination         

Chain INPUT (policy ACCEPT)

target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)

target     prot opt source               destination         

Chain POSTROUTING (policy ACCEPT)

target     prot opt source               destination
```

위와 같이 현재 적용 중인 패킷 필터링 규칙이 없는 것을 확인하였다면, 테스트로 아래 4개의 상황을 적용해 봅니다.

(1) 특정 Port를 닫거나 열고 싶을 때
(2) 특정 Port로 향하는 트래픽을 다른 Port로 리디렉션(포워딩) 하기
(3) 특정 Port에 대한 액세스를 IP로 제한하기
(4) 특정 IP로 향하는 아웃바운드 트래픽을 Block 하기


### (1) 특정 Port를 닫거나 열고 싶을 때
> 예) iptables에 추가하겠습니다 / 들어오는(Inbound) 트래픽 규칙을 / 네트워크 인터페이스 / eth0에 /  프로토콜은 / 모든 tcp/ 목적지 포트가 / 3000번 인 경우 / drop 처리

- 문장 순서 그대로, iptables -A / INPUT / -i / eth0 / -p / tcp / --dport / 3000 / -j drop 와 같이 작성하면 됩니다. 처음이 많이 헷갈리지만 syntax 구조를 이해하고 나면 금방 적응할 수 있습니다.

```bash
~$ iptables -A INPUT -i eth0 -p tcp --dport 3000 -j DROP

~$ iptables -L

Chain INPUT (policy ACCEPT)

target     prot opt source               destination         

DROP       tcp  --  anywhere             anywhere             tcp dpt:3000 # new rule

Chain FORWARD (policy ACCEPT)

target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)

target     prot opt source               destination

```

위와 같이 설정하면 로컬호스트에서는 해당 포트가 정상적으로 액세스 가능하지만 원격지 서버에서는 액세스가 불가합니다.

```bash
root@server1 ~$ curl localhost:3000
app on port 3000

user1@client ~$ curl server1:3000
curl: (7) Failed to connect to server1 port 3000 after 0 ms: Connection refused
```

### (2) 특정 Port로 향하는 트래픽을 다른 로컬 Port로 리디렉션(포워딩) 하기 (NAT)
> 예) iptables에 추가하겠습니다 / Prerouting 규칙을 / 네트워크 인터페이스 / eth0 에 /  NAT로 / 프로토콜은 / 모든 tcp / 목적지 포트가 2000 일 경우 / Redirection 처리 / 2001 포트로

```bash
~$ iptables -A PREROUTING -i eth0 -t nat -p tcp --dport 2000 -j REDIRECT --to-port 2001

~$ iptables -L -t nat

Chain PREROUTING (policy ACCEPT)

target     prot opt source               destination         

REDIRECT   tcp  --  anywhere             anywhere             tcp dpt:x11 redir ports 2001 # new rule

Chain INPUT (policy ACCEPT)

target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)

target     prot opt source               destination         

Chain POSTROUTING (policy ACCEPT)

target     prot opt source               destination
```

원격에서 기존 포트 2000 번에 대해 curl 명령을 주면 2001 포트로 리디렉션 되는 것을 확인할 수 있습니다

```bash
user1@client ~$ curl server1:2000
app on 2001
```

### (3) 특정 Port에 대한 액세스를 IP로 제한하기
> 예) iptables에 추가하겠습니다 / 인바운드 규칙을 / 네트워크 인터페이스 eth0에 / 프로토콜은 모든 tcp / 목적지 포트가 6000 이고 / 소스 ip가 192.168.10.80 일 경우 / accept 처리

```bash
~$ iptables -A INPUT -i eth0 -p tcp --dport 6000 -s 192.168.10.80 -j ACCEPT
```


### (4) 특정 IP로 향하는 아웃바운드 트래픽을 Block 하기
> 예) iptables에 추가하겠습니다 / 아웃바운드 규칙을 / 네트워크 인터페이스 eth0에 / 목적지 ip가 192.160.10.80 일 경우 / 프로토콜은 모든 tcp /  drop 처리

```bash
~$ iptables -A OUTPUT -i eth0 -d 192.160.10.80 -p tcp -j DROP
```

아웃바운드 트래픽을 block 처리한 후 로컬호스트에서 192.150.10.80 에 대한 포트 스캔과 같은 연결을 실행해보면 timeout 에러가 발생하게 됩니다.

```bash
~$ nc 192.150.10.80 22
# timeout
```