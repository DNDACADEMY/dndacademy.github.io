---
layout: post
title: "Docker 설치하기"
author: Gidong
categories: [Docker]
tags: [Docker Compose, Setup]
image: assets/images/setup-docker/docker-compose-main.jpg
sitemap:
  changefreq: daily
  priority: 1.0
---

> 도커Docker는 2013년에 등장한 컨테이너 기반 가상화 도구입니다.  
> 이 글은 도커 입문자를 위한 튜토리얼로서, 도커의 설치 방법에 대해서 기술해 놓았습니다.

## WSL v2 설치하기

### 1. 윈도우 버전 확인

윈도우10 Home/Pro/Education 모두에서 “버전 2004” 업데이트가 적용이 된 경우에 WSL v2를 사용하실 수 있습니다.  
“버전 2004”는 우분투 리눅스의 버전 네이밍을 유사하며 20년 04월 업데이트를 뜻합니다. 아래와 같은 Windows 정보는 윈도우 실행창에서 winver 를 실행하시면 확인하실 수 있습니다.  
이전 버전이시라면 필히 최신 윈도우 버전으로 업데이트해주세요. WSL v2를 지원하는 정확한 버전은 “윈도우 10 빌드 18197” 이상입니다.

![/assets/images/setup-docker/10.png](/assets/images/setup-docker/10.png)

윈도우 버전은 명령 프롬프트에서 ver 명령으로도 확인 가능합니다.

![/assets/images/setup-docker/11.png](/assets/images/setup-docker/11.png)

### 2. “가상 머신 플랫폼” 옵션 구성 요소 사용

Linux용 Windows 하위 시스템 및 Virtual Machine 플랫폼 구성 요소가 모두 설치되어 있는 지 확인해야 합니다.  
관리자 권한으로 Powershell을 구동시켜 아래 명령을 실행하여 확인하실 수 있습니다.

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

두 구성요소 설치를 완료하려면 머신을 재부팅해주세요.  
그리고 “Linux용 Windows 하위 시스템” 기능을 사용토록 설정해야합니다. 관리자 권한으로 Powershell에서 아래 명령을 입력해주세요.

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

메시지가 표시되면 재부팅해주세요.

### 3. Linux용 Windows 하위 시스템 설치

![/assets/images/setup-docker/12.png](/assets/images/setup-docker/12.png)

리눅스 배포판을 설치하는 데에 다음 2가지 옵션을 지원합니다.

1. Microsoft Store에서 다운로드 및 설치 : 가장 손쉬운 방법입니다. Microsoft Store 애플리케이션을 구동하고, Ubuntu Linux 20.04 LTS 버전을 검색하여 다운받아주세요.

   20.04는 20년 4월에 릴리즈된 버전이라는 의미이며, 이후에 출시된 최신 버전이 있다면 최신버전을 설치해주세요.

2. 이미지를 다운로드받고 Add-AppxPackage 명령으로 설치 : 윈도우 버전, 회사 네트워크 정책 등의 이유로 Microsoft Store를 사용하지 못할 경우 직접 다운로드하여 설치할 수 있습니다.

다음 주소에서 Ubuntu Linux WSL 이미지를 다운받으실 수 있습니다.

1. https://aka.ms/wsl-ubuntu-1804 : 18.04 버전

2. https://aka.ms/wsl-ubuntu-2004 : 20.04버전 (2020년 5월 현재 아직 링크가 제공되고 있지 않습니다만, 조만간 제공될 것입니다.)

위 주소를 브라우저에 직접 입력하여 다운받으실 수도 있고, 다음과 같이 파워쉘을 통해 다운받으실 수도 있습니다. 아래 명령에서는 18.04 버전을 지정했지만, 20.04버전이 가용할 경우 20.04버전으로 변경해주세요.

```bash
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu-1804.appx -UseBasicParsing
```

이제 관리자 권한으로 실행한 파워쉘에서 다음 명령으로 설치하실 수 있습니다. 팩키지 파일 경로를 잘 확인해주세요.

```bash
Add-AppxPackage .\Ubuntu-1804.appx
```

### 4. 설치된 리눅스 배포판 초기화

윈도우 시작 버튼을 눌러 설치한 리눅스 배포판 이름을 검색하여, 앱을 실행해주세요. 아래 스크린샷은 Ubuntu 20.04 버전을 설치했을 경우입니다.

![/assets/images/setup-docker/13.png](/assets/images/setup-docker/13.png)

새로 설치한 리눅스 배포판이 처음 실행되면 콘솔창이 열리고 설치가 완료될 때까지 1~2분 기다리라는 메시지가 표시됩니다. 이 설치의 마지막 단계에서 배포판의 파일을 압축을 풀고 PC에 저장하여 사용할 준비를 합니다. PC 스토리지 성능에 따라 약 1분 이상이 소요될 수 있습니다. 이 단계는 배포판을 새로 설치할 때에만 수행되며, 이후의 모든 시작에는 1초 미만의 시간으로 빠르게 구동됩니다.

![/assets/images/setup-docker/14.png](/assets/images/setup-docker/14.png)

설치가 끝나면 새 사용자 계정 및 암호를 만들라는 메시지가 표시됩니다. 이 사용자 계정은 윈도우 사용자 이름과는 관련이 없습니다. 원하는 사용자 이름과 암호를 입력하시면 됩니다. WSL 리눅스 쉘을 열 때에는 암호 입력을 요구하지 않지만, sudo를 사용할 경우 암호를 입력해야합니다.

![/assets/images/setup-docker/15.png](/assets/images/setup-docker/15.png)

### 5. 배포판 팩키지 업데이트 및 업그레이드

대부분의 배포판은 비어있거나 최소한의 팩키지 카탈로그가 제공됩니다. 배포판의 기본 설정 팩키지 관리자를 사용하여 정기적으로 팩키지 카탈로그를 업데이트하고 설치된 팩키지를 업그레이드하는 것이 좋습니다. Debian/Ubuntu 에서는 apt를 사용합니다. 그리고, 윈도우에서는 Linux 배포판을 자동으로 업데이트하거나 업그레이드하지 않으니, 정기적으로 수동 업그레이드를 해주셔야 합니다.

```bash
sudo apt update && sudo apt upgrade -y
```

WSL에 대해서 보다 깊게 살펴보고 싶으시다면, https://devblogs.microsoft.com/commandline/learn-about-windows-console-and-windows-subsystem-for-linux-wsl/ 문서를 참고해보세요.

### 6. WSL에 버전2 디폴트 설정

wsl -l -v 명령으로 설치한 배포판에 대한 WSL 버전을 확인하실 수 있습니다. 설치하신 배포판 버전에 맞게 버전을 확인해주세요.

![/assets/images/setup-docker/16.png](/assets/images/setup-docker/16.png)

위와 같이 버전1로 확인이 된다면, “wsl --set-version <배포판이름> 2” 명령으로 WSL 버전2로 올리실 수 있습니다. 반대로 버전2를 버전1으로 내리는 것도 가능합니다.

![/assets/images/setup-docker/17.png](/assets/images/setup-docker/17.png)

### 7. WSL 디폴트 배포판 설정하기

“wsl --set-default <배포판이름>” 명령으로 wsl 디폴트 배포판을 설정하실 수 있습니다.

![/assets/images/setup-docker/18.png](/assets/images/setup-docker/18.png)

디폴트 배포판을 설정 하신 후에 wsl 명령으로 배포판을 구동하신 후에, 우분투 리눅스 기준으로 “lsb_release -a” 명령으로 우분투 리눅스 배포판 버전을 확인하실 수 있습니다.

---

## Hyper-V, WSL v2 사용이 어려운 경우

다음 2가지 경우가 있을 수 있습니다.

1. 윈도우 10 Home이전 버전을 쓰시면서 윈도우 최신 업데이트를 하지 못하시는 경우

2. 윈도우 10 Pro/Education 이상이지만, 윈도우 환경 상의 이유로 Hyper-V 구동이 원활하지 않거나 , 최신 윈도우 업데이트가 불가능한 경우

이럴 경우, 어쩔 수 없이 VirtualBox (Oracle의 가상화 프로그램)과 함께 Docker Toolbox on Windows 프로그램을 사용할 수 밖에 없습니다. 이 환경은 비추천환경이니 WSL v2를 사용하는 쪽으로 환경개선을 하시는 것을 적극 추천드립니다.

### Docker Toolbox를 사용하는 경우 (비추천!)

- 첨부된 링크에서 Docker ToolBox를 설치. [https://github.com/docker/toolbox/releases](https://github.com/docker/toolbox/releases)

(기본적인 개발 환경을 위해서 옵션을 모두 체크하시고 설치하시면 편합니다.)

- DockerToolBox를 설치하면서 VirtualBox를 설치하여 옵션을 체크하여 VirtualBox 설치

(DockerToolBox를 설치하면서 따로 체크 옵션을 건든 부분이 없다면 VirtualBox도 설치 되셨을겁니다.)

- VirtualBox에서 사용할 포트를 포트포워딩합니다. (default 이미지를 클릭하시고 상단의 설정을 클릭하여 진입이 가능합니다.)

![/assets/images/setup-docker/01.png](/assets/images/setup-docker/01.png)

![/assets/images/setup-docker/02.png](/assets/images/setup-docker/02.png)

- VirtualBox에서 머신폴더를 마운트합니다.

![/assets/images/setup-docker/03.png](/assets/images/setup-docker/03.png)

![/assets/images/setup-docker/04.png](/assets/images/setup-docker/04.png)

---

## WSL v2 사용이 어렵지만, Hyper-V는 가능한 경우

윈도우10 Pro/Education 버전을 쓰고 계시지만, 윈도우 최신 업데이트가 불가능한 경우입니다.

먼저 가상화(Virtualization) 옵션이 켜져있는 지 확인해주세요. 작업관리자 (단축키: Ctrl+Shift+ESC)의 성능 탭에서 확인하실 수 있습니다.

![/assets/images/setup-docker/19.png](/assets/images/setup-docker/19.png)

가상화 옵션이 꺼져있고, 가상화를 지원하는 컴퓨터라면 바이오스 설정에서 가상화 옵션을 켜주세요. 윈도우 바이오스 설정에서 Virtualization Technology (VT)를 활성화하시면 됩니다.
이제 Hyper-V를 설치합니다. 관리자 권한의 파워쉘에서 다음 명령을 통해 설치하실 수 있습니다.

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### Docker를 직접 설치하는 경우

- 첨부된 링크에서 [https://docs.docker.com/install/](https://docs.docker.com/docker-for-windows/install/)
- Window Bios에서 Virtualization Technology(VT)를 활성화 해주세요.(VT를 사용하지 못하면 Hiper-V를 사용하지 못하기 때문에 다른 경우의 방법으로 설치하셔야 합니다.)
- 제어판 - 프로그램 및 기능 - Windows 기능 켜기/끄기 - Hyper-V 체크

![/assets/images/setup-docker/05.png](/assets/images/setup-docker/05.png)

![/assets/images/setup-docker/06.png](/assets/images/setup-docker/06.png)

- 재부팅해줍니다.
- 아래와 같이 고래모양의 Docker가 실행됩니다. Docker는 원래 리눅스 기반에서 만들어진 기술이기때문에 윈도우 컨테이너에서는 Docker 사용이 불가능하니 반드시 **Switch to Linux containers**를 클릭해 리눅스 컨테이너로 스위칭 해주셔야 합니다.
  제대로 설치가 완료되고, 셋팅이 완료된다면 윈도우 Command, Powershell에서 Docker 명령어의 사용이 가능해집니다.

![/assets/images/setup-docker/07.png](/assets/images/setup-docker/07.png)

![/assets/images/setup-docker/08.png](/assets/images/setup-docker/08.png)

---

## WSL v2 사용이 가능한 경우 (최적)

WSL v2를 설치하시고 WSL 리눅스 배포판을 설치하셨다면, Docker Desktop 옵션에서 “Enable the experimental WSL 2 based engine” 옵션을 켜주세요. 기존에 Hyper-V를 사용하고 계셨다면, Hyper-V에 생성된 VM은 자동 제거되고, WSL에 docker-desktop 배포판과 docker-desktop-data 배포판이 자동으로 추가됩니다. 이때 외부 네트워크 접속이 필요할 수 있습니다.

![/assets/images/setup-docker/20.png](/assets/images/setup-docker/20.png)

다음과 같이 docker-desktop 배포판을 확인하실 수 있습니다.

![/assets/images/setup-docker/21.png](/assets/images/setup-docker/21.png)

---

## Linux에서 Install

도커는 리눅스 기반의 기술이기에 리눅스에서는 1줄 명령으로 손쉽게 설치하실 수 있습니다.

```bash
Bash> curl -fsSL https://get.docker.com/ | sudo sh
```

---

## Docker 그룹 권한

리눅스에서는 docker 명령 사용을 위해 docker 그룹이 필요합니다. 그래서 보통 sudo를 붙여 root 권한으로 실행을 하게 되는 데요. 다음 명령으로 현재 유저를 docker 그룹에 추가하실 수 있습니다.
Bash> sudo usermod -aG docker $USER
$USER는 현재 접속 계정의 username을 담고 있는 환경변수입니다. 대신에 직접 아이디를 지정하셔도 됩니다.

```bash
sudo usermod -aG docker $USER # 현재 접속중인 사용자에게 권한주기
```

---

## Docker Test

```docker
docker run --rm -it -p 8000:80 nginx # nginx 도커이미지에 대한 컨테이너를 실행해라.
# --rm : 컨테이너의 실행을 중단하면 컨테이너를 삭제
# -i, -t : 실행된 Bash Shell에 입력 및 출력이 가능
# -p 8000:80 : 컨테이너 외부에서 들어오는 8000번 포트를 80으로 보내라.
```

![/assets/images/setup-docker/09.png](/assets/images/setup-docker/09.png)

---

## Docker Hub

Docker에서 사용 가능한 이미지를 다운로드 또는 업로드할 수 있는 이미지 저장소입니다.
이미지를 업로드하려면 계정이 필요하니 [도커허브](https://www.notion.so/hurara/04-Docker-hub-72d5f6bf267c489a9a97745b44411cc8#4d8636e9b14946179a92c387ff7f804e)에서 계정을 생성해야 합니다.

### 로그인

아래의 명령을 통해 현재 설치된 Docker 머신에서 Docker Hub에 로그인 할 수 있습니다.

```bash
docker login
```

또는

```bash
docker login --username 계정 --password 비밀번호
```

### 이미지 다운로드

```bash
docker pull nginx
```

### 이미지 업로드

```bash
# docker push 도커허브계정/이미지명:태그
docker push testuser/test-image:1.0
```
