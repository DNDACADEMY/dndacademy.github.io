---
layout: post
title: "Mac 터미널 세팅하기 (zsh & iterm)"
author: Gidong
categories: [설정]
tags: [develoment, vim, vimrc, zsh, iterm2, mac, environment]
image: assets/images/settings-mac-terminal/logo.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> 개발을 하면서, 가장 많이 사용하게 되는 요소 중 하나가 바로 터미널입니다.
> 오늘은, 맥북의 터미널을 아름답고 효율적으로 꾸며보도록 할 것입니다.

## 터미널 환경 구성

![/assets/images/settings-mac-terminal/1.png](/assets/images/settings-mac-terminal/1.png)

여러분들이 별도의 환경설정을 하지 않았다면, 위의 사진과 비슷한 모습일 겁니다.
하지만 이 글을 끝까지 따라한다면 아래와 같이 꾸밀 수 있을 것입니다.

![/assets/images/settings-mac-terminal/2.png](/assets/images/settings-mac-terminal/2.png)

## 1. zsh 및 oh-my-zsh 설치하기

- zsh 설치하기

```bash
# zsh 설치
brew install zsh

# 설치경로 확인
which zsh
#=> /usr/bin/zsh

# 기본 sh 변경
chsh -s $(which zsh)
```

- oh-my-zsh 설치

```bash
# git wget curl 설치 확인

# oh-my-zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

- zsh 확인

쉘 이름은 `echo $0` 환경변수로 확인할 수 있습니다.  
여러분의 터미널에 `zsh`가 출력되는지 확인해보자, 아래 그림처럼 `zsh`가 나오면 정상적으로 설치된 것입니다.

![/assets/images/settings-mac-terminal/3.png](/assets/images/settings-mac-terminal/3.png)

## 2. Powerlevel9k 테마 설치

zsh는 정상적으로 설치한 이후, 별도의 테마가 없다면 기존의 터미널과 별로 다를게 없을 것입니다.
그렇기 때문에, **Powerlevel9k** 과 같은 테마를 설치를 합니다

```bash
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/themes/powerlevel9k
```

다운받은 테마를 **.zshrc**파일에 적용해 주는 작업을 해야 합니다.  
아래 명령어처럼 .zshrc 파일을 엽니다.

```bash
vi ~/.zshrc
```

아래 그림처럼 ZSH_THEME 단락을 `powerlevel9k/powerlevel9k`로 바꿔줍니다. 아마 여러분의 .zshrc의 기본 ZSH_THEME는 `robbyrussell`로 잡혀있을 것입니다.

![/assets/images/settings-mac-terminal/4.png](/assets/images/settings-mac-terminal/4.png)

`.zshrc` 파일을 변경했다면, zsh 명령어를 통해 쉘을 다시 열어줘야 변경 사항이 확인이 가능합니다.

```bash
zsh
```

## 3. Iterm2 설치

설치는 https://www.iterm2.com/downloads.html 에서 진행할 수 있습니다.

iterm2를 열면 일부 박스가 깨져 제대로 보이지 않고 `?` 기호로 표시됩니다.  
글자가 깨지는 이유는 우리가 앞서 설치한 Powerlevel9k 테마는 일부 특수 문자를 사용하여 TUI (Text User Interface) 화면을 꾸미기 때문에, Powerlevel9k에서 권장하는 폰트를 사용해줘야 합니다.  
아래와 같은 절차를 따라하여 폰트를 설치해봅시다.

```bash
# Powerlevel9k 테마 폰트 리포지토리를 다운로드 받고 그 폴더로 이동.
git clone https://github.com/powerline/fonts.git /tmp/powerlevel9k-fonts && cd $_

# install.sh를 실행해 폰트를 설치
sh ./install.sh

# 다운로드 받았던 리포지토리 삭제
cd .. && rm -rf /tmp/powerlevel9k-fonts
```

폰트 설치가 끝났으면 iTerm 설정을 통해 터미널 기본 폰트를 변경해주어야 한다. iTerm 화면에서 **Command + ,(콤마)** 단축키를 이용해 설정 창을 열어준다. 그 다음 **Profiles > Text 탭**의 Font 섹션 아래에 있는 `Change Font` 버튼을 클릭(혹은 폰트에 대한 select가 보입니다.)해주자.

![/assets/images/settings-mac-terminal/5.png](/assets/images/settings-mac-terminal/5.png)

`Meslo LG M DZ for Powerline` 폰트가 보인다. 그 폰트를 선택하고 글자 크기를 여러분이 원하는 크기로 세팅하고 창을 닫아준다. (필자는 12pt가 적당하다고 생각하지만, 넓은 화면을 가진 사용자의 경우 13pt가 가장 적절하다.)

이제 여러분은 모든 텍스트가 깨짐없이 출력되는 것을 확인 할 수 있다.

## 4. iTerm color scheme 설정

테마가 적용된 아름다운 터미널 구성 세팅이 끝났습니다. 하지만, 컬러에 대한 부분을 아직 처리하지 못했습니다. 조금 더 아름다운 색체를 적용을 해보도록 합시다.
해당 글에서는 **Brogrammer**를 설치하는 방향으로 진행을 합니다. 하지만, 구글에 iterm color scheme이라 검색하여 여러분에 선호에 맞는 색상을 설치할 수 있습니다.

```bash
mkdir -p ~/.iterm && curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Brogrammer.itermcolors > ~/.iterm/Brogrammer.itermcolors
```

위 명령어를 입력하여 Brogrammer 컬러 스킴을 여러분의 홈 디렉토리 .iterm 폴더안에 다운로드 하였다. 다운로드가 끝났다면 iTerm 화면에서 Command + ,(콤마) 단축키로 설정 화면을 열고 Profiles > Colors 탭의 우측하단의 Color Presets 콤보박스를 열어 `Import` 옵션을 선택하자. 이해가 잘 안간다면 아래 그림을 보자.

![/assets/images/settings-mac-terminal/6.png](/assets/images/settings-mac-terminal/6.png)

탐색기에서 Command + Shift + g 단축키를 입력하여 경로 입력 창을 열고 `~/.iterm` 을 입력하여 ~/.iterm 폴더로 이동한 후 .iterm 폴더 내에 있는 Brogrammer.itermcolors파일을 선택해주자.

![/assets/images/settings-mac-terminal/7.png](/assets/images/settings-mac-terminal/7.png)

Brogrammer를 선택하고, 설정 화면을 닫아주자. 설정이 정상적으로 되었다면 아래와 같이 컬러가 변경된 터미널을 확인할 수 있다.

## 5. Powerlevel9k context 설정을 통한 간략화

Powerlevel9k 테마는 환경변수를 통해 사용자 입맛에 맞게 커스터마이징 하는 기능을 제공하고 있다. https://github.com/bhilburn/powerlevel9k#prompt-customization 링크를 확인해보자.

현재, 사용할 환경변수는 좌측과 우측 라인에 기본적으로 표시되는 Context를 수정할 수 있게 제공해준다. 필자는 다음과 같은 내용을 .zshrc에 추가하였다.

```bash
cat <<EOF >> ~/.zshrc
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status)
EOF
```

설정 파일을 변경하더라도 바로 적용이 안되고 zsh 쉘을 다시 실행해야 한다. zsh 명령어를 입력하여 zsh 쉘을 다시 실행하여 보자. 설정이 잘 완료 되었다면 아래와 같이 터미널이 조금 더 간략화된다.

![/assets/images/settings-mac-terminal/8.png](/assets/images/settings-mac-terminal/8.png)

## 6. logo-ls 설치하기

이제 터미널 셋팅의 최종장입니다.  
여러분들의 터미널(iterm2)에서 **ls** 명령어를 입력하였을 때, 아래와 같이 logo가 함께 나올 수 있도록 하는 작업입니다.

![/assets/images/settings-mac-terminal/9.png](/assets/images/settings-mac-terminal/9.png)

[공식 github 바로가기](https://github.com/Yash-Handa/logo-ls)

- Step 1. [Github Release Page](https://github.com/Yash-Handa/logo-ls/releases)에서 **logo-ls_Darwin_x86_64.tar.gz** 파일을 다운받으세요.

- Stem 2. **/usr/local/bin** 폴더로 설치한 logo-ls를 옮기세요.

```bash
cd logo-ls_Darwin_x86_64
sudo cp logo-ls /usr/local/bin
```

- Stem 3. If you want the man page of `logo-ls` place `logo-ls.1.gz` in `/usr/local/share/man/man1/`

```bash
sudo cp logo-ls.1.gz /usr/local/share/man/man1/
```

- zshrc 파일 내부에 아래와 같이 설정을 합니다.

```bash
alias ls='logo-ls'
alias la='logo-ls -A'
alias ll='logo-ls -al'
# equivalents with Git Status on by Default
alias lsg='logo-ls -D'
alias lag='logo-ls -AD'
alias llg='logo-ls -alD'
```

![/assets/images/settings-mac-terminal/10.png](/assets/images/settings-mac-terminal/10.png)

### logo-ls에 맞는 font 적용

**logo-ls**에 해당되지 않는 font의 경우 아이콘 대신 ?와 같은 표시가 나올겁니다.
이에 대해서 제대로 적용하기 위해서 `nerd font`가 필요합니다.  
우리는 그 중에서 `FiraMono Nerd Font`를 설치할 예정입니다.

```bash
brew tap homebrew/cask-fonts
brew install --cask font-fira-mono-nerd-font
```

설치를 완료한 후 iTerm 화면에서 **Command + ,(콤마)** 단축키를 이용해 설정 창을 열어준다. 그 다음 **Profiles > Text 탭**의 Font 섹션 아래에 있는 `Change Font` 버튼을 클릭(혹은 폰트에 대한 select가 보입니다.) 하여 **FiraMono Nerd Font**를 적용해줍니다.

![/assets/images/settings-mac-terminal/11.png](/assets/images/settings-mac-terminal/11.png)

## 마무리하며...

이렇게 Mac에서의 터미널 설정을 끝마쳤습니다.  
중간에 잘 되지 않는 부분이 있다면, 공식문서를 한번 확인해보시는 것도 좋습니다.  
아름다운 터미널 환경을 꿈꾸면서 이만 물러갑니다.
