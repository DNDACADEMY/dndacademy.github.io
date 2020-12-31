---
layout: post
title: "vscode-extension cli에서 설치"
author: Gidong
categories: [vscode]
tags: [Visual Studio Code, extensions]
image: assets/images/vscode-extensions/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

# 1. CLI 환경 구성

- 해당 URL을 통해서 CLI 환경부터 구성을 하도록 하자.
- [CLI 환경 구성](https://code.visualstudio.com/docs/setup/mac)

## 2. cli환경에서의 기본적인 설치방법

위 extension 을 설치한다고 했을 때 아래와 같이 명령어를 입력할 수 있다.

```bash
code --install-extension ms-vscode.azurecli
```

## 3. 실제 활용방법

일단 vscode-extension.txt 에는 아래와 같은 내용이 들어있다고 가정하자

```txt
ms-vscode.azurecli
formulahendry.auto-close-tag
naumovs.color-highlight
Name: Color Highlight
```

**xargs**  
표준 출력의 내용을 다음 명령어의 인자로 전달한다.  
여러가지 옵션이 있지만 여기서는 L(line) 옵션을 사용했다.  
출력 내용이 여러줄이면 1줄씩 인자로 전달하겠다는 내용이다.

```bash
cat vscode-extensions.txt | xargs -L1 code --install-extension

# 실제 실행될때
code --install-extension ms-vscode.azurecli;
code --install-extension formulahendry.auto-close-tag;
# .... 생략
```

### 4. extension.txt 만들기

현재 내가 설치하고 있는 extension id를 일일히 찾아서 기입하는 일은 번거롭다. 깔려있는 모든 extension id는 어떻게 추출할 수 있을까? 필자의 경우 아래 명령어를 통해 vscode 폴더를 찾았다.

.vscode/extensions 폴더 찾기

```bash
find ~ -name ".vscode" -type d | grep -i seong-gidong/.vscode

# 출력 결과
/Users/godot/.vscode
/Users/godot/.vscode/extensions/steoates.autoimport-1.5.3/.vscode
/Users/godot/.vscode/extensions/ritwickdey.liveserver-5.6.1/node_modules/bcryptjs/.vscode
/Users/godot/.vscode/extensions/tht13.python-0.2.3/.vscode
/Users/godot/.vscode/extensions/tht13.python-0.2.3/src/server/.vscode
/Users/godot/.vscode/extensions/msjsdiag.debugger-for-chrome-4.12.3/node_modules/vscode-uri/.vscode
/Users/godot/.vscode/extensions/ms-vscode.vscode-typescript-tslint-plugin-1.2.3/node_modules/vscode-uri/.vscode
```

.vsocde 내부에 extensions 폴더에 현재 깔려있는 extension 폴더들이 존재한다. 때문에 그 폴더로 이동했다.

> .vscode/extensions 폴더로 이동하기

```bash
cd /Users/seong-gidong/.vscode/extensions
```

> 깔려있는 extension 확인하기

```bash
ls -l
# 출력 결과
drwxr-xr-x  10 seong-gidong  staff   320  7 29 09:42 aaron-bond.better-comments-2.1.0
drwxr-xr-x  10 seong-gidong  staff   320  4 14  2020 abusaidm.html-snippets-0.2.1
drwxr-xr-x  12 seong-gidong  staff   384 12  4 10:40 alexcvzz.vscode-sqlite-0.10.1
drwxr-xr-x  16 seong-gidong  staff   512 12 12 09:49 batisteo.vscode-django-1.0.1
```

> 출력결과 저장

아래 명령어를 통해 extension.txt를 만들 수 있다. 해당 extensions 폴더에서 필요한 네이밍만 추출하면 extensions.txt 가 완성된다.

(리눅스 명령어를 통해 불필요한 정보를 제외하고 필요한 네이밍 ex) **steoates.autoimport** 만 추출이 가능할 것이다. 다만 현재의 필자는 에디터를 통해 불필요한 권한, 유저정보, 시간 등의 데이터를 삭제하기로 했다. )

```bash
ls -l > extensions.txt
```
