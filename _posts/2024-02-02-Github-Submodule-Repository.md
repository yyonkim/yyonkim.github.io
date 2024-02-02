---
share: true
title: Github Submodule Repository
date: 2024-02-02
categories:
  - Other
tags:
  - git
  - blog
---


### Github Repository를 서브모듈로 연결하기
---

준비물: 
- 서브모듈로 연결할 repository 주소
- 메인 Repository

> 예) jekyll 블로그(username.github.io) repository의 `_posts` 디렉토리에 .md 파일을 보관중인 repository를 서브모듈로 연결: [1]

- 연결할 디렉토리(예: `_posts`) 백업 후 남아있는 캐시를 날려준다.

```bash
$ git ls-files --stage _posts
100644 8b137891791fe96927ad78e64b0aad7bded08bdc 0       _posts/.placeholder
100644 45084cb9d4bf97844bbb6d092deac273e0833687 0       _posts/2024-02-02.md
100644 89a90b55bc61d2d2f3ba7ec166d232b83abd2c76 0       _posts/2024-02-03.md
100644 bb141ab47b5cc6e02b4269edc4e6ca0decca65bc 0       _posts/test.md

$ git rm -r --cached _posts
rm '_posts/.placeholder'
rm '_posts/2024-02-02.md'
rm '_posts/2024-02-03.md'
rm '_posts/test.md'
```

-   `_posts` 디렉토리 하위 파일 제거: [2]

```bash
$ git rm _posts/*
$ rm _posts/*
```

- submodule 추가 후 .gitmodules에 경로 추가 되었는지 확인

```bash
$ git submodule add https://github.com/yyonkim/study-logs.git _posts/
$ cat .gitmodules

[submodule "_posts"]
        path = _posts
        url = https://github.com/yyonkim/study-logs <--- 잘 추가되었음
        
$ git add _posts/
$ git add .gitmodules
$ git commit -m "feat: add study-logs repository as post"
```


- 추후 study-logs에 새 업데이트가 생기면 서브모듈 업데이트를 통해 반영한다. (현재 study-logs는 obsidian과 연동되어 있음)

```bash
$ git submodule update --remote
```


### 서브모듈 제거
---
1. .gitmodules 파일에서 경로 제거
2. git rm --cached [submodule 경로 (예: `_posts`)]
3. rm -rf .git/modules/{submodule}
4. rm -rf 


References:
- [1] https://minyeamer.github.io/blog/hugo-blog-1/#%EC%A0%80%EC%9E%A5%EC%86%8C-%EC%97%B0%EB%8F%99
- [2] https://djoepramono.github.io/git-filter-branch/
- [3] https://blog.naver.com/jegumhon/220537092950
- [4] https://snowdeer.github.io/git/2018/08/01/how-to-remove-git-submodule

