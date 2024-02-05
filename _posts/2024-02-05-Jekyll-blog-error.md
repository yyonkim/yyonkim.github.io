---
share: true
author: yonkim #author id from _data/author.yaml
title: Jekyll 블로그 빌드 후 layout: home Index page 만 표시되는 경우
date: 2024-02-05
categories: [Other] # Linux, Other, Network, Security, Troubleshooting
tags: [blog, jekyll] # No Capital Letters
---

# Jekyll 블로그 빌드 후  layout: home Index page 만 표시되는 경우
> Jekyll 블로그 빌드 후 브라우저에서 페이지 로드 시 index.html 의 텍스트만 보이는 현상이 발생하는 경우가 있다.
```
--- layout: home # Index page ---
```


>문제가 발생된 환경 정보
```
$ bundle exec jekyll -v
jekyll 4.3.3

$ bundle info jekyll-theme-chirpy
  * jekyll-theme-chirpy (6.4.2)
        Summary: A minimal, responsive, and feature-rich Jekyll theme for technical writing.
        Homepage: https://github.com/cotes2020/jekyll-theme-chirpy
        Documentation: https://github.com/cotes2020/jekyll-theme-chirpy/#readme
        Source Code: https://github.com/cotes2020/jekyll-theme-chirpy
        Wiki: https://github.com/cotes2020/jekyll-theme-chirpy/wiki
        Bug Tracker: https://github.com/cotes2020/jekyll-theme-chirpy/issues
        Path: C:/Users/yonki/.local/share/gem/ruby/3.2.0/gems/jekyll-theme-chirpy-6.4.2

$ bundle -v
Bundler version 2.4.10

$ ruby -v
ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x64-mingw-ucrt]

$ gem -v
3.4.10
```

> 해결 방법: 원인은 여러가지일 수 있으며 ruby 버전, 로컬 머신 플랫폼, config, 페이지 빌드 방식에 따른 에러일 수 있다.

1. pages-deploy.yml 에 정의된 Ruby 버전 업데이트
	- 현재 사용중인 Ruby version과 .github/workflows/pages-deploy.yml 에 정의된 버전이 맞지 않을 수 있다
	- 예를 들어 Jekyll 테마를 fork했을 때 지정되어 있던 버전은 2.7인데 내가 번들로 설치한 루비 버전은 3.2인 경우
```
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true
```


2. Gemfile.lock 파일을 리포지토리에 커밋했고 로컬 머신이 Linux 가 아닐 경우 아래의 명령어를 통해 플랫폼 리스트를 업데이트 해준다.
```
$ bundle lock --add-platform x86_64-linux
```


3. 브랜치가 아닌 GitHub Actions 로 페이지를 빌드한다.
GitHub.io 프로젝트 리포지토리 -> Settings -> Pages -> Build and Deployement 의 Source를 Branch에서 GitHub Actions로 변경 -> 아무 커밋을 넣고 푸쉬한다.


4. `_config.yml` 파일의 base_url 부분은 "" 로 비어있어야 하고, url 부분의 깃허브 페이지 주소는 아래 형식을 따라야 한다.
```
 https://username.github.io
```


References:
- https://chirpy.cotes.page/posts/getting-started/#deploy-by-using-github-actions