---
share: true
pin: true
author: yonkim
title: How to Troubleshoot SSH Connectivity Issues
date: 2024-02-03
categories:
  - Troubleshooting
tags:
  - ssh
  - manual
---


## SSH 커넥션 문제(SSH Connectivity Issues)
---
SSH 클라이언트를 이용해 원격 서버에 접속하려고 할 때 이슈가 생긴다면, 첫 번째 단계는 이슈 원인을 아래 2가지로 분리하는 것이다.
만일 (2)에 해당한다면 재부팅을 통해 자원을 일시적으로 해제하거나, 하드웨어 마이그레이션, 루트 볼륨을 보조 디바이스로 연결할 수 있는 복구용 서버와 같이 별도로 원인을 분석할 수 있는 환경이 필요하게 된다.

(1) 기본적인 네트워크 연결로 인한 문제

(2) 네트워크 연결 설정과 별도의 문제
- 손상된 파일 시스템(File system corruption)
- 잘못된 파일 시스템 권한 및 파일 소유권(Wrong permission)
- 고장난 시스템 패키지 및 필수 라이브러리
- 특정 프로세스의 CPU, Memory 등의 자원 부하 및 용량 부족
- 하드웨어 문제(Droplet, Device failure)
- Deprecated keypair hash 알고리즘 및 클라이언트 버전 이슈



## 디버깅 레벨 상향을 통한 세션 이벤트 로그 조회(ssh -vvv)
---
SSH 클라이언트가 기본적으로 SSH 세션에 대해 제공하는 정보 수준은 기본적으로 quiet 이므로 문제를 디버깅할 때는  -verbose 옵션을 사용할 수 있다.
대부분의 문제는 단일 -v 에서도 확인할 수 있지만 -vvv는 보다 상향된 출력 수준을 제공하므로 디버깅 시 기본적으로 -vvv 옵션을 주는게 편하다.
ssh -vvv 명령으로 출력되는 일반적인 내용에서 각 필드를 해석하는 방법은 아래와 같다.

- **종합적인 연결 과정 확인:**
    - 연결 과정에서 `debug1`로 시작하는 각 라인을 통해 전반적인 연결 상황을 파악할 수 있다.
    
- **클라이언트에서 사용하는 키 확인:**
    - `Offering public key: ...` 또는 `Offering password: ...` 부분에서 클라이언트가 제공하는 인증 방법을 확인할 수 있다.

- **서버에서 허용하는 인증 방법 확인:**
    - `Authentications that can continue:` 부분에서 서버가 허용하는 인증 방법을 확인할 수 있다.

- **서버로 전송되는 유저 정보 확인:**
    - `debug1: Sending SSH2_MSG_USERAUTH` 부분에서 클라이언트가 서버로 보내는 사용자 정보를 확인할 수 있다.

- **서버로부터 받은 메시지 확인:**
    - `debug1: Remote protocol version` 부분에서 서버로부터 받은 SSH 프로토콜 버전을 확인할 수 있다.
    - `debug1: SSH2_MSG_SERVICE_ACCEPT received` 부분에서 서버로부터 서비스 수락 메시지를 확인할 수 있다.

- **서버 키 교환과정 확인:**
    - `debug1: SSH2_MSG_KEXINIT` 및 이에 관련된 부분에서 서버와 클라이언트 간의 키 교환과정을 확인할 수 있다.

- **서버 호스트키 확인:**
    - `debug1: Server host key` 부분에서 서버의 호스트키 정보를 확인할 수 있다.

- **암호화 및 압축 알고리즘 확인:**
    - `debug1: kex: algorithm: ...` 및 `debug1: Compression` 부분에서 사용되는 암호화 및 압축 알고리즘을 확인할 수 있다.


## ssh -vvv를 사용한 샘플 출력내용
---
```bash

$ ssh -vvv user@hostname
OpenSSH_8.2p1 Ubuntu-4ubuntu0.3, OpenSSL 1.1.1f  31 Mar 2020
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 19: Applying options for *
debug2: resolve_canonicalize: hostname hostname is address
debug2: ssh_connect_direct
debug1: Connecting to hostname [192.168.1.1] port 22.
debug1: connect to address 192.168.1.1 port 22: Connection timed out
ssh: connect to host hostname port 22: Connection timed out

```

위와 같은 출력에서 확인할 수 있는 주요 사항은 아래와 같다.

1. **OpenSSH 버전 및 운영체제 정보:** `OpenSSH_8.2p1 Ubuntu-4ubuntu0.3, OpenSSL 1.1.1f  31 Mar 2020`
2. **클라이언트 측 SSH 설정 파일 읽기 확인:** `debug1: Reading configuration data /etc/ssh/ssh_config`
3. **호스트 및 포트 확인:** debug1: Connecting to hostname [192.168.1.1] port 22.
4. **연결 시도 중 에러 발생 확인:** debug1: connect to address 192.168.1.1 port 22: Connection timed out

이렇게 출력된 내용을 통해 클라이언트가 호스트에 연결을 시도하면서 발생한 문제를 추적하고, 디버깅하여 문제를 해결할 수 있다.



## 일반적으로 많이 발생하는 SSH 에러메시지
---

일반적으로 SSH 접속이 불가할 때 확인해야 하는 메시지는 아래와 같다.

**1. Authentication failure / Permission denied (publickey, password), Server refused our key**
> 주로 인증에 실패한 경우에 관한 정보를 확인할 수 있으며, 키 또는 비밀번호 인증과 관련된 문제가 여기에 나타난다.

```bash
debug1: Authentications that can continue: publickey,password
debug3: start over, passed a different list publickey,password
debug3: preferred gssapi-keyex,gssapi-with-mic,publickey,keyboard-interactive,password
debug3: authmethod_lookup publickey
debug3: remaining preferred: keyboard-interactive,password
debug3: authmethod_is_enabled publickey

및

debug1: Offering public key: ~/.ssh/id_rsa RSA SHA256:xxxxxx
debug3: send_pubkey_test
debug2: we sent a publickey packet, wait for reply
debug3: receive packet: type 51
debug1: Authentications that can continue: publickey,password
debug1: No more authentication methods to try.
Permission denied (publickey,password).
```

- **확인 사항:**
    - 인증 방법 확인: 클라이언트가 사용하고자 하는 인증 방법이 서버에서 허용되는지 확인해야 한다.  
	- 위 예시 로그에서는 `debug1: Authentications that can continue: publickey,password` 이므로 서버는 현재 공개키 또는 패스워드 인증을 허용하고 있음을 알 수 있다.
    - 공개키 확인: 클라이언트의 공개키가 서버에 등록되었는지 확인한다.

- **확인 방법:**
	- 서버 측 확인이 필요하므로 서버에 접속하거나 서버 측 루트 볼륨을 분리하여 확인할 수 있는 다른 방법이 요구된다.
    - 서버 측 SSH 설정 확인: 서버의 SSH 설정 파일(`/etc/ssh/sshd_config`)에서 `PasswordAuthentication`과 `PubkeyAuthentication` 옵션이 yes 인지 확인
    - 서버에 등록된 공개키 확인: 서버의 `~/.ssh/authorized_keys` 파일에서 클라이언트의 공개키가 등록되어 있는지 확인
    - 클라이언트 측 공개키와 일치 여부 확인: 클라이언트 측에서 보유한 .pem 파일에 대해 공개키를 확인하려면 `ssh-keygen -y -f <private.pem>`

---

**2. Connect to host port 22: Connection refused**
> 호스트의 SSH 포트에 연결할 수 없는 경우의 오류 메시지가 나타나며, 호스트에서 SSH 서비스가 실행 중이지 않거나 포트가 제대로 열려있지 않은 경우에 해당된다.
> Connection Refused 에러는 호스트에서 원격으로 전송되는 메시지이다.

```bash
ssh: connect to host example.com port 22: Connection refused
```

- **확인 사항:**
    - SSH 서비스 확인: 호스트에서 SSH 서비스 데몬(sshd)이 제대로 실행 중인지 확인
    - 포트 확인: 호스트의 방화벽이나 네트워크 장비에서 SSH 포트(기본값 22)이 열려있는지 확인
  
- **확인 방법:**
    - 서버 SSH 상태 확인: 호스트에서 SSH 서비스가 동작 중인지 확인하기 위해 `sudo systemctl status sshd` 또는 `service sshd status`를 사용
    - 포트 확인: 호스트에서 `sudo ss -tulpn | grep :22` 명령어를 사용하여 22번 포트가 열려 있는지 확인

---

**3. Connect to host port 22: Connection Timedout**
> ssh: connect to host example.com port 22: Connectino Timedout
> 오류 메시지는 SSH 클라이언트에서 발생하며, 서버가 클라이언트에 응답하지 않아 클라이언트 프로그램이 중단(제한 시간 초과)되었음을 나타낸다.

- **확인 사항:**
	- 접속하려는 IP 또는 호스트 이름이 정확한지 확인
	- 호스트의 상태가 정상인지 확인
	- SSH 클라이언트와 호스트 간의 연결을 차단하는 방화벽 유무 확인
	- 호스트 측 방화벽, Network ACL, TCP 래퍼에 의한 SSH 프로토콜 및 포트 차단 확인
	
- **확인 방법:**
	- (호스트) TCP 래퍼: `/etc/hosts.allow`, `/etc/hosts.deny`
	- (호스트) 22번 포트 수신 여부 확인: `sudo ss -tulpn | grep :22`
	- (호스트) 방화벽 여부 확인: `sudo iptables -L` 또는 (Ubuntu) `sudo ufw status`
	- (호스트) nacl `cat /etc/network/options`

---

**4. Host key verification failed**
> 호스트 키 검증에 실패한 경우로 해당 호스트의 SSH 키가 이전에 저장된 것과 일치하지 않을 때 나타난다. 보안상의 이유로 이전에 저장된 호스트 키와 변경된 키가 일치하지 않으면 연결을 거부하게 된다.
```bash
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

- **확인 사항:**
    - 호스트 키 변경 여부: 이전에 저장된 호스트 키와 현재 호스트 키가 일치하지 않는 경우, 호스트 키가 변경되었는지 확인
  
- **확인 방법:**
    - 호스트 키 확인: 클라이언트에서 `~/.ssh/known_hosts` 파일을 열어 해당 호스트의 키를 확인
    - 호스트 키 갱신: 호스트 키가 변경된 경우, `ssh-keygen -R <호스트 IP>` 명령어로 기존 키를 제거하고 다시 연결하여 새로운 키를 저장

---

**5.Connection to port 22: no matching key exchange method found**
> 키 교환 알고리즘으로 인한 에러가 발생하면 해당 에러 메시지를 찾아서 서버에서 허용하는 알고리즘으로 클라이언트를 업데이트 해야한다.

예시)
```bash

debug1: kex: algorithm: diffie-hellman-group14-sha1
debug1: kex: host key algorithm: rsa-sha2-256
debug1: kex: server->client cipher: aes128-ctr MAC: hmac-sha1 compression: none
debug1: kex: client->server cipher: aes128-ctr MAC: hmac-sha1 compression: none
debug3: send packet: type 30
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
ssh_dispatch_run_fatal: Connection to <hostname> port 22: no matching key exchange method found

```

- `debug1: kex: algorithm: diffie-hellman-group14-sha1`: 클라이언트에서 사용하려는 키 교환 알고리즘
- `debug1: kex: host key algorithm: rsa-sha2-256`: 서버에서 사용하려는 호스트 키 알고리즘
- `ssh_dispatch_run_fatal: Connection to <hostname> port 22: no matching key exchange method found`: 클라이언트와 서버 간에 호환되는 키 교환 알고리즘이 없어 연결이 실패

위와 같은 경우는 클라이언트 측에서 특정 알고리즘을 사용하는(예: sha1) 키페어를 사용했을 때 보안 및 알고리즘 업데이트 등으로 인해 서버 OS에서 해당 키를 이용한 접속을 거부하거나 할 때 발생할 수 있다.
클라이언트나 서버 측에서 사용 가능한 키 교환 알고리즘을 수정하거나, 서버 측에서 클라이언트에서 사용 중인 알고리즘을 허용하도록 설정을 변경해야 한다. 알고리즘 관련 설정은 서버의 `sshd_config` 파일에서 조정할 수 있다.
Ubuntu를 기준으로 `sshd_config` 에서 아래와 같은 설정이 있을 수 있다.

```
# Ciphers and keying
# RekeyLimit default none

# Algorithms supported for protocol version 2
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256,hmac-sha2-512,hmac-sha1
```

원하는 알고리즘을 추가하거나 기존 알고리즘을 수정한다. 주석 (#)을 제거하고 원하는 알고리즘을 추가하거나, 사용하지 않을 알고리즘을 주석 처리하여 비활성화한다.
sha1 의 경우 OS의 특정 릴리스부터 기본값으로 비허용 하고 있는 경우가 있으므로 확인이 필요하다.
