---
share: true
title: Linux CLI Cheat Sheet
date: 2024-01-31
tags:
  - Linux
  - Cheat-Sheet
categories:
  - OS
---



### Hard link, Soft link 생성 및 파일 메타데이터 정보 확인
---
- Create Hard link (하드 링크 생성)

```bash

$ ln <source file> <target file>

```

- Create Soft link (소프트 링크 생성)

```bash

$ ln -s <source file> <target file>

```

- File stat (metadata) (파일 메타데이터 조회)

```bash

$ stat <source file>

1. File: 파일의 이름을 표시합니다.
2. Size: 파일의 크기를 바이트 단위로 표시합니다.
3. Blocks: 파일이 사용하는 파일 시스템 블록 수를 나타냅니다.
4. IO Block: 파일 시스템에서의 블록 크기를 나타냅니다.
5. File type: 파일의 형식을 나타냅니다. 일반 파일, 디렉토리, 심볼릭 링크 등이 여기에 표시됩니다.
6. Device: 파일이 위치한 디바이스를 나타냅니다.
7. Inode: 파일의 Inode 번호(파일 고유 식별자)를 나타냅니다. 
8. Links: 파일을 참조하는 하드 링크의 수를 나타냅니다.
9. Access: 파일에 대한 마지막 액세스 시간을 나타냅니다.
10. Modify: 파일에 대한 마지막 수정 시간을 나타냅니다.
11. Change: 파일의 메타데이터가 마지막으로 변경된 시간을 나타냅니다.
12. Birth: 일부 파일 시스템에서 지원하는 경우 파일의 생성 시간을 나타냅니다.

```



### 특정 조건을 가진 파일만 따로 추출하여 옮기기 (one liner)
---
- extract files with permission - 예: 유저에게 실행 권한이 있는 파일만 따로 추출하여  /opt/executable 디렉토리로 복제

```bash

$ find /파일경로 -type f -perm -u=x -exec cp "{}" /대상경로 \;

```

- extract files with size - 예: 1M 이상 사이즈의 파일만 따로 추출하여 옮기기

```bash

$ find /파일경로 -type -f -size +1M -exec mv "{}" /대상경로 \;

```


### 특정 문자열을 가진 파일만 따로 추출하기(grep)
---
- filter files with string

```bash

$ grep -rl "찾으려는 문자열" <경로>

```


### 파일 내 특정 문자열을 교체하기(Search and replace: 간단한 버전)
---
- search and replace string

```bash

$ sed -i s/대상문자열/교체문자열/g <파일명>

```

### 파일 내 특정 조건에 맞는 문자열 찾기(grep: 간단한 버전)
---
- search pattern - 예) abc로 시작하는 문자열 /  abc로 끝나는 문자열 찾기

```bash

# 시작하는 문자열
$ grep "^abc" <파일명>
# 끝나는 문자열
$ grep "abc$" <파일명>

```


### TAR Archive (압축, 비압축, 추출)
---

- Create TAR Archive - 예) 압축되지 않은 단순 TAR Archive

```bash

$ tar -cvf /경로/파일명.tar <압축대상>

# -c create
# -v verbose
# -f file name

```

- Compress with .gz - 예) .gz 으로 압축

```bash

$ tar -czvf /경로/파일명.tar.gz <압축대상>

# -c create
# -z .gz format
# -v verbose
# -f file name

```

- Compress with bzip - 예) .bz2 로 압축

```bash

$ tar -cjvf /경로/파일명.tar.bz2 <압축대상>

# -c create
# -j .bz2 format
# -v verbose
# -f file name

```

- Compress with zip 예) .zip 으로 압축

```bash

$ zip -r /경로/파일.zip <압축대상>

```

- Extract - 추출(Extract)

```bash

$ tar -xvzf /경로/파일.tar.gz -C <추출경로>

# -x extract
# -v verpose
# -z .gz format
# -f file name

$ unzip /경로/파일.zip -d <추출경로>

# -d target directory

```


### 패키지 매니저: 인스톨 된 패키지 확인(Check installed packages)
---
- yum

```bash

$ yum list installed | grep httpd 

```

- apt

```bash

$ apt list --installed

```

- rpm

```bash

$ rpm -qa

```

- zypper

```bash

$ zypper se --installed-only

```

- dnf
```bash

$ dnf list installed | grep httpd

```


### 유저 생성(Create user)
---
- User creation 생성

```bash

$ sudo useradd smith

```

- Change default login shell 로그인 셸 변경

```bash

$ sudo useradd -s /bin/zsh smith

```

- Add user to wheel group 생성된 유저를 wheel그룹에 추가 (기존 유저 그룹은 유지)

```bash

$ sudo usermod -aG wheel smith # CentOS, RHEL
$ sudo adduser smith wheel # Ubuntu, Debian

```

- Delete user from wheel group 특정 유저를  wheel 그룹에서 제거

```bash

$ sudo gpasswd -d smith wheel # CentOS, RHEL
$ sudo deluser smith wheel # Ubuntu, Debian

```


### 유저 패스워드 활성화/비활성화(Active/Deactive user password)
---
- 활성화 (/etc/shadow의 해시된 패스워드가 있음) | 비활성화 (/etc/shadow의 해시된 패스워드 앞 !!가 있음)

```bash

$ sudo passwd -l smith # 패스워드 비활성화
$ sudo passwd -u smith 활성화

```


### 두 파일의 문자열 차이 / 두 디렉토리의 컨텐츠 차이 추출(comm, diff)
---
- 두 파일 간 문자열 차이 (A파일에는 있지만 B파일에는 없는 문자열)

```bash

$ comm -23 <(sort A.txt) <(sort B.txt) 

```

- 단순 비교 후 리디렉션(diff.txt로)

```bash

$ diff 파일1.txt 파일2.txt > diff.txt

```

- 두 디렉토리 간 컨텐츠 차이  (A디렉토리에만 있는 파일 목록 출력)

```bash

$ diff -rq A B | grep "Only in A:" | sed 's/Only in A: //'

```


### 네트워크 인터페이스 IP 주소 및 라우팅 테이블 확인(ifconfig, ip addr, hostname, route)
---
- IP 주소 확인

```bash

$ ifconfig
$ ip addr show
$ hostname -I #현재 호스트의 IP주소 확인

```

- 라우팅 테이블 확인

```bash

$ route -n
# -n No DNS resolution

$ ip route 
$ ip route list
$ ip route add
$ ip addr show

```

### 현재 열려있는 포트 및 해당 포트에서 수신 중인 서비스 나열(Listening services, Port)
---
> netstat
```bash

$ netstat -tuln

# -t tcp
# -u udp
# -l listening
# -n numeric

```

> ss(`ss` 명령어는 `netstat` 명령어와 유사하지만 더 빠르고 간결한 출력을 제공합니다)
```bash

$ ss -tuln

```

> lsof (열려 있는 파일 및 소켓에 대한 정보를 제공하므로, 여기에는 현재 수신 중인 포트 정보도 포함됩니다.)
```bash

$ lsof -i -P -n

```


### 파일 속성(Attribute) 조회, 추가, 제거
---
```bash

$ lsattr 파일
$ chattr -i 파일 # immutable 속성 제거
$ chattr +i 파일 # immutable 속성 추가

```


### 프로세스에 시그널 보내기(Sending signal to processes)
---
> 예) httpd 프로세스에  SIGHUP 전송 
```bash

$ sudo kill -HUP $(pidof httpd)

```
- 전송 결과는 각 프로세스 로그를 통해 확인 가능


### LVM (간단한 명령어)
---
```bash

# Physical Volume 생성
$ sudo pvcreate /dev/vdc /dev/vdd

# Volume group 생성
$ sudo vgcreate volume1 /dev/vdc /dev/vdd

# Logical Volume 생성(volume group에)
$ sudo lvcreate --size 1G --name logic1 volume1

```

### SWAP 파티션 추가 / SWAP 활성화
---
```bash

$ sudo mkswap /dev/vdb1
$ sudo swapon /dev/vdb1

```

### 파일 액세스 제어(ACL based)
---
> 예) file.txt 에 대한 유저 jane의 액세스 범위를 Read로만 제한
```bash

$ setfacl -m u:jane:r file.txt
# -m --modify
$ getfacl file.txt # 현재 FACL 조회

```


### 특정 유저의 Resource Limit 설정
---
> /etc/security/limits.conf 파일에서 유저, 타입, hard/soft, 값 직접 수정