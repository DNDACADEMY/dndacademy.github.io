---
layout: post
title: "git commitizen의 사용방법 및 template에 대해서 알아보기"
author: Gidong
categories: [Github]
tags: [commitizen, Project Management]
image: assets/images/github-commitzen-template/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> Github를 이용해서 Project를 수행하면서 우리는 수많은 commit을 하게 됩니다. 이때 일정한 스타일의 commit message를 작성하면, 해당 message만 확인을 하여도
> 전체적인 흐름을 이해할 수 있도록 도와줍니다. 오늘은 일정한 commit message를 작성하기 위해 사용할 수 있는 commitizen이라는 라이브러리와 git의 Template에 대해서
> 알아보는 시간을 가져보고자 합니다.

# 1. commitizen

## 설치방법

Commitizen은 현재 node 10 및 12에 대해서 사용이 가능합니다.  
아래의 명령어를 통해서 설치가 가능합니다.

```
npm install -g commitizen
```

```
npm install -g cz-conventional-changelog
```

```
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```

## 사용방법

아래의 명령어를 통해서 commitzen을 사용할 수 있다.

```
git cz
```

![/assets/images/github-commitzen-template/1.png](/assets/images/github-commitzen-template/1.png)

![/assets/images/github-commitzen-template/2.png](/assets/images/github-commitzen-template/2.png)

# 2. template
