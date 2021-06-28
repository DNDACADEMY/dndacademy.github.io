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

> Github를 이용해서 우리들은 많은 소스들을 손쉽게 관리할 수 있습니다. 하지만, 때로는 용량이 너무 큰 파일때문에 곤란한 경우가 생기기도 하는데요. git에서는 일반적으로 100MB 이상의 파일에 대해서 PUSH를 할 수가 없습니다. 오늘은 이 경우에 대해서 어떻게 대처를 할 것인가에 대해서 알아보도록 하겠습니다.

# 1. 100MB 이상의 큰 파일을 마주치다 📌

![/assets/images/git-large-file-storage/1.png](/assets/images/git-large-file-storage/1.png)
개발을 하면서 100MB를 초과하는 파일을 git에 올리게될 경우는 거의 없을 것이다.  
하지만 특별한 경우 위와 같은 일이 생기게 되는 경우가 있을 수 있다.  
혹은 git의 history상에 존재가 남아있어 이슈를 보게되는 경우도 발생할 수 있다.  
이럴때 사용할 수 있는 방법이 `Large File Storage(LFS)`를 설치해서 사용하는 것이다.

# 2. Large File Storage(LFS) 설치

우선, _git-lfs_ 설치를 진행해보자.  
macbook 사용자의 경우 아래와 같은 명령어로 간단하게 설치를 진행할 수 있다.

```CMD
Homebrew: brew install git-lfs
```

다른 OS를 이용할 경우 [git-lfs](https://git-lfs.github.com/)에서 다운로드 받을 수 있다.

> ### - Git LFS 설정
>
> ```CMD
> git lfs install
> ```
>
> Git LFS를 설치합니다.
>
> ```CMD
> git lfs track "*.zip"
> ```
>
> ![/assets/images/git-large-file-storage/2.png](/assets/images/git-large-file-storage/2.png)
>
> Git LFS를 사용하는 각 Git repository에서 Git LFS를 통해 (또는 .gitattributes 파일을 직접 설정) 파일형식을 선택합니다.  
> 추가 파일 확장명은 언제든지 구성 할 수 있습니다.
>
> ```CMD
> git add .gitattributes
> ```
>
> ![/assets/images/git-large-file-storage/3.png](/assets/images/git-large-file-storage/3.png)
>
> 이제 .gitattributes을 통해서 파일 추적이 이루어질 것입니다.

> ### 그럼에도 불구하고 에러가 발생하는 경우!
>
> ```CMD
> git filter-branch -f --index-filter 'git rm --cached --ignore-unmatch node_modules.zip'
> ```
>
> 해당 파일의 캐쉬 삭제후 git add를 진행합니다.
