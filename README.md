# DND 기술블로그

[![Website Stats](https://img.shields.io/website-up-down-green-red/http/monip.org.svg)](https://dndacademy.github.io) [![Feedback](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://dnd.channel.io/) ![Forks](https://img.shields.io/github/forks/DNDACADEMY/dndacademy.github.io.svg) ![Stars](https://img.shields.io/github/stars/DNDACADEMY/dndacademy.github.io.svg) ![Watchers](https://img.shields.io/github/watchers/DNDACADEMY/dndacademy.github.io.svg)

- Copyright &copy; 2019-2021, [https://dndacademy.github.io/](https://dndacademy.github.io/)
- Author: [Gidong Seong](https://sgd122.github.io/)
- Licensed under the terms of the MIT License.

## 게시글 작성방법

1. `_posts` 폴더에 `*.md` 형태의 파일을 작성
2. 아래의 문구 내용을 해당 md파일 최상위에 적용

```markdown
---
layout: post
title: "글제목"
author: 작성자이름
categories: [`카테고리`]
tags: [a, b, c]
image: assets/images/**/*.png
sitemap:
  changefreq: daily
  priority: 1.0
---
```

예시)

```markdown
---
layout: post
title: "git Large File Storage(LFS)"
author: Gidong
categories: [Github]
tags: [LFS, Large File, git]
image: assets/images/git-large-file-storage/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---
```

3. image를 첨부해야 할 경우 `assets/images` 폴더안에 게시글과 비슷한 이름의 폴더를 만들어서 사용.

예시)

```
게시글제목 : 2021-06-28-git-large-file-storage.md
이미지경로 : assets/images/git-large-file-storage/
```

4. 작성을 완료하면 Pull Requests 올려주시면 감사하겠습니다.

## Settings

```
** ruby 설치 **
gem install bundler
bundle install
bundle exec jekyll serve --watch
```
