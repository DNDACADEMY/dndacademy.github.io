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

commit 메시지의 prefix를 지정한다.

```
feat: 새로운 기능 추가
fix: 버그 수정
improvement: 호환성, 테스트 커버리지, 성능, 검증 기능, 접근성 등의 향상
docs: 문서수정
style: 코드 포맷팅, 세미콜론 누락 등
refactor: 기존 코드에 대한 리펙토링을 진행
```

![/assets/images/github-commitzen-template/2.png](/assets/images/github-commitzen-template/2.png)

커밋에 대한 Title, Description등을 입력한다.
이 과정에서 이슈에 대한 연결도 지정하여 git push를 진행한다.

# 2. Pull Request Template / Issue Template

Github를 이용하게 될 경우 PR(Pull Request), Issue 등록 등을 통해서 프로젝트를 진행한다.  
이 과정에서 어떤 작업에 대한 내용인지, 어떠한 이슈인지를 조금 더 명확하게 알 수 있게 하기위해 구체적인 PR/Issue 등록을 해주는 것이 중요하다.  
하지만, 작업하는 사람마다 작성하는 양식이 다르다보니, 이해하기 어려운 경우가 종종 발생할 수 있다.  
이러한 과정을 해결하기 위해 프로젝트를 진행할때 Template을 등록해서 사용하는 경우가 많다.  
아래는 Template 등록에 대한 과정설명이다.

1. 프로젝트의 `.github`폴더에 아래의 파일 생성

- PULL_REQUEST_TEMPLATE.md
- ISSUE_TEMPLATE.md

2. PULL_REQUEST_TEMPLATE.md 에 아래와 같은 기본적인 내용을 작성할 수 있다.

```MD
## 🧑‍💻 PR 내용

수정/추가한 내용을 적어주세요.

## 📸 스크린샷

스크린샷을 첨부해주세요.

```

3. ISSUE_TEMPLATE.md 에 아래와 같은 기본적인 내용을 작성할 수 있다.

```MD
## 🤷 이슈 내용

무슨 이슈인가요?

## ✨ 기대 결과

어떤 결과물을 원하시나요?

## 📸 스크린샷

이슈에 해당하는 부분을 보여주세요.

```

최종적으로 아래와 같은 사진의 형태가 일관되게 나오는것을 알 수 있다.

![/assets/images/github-commitzen-template/3.png](/assets/images/github-commitzen-template/3.png)
