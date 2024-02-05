---
share: true
title: DNS란? 자세한 DNS 쿼리 과정 및 캐싱
date: 2024-02-05
tags:
  - DNS
categories:
  - Network
---


# DNS?
모든 디바이스들은 인터넷 상에서 서로 간의 통신을 위한 Internet Protocol(IP) 주소를 보유하고 있다. IP 주소는 기본적으로 숫자로 구성된 복잡한 문자열의 형태를 띄고 있기 때문에 사람이 읽기 쉽고 기억하기 편한 이름으로 변환할 필요가 있는데, 이 때 사용되는 것이 DNS 이다:[1] 

DNS 는 기본적으로 전화번호부 같은 역할을 하며 셀 수 없이 많은 DNS Zone으로 구성된 거대한 데이터베이스이다. DNS Zone들의 최상위에는 DNS Root Zone이 있으며 Root Zone 바로 아래에는 org,com,net 과 같은 TLD들이 위치한다. Root Zon e으로부터 탑다운 형식으로 구성된 전화번호부인 셈이다.

```
DNS Root Zone
ㄴTLD (org, com, net...)
	ㄴDNS Zones (wikipedia.org, google.com, gov.uk ...)
```

DNS Zone은 다수 개의 DNS 이름을 보유한 도메인의 영역을 말한다. 

```
예) 
DNS Zone: wikipedia.org
DNS Zone을 구성하는 하위도메인들: ko.wikipedia.org, en.wikipedia.org 등등
```

## DNS 쿼리 과정
> 유저가 브라우저에 www.google.com 을 입력하는 순간부터 페이지를 반환받을 때 까지 일어나는 DNS Resolve과정

```
1. 브라우저 캐시 확인
브라우저는 먼저 자체 DNS 캐시를 확인하며 캐시에 해당 도메인의 IP 주소가 이미 있으면 추가적인 DNS 조회 없이 캐시된 IP 주소를 사용한다.

2. 로컬 호스트 파일 확인
브라우저 캐시에 해당 도메인이 없으면 로컬 호스트 파일을 확인한다.
호스트 파일에 도메인과 관련된 IP 주소가 정의되어 있을 경우 브라우저는 해당 주소를 사용한다.

3. 1,2에서도 IP 주소를 찾을 수 없다면 운영체제의 로컬 DNS Resolver(예: systemd-resolved)가 동작한다.
이 Resolve는 사용중인 리졸버의 Configuration File(예: /etc/resolv.conf, /etc/systemd/resolved.conf 등) 파일에서 설정된 DNS 서버(네임서버 예: 1.1.1.1)로 DNS Query를 보낸다. 여기서부터 시작되는 재귀적인 쿼리 전달 과정을 DNS Delegation이라고 한다.

* 만일 네임서버를 커스텀 설정하지 않았다면 ISP에서 운영하는 Recursive DNS 서버로 쿼리를 보낸다.
* 운영체제의 DHCP 클라이언트로부터 받은 정보를 통해 Recursive DNS 서버의 IP 주소를 알고 있음

4. 1.1.1.1 네임서버는 TLD 서버부터 출발하여 도메인 이름을 해석하고 결과를 로컬 DNS Resolver(예: systemd-resolved)에게 반환한다

5. 로컬 DNS Resolver(예: systemd-resolved)는 받은 DNS 응답을 애플리케이션 또는 브라우저에게 전달한다.
```


## DNS 캐싱?
> 앞서 살펴본 DNS Delegation 과정은 쿼리당 2~60밀리초 가량이 소비되는 과정이다. 이를 절약하고 보다 빠른 로드를 위해 캐싱을 사용하게 된다. DNS 캐싱은 이전에 수행한 DNS 쿼리의 결과를 일정 기간 동안 저장하여 동일한 쿼리가 반복될 때 더 빠른 응답을 가능하게 하는 매커니즘이다.

DNS 캐싱은 두 가지 주요 유형이 있다.
```
1. 클라이언트 캐싱(OS, 애플리케이션)
2. 네임서버 캐싱
```

### 클라이언트 캐싱(OS 레벨)
- 사용자의 컴퓨터 또는 네트워크 장비에서 수행한 DNS 쿼리 결과를 저장한다.
- 클라이언트 캐싱은 사용자의 개별 장치에서 이루어지며, 각 장치는 자체 로컬 캐시를 유지한다.
- 캐시는 TTL(Time-To-Live) 값에 따라 유지 기간을 가지며 TTL 만료 시 해당 캐시는 갱신되거나 삭제된다.

### 클라이언트 캐싱(애플리케이션 레벨)
- 메모리 캐시: 
	- 애플리케이션이 메모리에 DNS 응답을 캐시하여 동일한 도메인에 대한 반복적 DNS 조회를 방지한다. 메모리 캐시는 애플리케이션 실행 중에만 지속되며, 애플리케이션 종료시 캐시도 소멸한다.
- 로컬 파일 시스템 캐시: 파일로 응답을 저장하고 읽어오는 방식
	- 애플리케이션이 여러 실행 사이클 동안 캐시를 유지하기 위해 로컬 파일 시스템에 DNS 응답을 저장하고 필요할 때 읽어와서 사용한다
- 외부 DNS Resolver 사용: 외부 서버에서 DNS 응답을 가져오는 방식
	- 애플리케이션이 외부 DNS Resolver 라이브러리를 사용하여 DNS 조회를 처리하고 결과를 캐싱한다. 여러 애플리케이션에 같은 Resolver 라이브러리를 공유할 수 있어 중복된 DNS 조회를 방지할 수 있다.

### 네임서버 캐싱
- 네임서버가 수행한 DNS 쿼리 결과를 저장한다.
- 네임서버 캐싱은 DNS 서비스를 제공하는 서버에서 이루어지며, 다수의 클라이언트가 공유하는 캐시를 관리한다.
- DNS 서버는 자주 찾는 도메인에 대한 응답을 캐시에 저장하여 동일한 도메인에 대한 쿼리 응답시간을 단축한다.

---
References
- [1] https://www.nslookup.io/learning/what-is-dns/
