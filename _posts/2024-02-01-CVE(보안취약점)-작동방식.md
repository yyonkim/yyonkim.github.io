---
share: true
title: CVE(보안 취약점) 작동방식 및 식별방법
date: 2024-02-02
categories: [Security]
tags: [CVE]
---


### Overview
---
CVE(Common Vulnerabilities and Exposures) 는 보안 취약점 및 노출 사항에 대한 표준 식별자를 의미한다.
컴퓨터 시스템 및 소프트웨어에서 발견된 보안 취약점에 대한 통합된 식별체계를 제공하며 [MITRE Corporation](https://cve.mitre.org/)의 CVE 편집위원회에 의해 관리된다.

CVE의 세부 정보는 아래와 같은 다양한 데이터베이스를 통해 공유되며, MITRE Corp가 [CVE 목록](https://cve.mitre.org/cve/)을 유지 관리하지만, CVE 항목이 되는 보안 결함은 오픈소스 커뮤니티에 속한 조직 및 구성원이 제출하는 경우가 많다. CVE는 어디에서든 보고할 수 있으며 오픈소스 소프트웨어에서 취약점이 발견될 경우 오픈소스 커뮤니티에 제출해야 한다.

- [미국 국가 취약점 데이터베이스(NVD)](https://nvd.nist.gov/)
- [CERT/CC 취약점 참고 데이터베이스](https://www.kb.cert.org/vuls/)
- 벤더 및 기타 조직에서 유지 관리되는 목록
	- 예: [Red Hat CVE 데이터베이스](https://access.redhat.com/security/security-updates/cve)
	- 예: [Canonical CVE Reports-Ubuntu 리눅스를 포함한 모든 Canonical Issue](https://ubuntu.com/security/cves)
- 오픈소스 커뮤니티
	- 예: OSVDB는 2016년 공식적으로 shut down 됐지만 블로그 및 개별 커뮤니티들은 이어지고 있다. 
	- https://vulndb.wordpress.com/
	- https://osv.dev/


### CVE 식별자 정보
---
CVE는 CVE 넘버링 기관(CNA: CVE-Numbering Authorities)에서 할당하며, MITRE 외에도 보안 기업 및 리서치 조직, Red Hat, IBM, Cisco, Oracle, Microsoft와 같은 주요 IT 벤더사에서 CVE를 직접 발행할 수 있다. 많은 벤더사들이 보안 문제 공개를 장려하기 위해 버그 현상금을 제공하고 있다. [CVE 넘버링 기관 목록](https://www.cve.org/ReportRequest/ReportRequestForNonCNAs)

CVE 식별자는 (CVE-YYYY-NNNN) 형식으로 되어있으며 해당 년도에 발행된 CVE 번호를 식별할 수 있는 체계가 갖춰져있다. CVE ID는 보안 권고 사항이 공개되기 전에 할당되는 경우가 많은데, 픽스를 개발하고 테스트할 때까지 벤더가 보안 결함을 비밀로 유지하여 공격자들이 패치 적용 전 악용할 기회를 최소화한다.


### 공통 취약점 등급 시스템(CVSS)
---
취약점의 심각도를 평가하는 방법은 여러 가지가 있으며 CVSS는 취약점의 심각도를 평가하기 위해 번호를 할당하는 오픈 표준이다. CVSS 점수는 NVD, CERT및 기타 조직에서 취약점의 영향을 평가하는 데 사용되며 0.0에서 10.0까지 주어진다. 숫자가 높을수록 취약점의 심각도가 더 높음을 나타내며, 많은 보안 벤더들 또한 자체적으로 등급 시스템을 갖추고 있다.


### 오픈소스에 대한 CVE 식별 및 픽스 여부 확인 방법
---
CVE는 특정 OS 배포판 버전, 특정 패키지, 특정 소프트웨어 및 라이브러리 등으로 영향을 받는 범위가 한정되어 있는 경우가 있으므로 다양한 방법을 통한 식별 및 패치 대상, Workaround를 확인하는 것이 중요하다.

1. 공식 웹사이트 공지사항 확인 
2. 버전별 릴리스노트 / GitHub 리포지토리 Commit 내역의 CVE 식별자 및 Apply Patch 여부 확인
- 예: [Open-Source Redis](https://github.com/redis/redis/releases) ---> Security Fixes
3. Open Source 커뮤니티 참조
4. 소프트웨어 자동 업데이트 기능 활용
5. 취약점 스캐닝 도구 사용을 통한 식별



References
- https://www.redhat.com/ko/topics/security/what-is-cve
- https://security.stackexchange.com/questions/222435/difference-between-cve-and-osvdb