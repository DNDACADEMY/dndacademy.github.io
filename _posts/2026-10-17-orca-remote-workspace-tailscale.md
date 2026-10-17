---
layout: post
title: "Orca 사용법: AI 코딩 작업을 집 밖에서도 이어가기 (feat. Tailscale 원격 제어)"
author: Gidong
categories: [설정]
tags: [orca, terminal, ai, claude-code, codex, worktree, remote, ssh, tailscale, workflow]
image: assets/images/orca-remote-workspace/orca-remote-map.png
sitemap:
  changefreq: weekly
  priority: 0.8
---

> 지난 글에서는 [Herdr로 AI 에이전트 터미널을 관리하는 방법](/herdr-terminal-workspace-for-ai-agents/)을 다뤘습니다.
> 이번에는 **Orca에서 작업을 나누고, Tailscale로 원격 컴퓨터에 연결해 그 작업을 계속 통제하는 방법**을 정리합니다.
> 집 컴퓨터에서 에이전트에게 작업을 맡기고, 밖에서는 노트북이나 휴대폰으로 진행 상황을 확인하는 구성을 만들어 봅니다.

이 글에서는 **집에 두고 작업을 실행할 컴퓨터를 ‘서버’**, **밖에서 접속할 노트북을 ‘클라이언트’**라고 부릅니다. 서버라고 해서 별도의 장비를 살 필요는 없습니다. 켜 두고 사용할 Mac이나 PC면 시작할 수 있습니다.

처음 연결한다면 **1~4절**을 순서대로 읽으세요. Orca 설치부터 Tailscale 연결, 원격 작업 확인까지 이어집니다. 휴대폰·CLI·SSH·창 없는 서버 설정은 필요한 경우에만 읽는 선택 과정입니다.

*2026-10-17 기준 공식 문서와 Orca 1.4.224 CLI를 대조했습니다. 구조도 3장과 실제 설정 화면을 함께 사용했습니다.*

## 목차

- [Orca로 무엇을 할 수 있나](#orca로-무엇을-할-수-있나)
- [1. 양쪽 컴퓨터에 Orca 준비하기](#1-양쪽-컴퓨터에-orca-준비하기)
- [2. Tailscale로 두 기기 연결하기](#2-tailscale로-두-기기-연결하기)
- [3. 집 컴퓨터를 원격 Orca 서버로 공유하기](#3-집-컴퓨터를-원격-orca-서버로-공유하기)
- [4. 연결한 서버에서 첫 작업 확인하기](#4-연결한-서버에서-첫-작업-확인하기)
- [선택: 휴대폰으로 작업 확인하기](#선택-휴대폰으로-작업-확인하기)
- [선택: CLI로 원격 Orca 통제하기](#선택-cli로-원격-orca-통제하기)
- [선택: SSH 방식으로 연결하기](#선택-ssh-방식으로-연결하기)
- [선택: 창 없는 서버에서 실행하기](#선택-창-없는-서버에서-실행하기)
- [문제 해결과 운영 기준](#문제-해결과-운영-기준)
- [공식 참고 자료](#공식-참고-자료)

## Orca로 무엇을 할 수 있나

Herdr 글의 중심이 **터미널 패널과 에이전트 상태 관리**였다면, Orca에서는 **작업별 코드 사본과 리뷰 환경**까지 한곳에 묶는 흐름을 살펴볼 수 있습니다.

이 글의 [Orca](https://www.onorca.dev/docs)는 Claude Code, Codex 같은 코딩 에이전트를 실행하고 결과를 검토하는 데스크톱 개발 도구입니다. 평소 쓰는 에이전트 계정과 컴퓨터를 연결해 사용합니다. [공식 소개](https://www.onorca.dev/docs)

중심 개념은 **Git worktree(작업별 코드 폴더)**입니다. 하나의 저장소에서 서로 다른 브랜치를 별도 폴더로 열어, 각 작업에 파일과 터미널을 붙입니다. [Worktrees 문서](https://www.onorca.dev/docs/model/worktrees)

| 단위 | 예시 | 실전에서의 의미 |
| --- | --- | --- |
| 프로젝트 / 저장소 | `my-app` | 여러 작업의 출발점 |
| Worktree | `fix-login`, `add-search` | 작업별 브랜치와 코드 디렉터리 |
| 탭 / 패널 | 에이전트, 파일, 변경 내역 | 해당 작업을 실행·확인하는 화면 |
| 실행 호스트 | 내 Mac, 집 서버 | 실제 파일과 프로세스가 있는 기기 |

예를 들어 로그인 수정과 검색 기능을 서로 다른 작업 폴더에서 진행하면 각자 다른 파일 사본을 수정합니다. 다만 **포트·DB·외부 서비스까지 자동 격리되는 것은 아닙니다.** 개발 서버 두 개를 모두 `3000`번 포트로 실행하면 충돌합니다. 새 worktree의 `.env`나 의존성 설치 여부도 확인해야 합니다. 공식 문서도 Git에서 제외한 파일이 새 작업 폴더에 없을 수 있다고 설명합니다. [공유 경로와 로컬 파일](https://www.onorca.dev/docs/model/worktrees#shared-directories--gitignored-files)

리뷰는 내장 diff 뷰어(변경 내역 보기)에서 이어갑니다. 작업별 변경을 확인할 수 있다는 점이 터미널을 여러 개 띄우는 것과 다른 효용입니다. [Diff viewer](https://www.onorca.dev/docs/review/diff-viewer)

작업에는 내장 브라우저도 붙일 수 있습니다. 웹 UI를 수정한다면 에이전트와 미리보기 사이를 오가는 데 도움이 됩니다. [Per-worktree browser](https://www.onorca.dev/docs/browser/overview)

### 어디에 유용할까

예를 들어 다음 상황에서 활용할 수 있습니다.

| 상황 | 기대할 수 있는 효용 | 함께 고려할 비용 |
| --- | --- | --- |
| 집 Mac mini에서 빌드, 밖에서 노트북 사용 | 실행 위치를 유지하며 지시·검토 | 상시 가동과 서버 인증 관리 |
| Linux 서버에서 무거운 테스트 | 노트북 자원 사용을 줄임 | 원격 환경 준비와 연결 지연 |
| 여러 독립 작업 병행 | worktree마다 변경을 나눠 리뷰 | 의존성·DB·포트 격리 설계 |
| 이동 중 에이전트 질문 확인 | 폰으로 대기 중인 흐름을 이어감 | 작은 화면에서의 검토 한계 |

에이전트 하나로 짧은 작업만 한다면 추가 런타임과 원격 연결의 관리 부담이 더 클 수 있습니다. 먼저 로컬에서 한 작업을 끝내 보고, 원격 실행이 실제로 필요한 작업부터 옮기는 순서를 제안합니다.

## 1. 양쪽 컴퓨터에 Orca 준비하기

먼저 **서버와 노트북 양쪽에 Orca를 설치**합니다. 서버에는 Git과 사용할 에이전트도 설치하고 로그인해 둡니다. 노트북에서 한 로그인이 서버로 자동 전달되지는 않습니다. [서버 준비 사항](https://www.onorca.dev/docs/remote-servers#what-runs-where)

[공식 설치 페이지](https://www.onorca.dev/docs/install)에서 운영체제와 CPU에 맞는 배포본을 받습니다. macOS는 공식 Homebrew cask도 있습니다.

```bash
brew install --cask stablyai/orca/orca
```

원격 연결 전에 **서버에서** 작은 작업 하나가 실행되는지 확인합니다.

1. **저장소 추가(Add Repo)**로 기존 저장소를 추가합니다.
2. 저장소 옆 **+**에서 새 worktree를 만듭니다.
3. 작업 이름과 시작 브랜치 또는 커밋을 확인합니다. 기본 브랜치에서 시작할지, 기존 작업 위에 쌓을지 구분합니다.
4. Claude Code나 Codex 등 사용할 에이전트를 선택합니다.
5. 요구사항과 검증 방법을 전달하고, 변경 내역과 테스트 출력을 확인합니다.

이 흐름은 공식 [첫 세션 가이드](https://www.onorca.dev/docs/first-session)를 한 작업으로 줄인 것입니다. 처음부터 여러 에이전트를 띄울 필요는 없습니다. 먼저 에이전트 인증과 프로젝트 실행이 정상인지 확인하는 편이 문제를 찾기 쉽습니다.

**여기까지 확인할 것:** 서버에서 프로젝트를 열고 에이전트에게 질문했을 때 정상적으로 답을 받을 수 있어야 합니다.

## 2. Tailscale로 두 기기 연결하기

Tailscale은 기기들을 **tailnet이라는 사설 네트워크**로 연결합니다. 각 기기에는 사설 IP와 기기 이름으로 접속할 수 있는 MagicDNS가 제공됩니다. Tailscale로 연결 경로를 만들고, 그 경로 위에서 Orca에 접속합니다. [기기 연결 공식 가이드](https://tailscale.com/docs/how-to/connect-to-devices)

![Tailscale 연결, Orca 인증, 서버 프로세스의 역할을 나눈 그림](/assets/images/orca-remote-workspace/orca-access-layers.png)

준비 순서는 다음과 같습니다.

1. 서버와 노트북에 [공식 Tailscale 클라이언트](https://tailscale.com/download)를 설치합니다.
2. 같은 tailnet에 가입하고 연결합니다. 조직 계정이라면 기기 승인·접근 정책도 확인합니다.
3. 관리 콘솔에서 서버의 IP 또는 MagicDNS 이름을 확인합니다.
4. 서버가 켜져 있고 Orca 앱이 실행 중인지 확인합니다.

Tailscale 명령어를 사용할 수 있다면 다음 명령으로 연결 상태를 살펴볼 수 있습니다. `dev-mac`은 자기 서버의 이름으로 바꿉니다.

```bash
tailscale status
tailscale ip -4
tailscale ping dev-mac
```

`ip -4`는 **명령을 실행한 기기 자신의 주소**를 보여줍니다. 노트북에서 실행한 값을 집 서버의 주소로 넣으면 안 됩니다. `ping` 성공도 Orca 인증 성공을 보장하지 않습니다. [Tailscale CLI](https://tailscale.com/docs/reference/tailscale-cli)

**여기까지 확인할 것:** 양쪽 기기가 Tailscale에서 온라인으로 보이고, 노트북에서 서버의 주소를 확인할 수 있어야 합니다.

## 3. 집 컴퓨터를 원격 Orca 서버로 공유하기

공식 문서의 간단한 경로는 **양쪽 Orca 앱 + Tailscale**입니다. 이 경우 별도로 `orca serve`를 실행하지 않습니다. Remote Orca Servers는 베타입니다. [공식 연결 절차](https://www.onorca.dev/docs/remote-servers)

### 설정 화면의 세 가지 탭 이해하기

![Orca 원격 서버 설정 — 호스트에 연결, 이 호스트 공유, 클라우드 VM과 서버 연결 상태](/assets/images/orca-remote-workspace/orca-remote-server-settings.png)

*원격 Orca 서버 설정 화면. 아래 한글 메뉴는 이 화면을 기준으로 설명하며, 공식 문서의 영문 이름을 함께 적었습니다.*

| 화면의 탭 | 어느 기기에서 사용하는가 | 목적 |
| --- | --- | --- |
| **호스트에 연결** | 원격 기기를 조작할 노트북 | 다른 컴퓨터의 Orca 런타임을 등록하고 연결 |
| **이 호스트 공유** | 작업을 계속 실행할 컴퓨터 | 이 컴퓨터를 다른 Orca 클라이언트가 접속할 서버로 공유 |
| **클라우드 VM** | 레시피 기반 실행 환경을 관리할 때 | 레시피로 생성한 클라우드 머신 관리 |

두 기기를 연결할 때는 **서버의 ‘이 호스트 공유’ → 노트북의 ‘호스트에 연결’** 순서로 진행합니다. 클라우드 VM은 별도 실행 방식이며, 이미 가진 Mac 두 대를 연결하기 위해 VM을 만들 필요는 없습니다. 클라우드 실행도 사용자가 준비한 컴퓨터·계정과 레시피를 이용합니다. [공식 실행 방식 비교](https://www.onorca.dev/docs/ways-to-run)

### 서버 공유와 클라이언트 등록

**서버에서:**

1. 서버에서 **설정 → 원격 Orca 서버 → 이 호스트 공유**를 엽니다.
2. 서버 공유 영역(**Advertise this app as a server**)에서 새 링크(**New Link**)를 선택합니다.
3. 연결 주소(**Connection address**)에 **서버의 Tailscale 주소**를 선택합니다.
4. 접속 링크 생성(**Generate Access Link**)으로 링크를 만들고 복사합니다.

**노트북에서:** **설정 → 원격 Orca 서버 → 호스트에 연결 → + 서버 추가**에서 서버 이름과 접속 링크를 입력합니다. 저장 후 연결되지 않았다면 해당 서버를 연결합니다. 공식 영문 문서의 **Add Server**가 이 단계입니다.

### 연결됨과 기본 실행 대상은 다릅니다

서버 카드에 **연결됨**이 표시되면 해당 Orca와 연결된 것입니다. **호환됨**은 버전 호환 상태이며, 에이전트 로그인이나 프로젝트 실행까지 확인해 주는 표시는 아닙니다. 화면의 `v1.4.225 / 최신 상태`는 캡처 당시의 버전·업데이트 상태입니다.

**서버 추가·연결만으로 모든 새 작업이 원격으로 전환되지는 않습니다.** 화면 아래 **고급 → 활성 서버**는 기본 호스트를 변경하려는 경우에 확인합니다. 개별 작업에서도 실행 호스트와 서버 쪽 프로젝트 경로를 확인하세요. 이 구분은 화면 안내와 [공식 Active Server 설명](https://www.onorca.dev/docs/remote-servers#2-add-the-server-on-your-laptop)에 모두 나옵니다.

링크는 비밀번호처럼 취급합니다. 클라이언트별 권한은 서버의 공유 접근 권한 목록(**Shared Server Access**)에서 철회할 수 있습니다. 새 링크 생성만으로 기존 클라이언트 권한이 모두 취소되지는 않습니다.

공식 문서는 Orca 포트의 인터넷 직접 노출을 피하도록 안내합니다. 접속하는 노트북이 잠들어도 원격 에이전트는 실행되지만, **서버는 깨어 있고 Orca가 실행 중이어야 합니다.** 도구와 인증도 서버에 준비해야 합니다. [접근·보안과 실행 조건](https://www.onorca.dev/docs/remote-servers#access-and-security)

**여기까지 확인할 것:** 노트북의 서버 카드에 **연결됨**이 표시되고, 원격 서버의 프로젝트를 선택할 수 있어야 합니다.

## 4. 연결한 서버에서 첫 작업 확인하기

연결을 마쳤다면 **집 서버에 있는 프로젝트로 작업 하나를 진행**해 봅니다. 다음은 작은 조사 작업으로 실행 위치와 결과를 확인하는 예시입니다.

1. 노트북 Orca에서 **연결한 서버와 그 서버의 프로젝트**를 선택합니다. 이름이 같은 로컬 프로젝트와 혼동하지 않도록 실행 호스트를 확인합니다.
2. 선택한 작업의 터미널에서 `pwd`를 실행합니다. 출력이 예상한 서버의 작업 폴더인지 확인합니다. 경로가 같을 수도 있으므로 경로만으로 호스트를 판별하지는 마세요.
3. 새 변경 작업이라면 worktree를 만들고, 시작 브랜치와 실행 호스트를 확인한 뒤 에이전트를 선택합니다.
4. 먼저 아래처럼 범위가 작은 요청을 보냅니다.

```text
이 프로젝트의 실행 방법과 테스트 명령을 찾아줘.
코드는 수정하지 말고, 참고한 파일 경로와 함께 정리해줘.
```

5. 응답에 나온 파일을 열어 내용이 맞는지 확인합니다. 이어서 코드를 수정한다면 변경 내역(diff)과 실제 테스트 결과까지 확인합니다.

이제 노트북은 화면과 입력을 담당하고, 코드와 에이전트는 서버에서 실행되는 흐름입니다. 노트북의 연결이 끊겨도 서버가 깨어 있고 Orca가 실행 중이면 작업을 이어갈 수 있습니다. 서버 절전·재부팅은 별도로 관리해야 합니다. [원격 서버의 실행 위치와 조건](https://www.onorca.dev/docs/remote-servers)

**기본 연결 과정은 여기까지입니다.** 휴대폰으로 확인하려면 다음 절로, 명령어로 작업을 제어하려면 CLI 절로 이동하세요.

## 선택: 휴대폰으로 작업 확인하기

공식 Orca Mobile은 iOS/Android용 베타 보조 앱입니다. 에이전트 상태·출력을 읽고, 질문에 답하고, 소스 변경을 검토하는 등 짧은 후속 조작에 쓸 수 있습니다. 폰에서는 서버에서 실행 중인 작업에 접속합니다. [Mobile companion](https://www.onorca.dev/docs/mobile)

데스크톱의 계정·상태 메뉴에서 모바일 페어링을 시작하고 폰의 **Pair**로 연결합니다. 휴대폰에는 **모바일용 페어링 코드**를 사용합니다. 이 글의 Tailscale 구성을 사용한다면 폰에도 Tailscale을 연결해 서버에 도달할 수 있어야 합니다. **직접 연결용 페어링의 주소도 서버의 Tailscale 주소로 선택**합니다. 집 LAN 주소를 선택한 링크는 폰이 외부망으로 이동한 뒤 그대로 접속되지 않을 수 있습니다.

CLI 호스트는 모바일 범위의 링크를 요청할 수 있습니다. Linux 예시:

```bash
orca-ide serve --pairing-address 100.64.1.20 --mobile-pairing
```

이는 **기존 서버와 함께 두 번째 서버를 띄우라는 명령이 아니라, 서버를 시작할 때 고르는 페어링 방식의 예시**입니다. 실제 접속 주소와 코드를 확인하세요.

최신 모바일 문서에는 Orca Relay도 나옵니다. Relay와 tailnet 직접 연결은 같은 경로가 아니며, Relay에는 별도 로그인 조건이 있습니다. 이 글은 Tailscale로 서버에 직접 연결하는 구성을 설명합니다. 앱 지원·설치 링크는 [현재 모바일 문서](https://www.onorca.dev/docs/mobile#pairing)를 따릅니다.

폰에서는 “테스트 결과 알려줘”, “이 diff의 위험만 정리해줘”처럼 짧게 확인하고, 넓은 코드 리뷰는 큰 화면에서 이어가는 흐름을 제안합니다. 승인 화면에서는 대상 명령과 경로를 읽고 응답합니다.

## 선택: CLI로 원격 Orca 통제하기

반복 작업을 명령어로 처리하고 싶다면 CLI를 사용할 수 있습니다. **접속할 서버 → 작업 폴더 → 터미널**을 차례로 고릅니다. 기본 GUI 연결만 필요하다면 이 절은 건너뛰어도 됩니다.

CLI는 **설정 → 실험적 기능 → CLI(Settings → Experimental → CLI)**에서 등록합니다. macOS 예시는 다음과 같습니다.

```bash
orca --version
orca status --json
orca skills get orca-cli --json
```

마지막 명령은 설치 버전에 맞는 에이전트용 사용 지침입니다. 이 글에서도 읽어 확인했습니다. **Linux에서 앱 밖의 CLI 이름은 `orca-ide`**입니다. 그냥 `orca`가 GNOME 스크린 리더를 가리킬 수 있으므로 아래 macOS 명령을 그대로 복사하지 마세요. [설치 문서의 플랫폼 안내](https://www.onorca.dev/docs/install#linux)

### 1. 원격 환경 등록

이미 등록했다면 `environment list`로 이름을 확인하고 등록 단계는 건너뜁니다. 아래는 macOS의 zsh/bash 예시입니다. 링크를 명령행에 직접 붙여 셸 히스토리에 남기지 않도록 입력을 따로 받습니다.

```bash
printf 'Orca access link: '
IFS= read -r -s orca_pairing_link
printf '\n'
orca environment add --name home --pairing-code "$orca_pairing_link" --json
unset orca_pairing_link

orca environment list --json
orca host list --json
orca status --environment home --json
```

입력한 링크는 등록 명령 실행 중 프로세스 인자로 전달됩니다. 신뢰하는 개인 기기에서 수행하고, 링크가 담긴 출력·기록도 공개하지 마세요. 저장한 환경 이름 `home`을 이후 명령마다 지정하면 로컬 런타임과 혼동할 여지를 줄일 수 있습니다.

### 2. 서버 쪽 저장소와 작업 찾기

```bash
orca repo list --environment home --json
```

출력에서 원하는 저장소의 `id`를 찾습니다. 다음 예시는 **어떤 값을 다음 명령으로 옮기는지 설명하기 위해 항목의 일부만 적은 가상 데이터**입니다. 실제 응답 전체의 형식을 뜻하지 않습니다.

```json
{"id": "repo-example"}
```

이 값을 얻었다면 아래의 `id:REPO_ID`를 `id:repo-example`로 바꿉니다. `worktree list`에서는 사용할 작업의 서버 경로를 확인하고, `terminal list`에서는 터미널 식별자(handle)를 확인합니다. 경로와 `TERMINAL_HANDLE`도 실제 출력에 나온 값으로 교체합니다.

```bash
orca worktree list --repo 'id:REPO_ID' --environment home --json
orca terminal list --worktree 'path:/srv/projects/my-app-task' \
  --environment home --json
```

`/srv/projects/my-app-task`는 서버의 경로 예시입니다. 노트북의 체크아웃 경로를 넣지 않습니다. 원격 명령에서는 현재 디렉터리에 의존하는 `active`보다 명시적인 서버 경로나 전체 worktree ID를 사용하는 편이 명확합니다. [공식 selector 설명](https://www.onorca.dev/docs/cli/reference#selectors)

### 3. 읽고, 준비 상태를 확인하고, 보내기

![원격 CLI 제어 흐름 — 대상 선택, 출력 읽기, 입력 대기 확인, 한 번 전송, 결과 검증](/assets/images/orca-remote-workspace/orca-control-loop.png)

```bash
orca terminal read --terminal 'TERMINAL_HANDLE' --environment home --json

orca terminal wait --terminal 'TERMINAL_HANDLE' --for tui-idle \
  --timeout-ms 60000 --environment home --json
```

출력의 `wait.satisfied`를 확인합니다. **타임아웃 결과가 출력됐다는 사실은 준비 완료의 증거가 아닙니다.** 읽은 화면이 의도한 에이전트의 입력 대기 상태인지도 확인합니다. 셸에 에이전트용 자연어를 보내면 셸 명령으로 해석될 수 있습니다.

준비된 에이전트에만 다음처럼 전송합니다.

```bash
orca terminal send --terminal 'TERMINAL_HANDLE' \
  --text '현재 변경을 검토하고, 실행한 테스트와 남은 문제를 정리해줘.' \
  --enter --wait-submit 10 --environment home --json

orca terminal read --terminal 'TERMINAL_HANDLE' --environment home --json
```

전송 결과에는 `input_accepted`와 `turn_started`가 구분되어 표시될 수 있습니다. 전자는 입력 수락, 후자는 턴 시작을 관찰했다는 뜻이며 **작업 성공의 증거는 아닙니다.** 응답이 늦다고 같은 프롬프트를 다시 보내지 않습니다. 통신 결과가 모호하면 반환된 전송 요청 ID와 `--retry-request` 지침을 확인합니다. 서버 재시작으로 터미널 식별자가 무효화되면 `terminal list`에서 다시 얻습니다.

완료 판단은 테스트 결과·종료 코드·diff로 합니다. 에이전트의 “끝났다”는 답이나 idle 상태만으로 배포 준비가 끝났다고 보지 않습니다.

### 4. 원격에서 새 작업 시작하기

새 작업 폴더가 필요할 때의 예시입니다. 서버에 Codex가 설치·인증되어 있고, 저장소와 프로젝트 초기 설정 스크립트가 준비되어 있어야 합니다.

```bash
orca worktree create --repo 'id:REPO_ID' --name investigate-login \
  --no-parent --agent codex \
  --prompt '로그인 실패 원인을 조사하고 결과를 Markdown 파일에 정리해줘.' \
  --environment home --json
```

`--no-parent`는 Orca의 부모 작업 관계를 지정하지 않는 옵션이며, Git 시작 브랜치를 정하는 옵션은 아닙니다. 별도의 시작 브랜치나 커밋을 지정하지 않으면 저장소의 기본 시작 브랜치를 확인해야 합니다.

`--agent`로 이미 시작한 에이전트를 `terminal create`로 중복 실행하지 않습니다. 같은 작업 폴더에서 새 터미널만 필요한 경우와 새 worktree가 필요한 경우도 구분하세요. [CLI의 작업·터미널 명령](https://www.onorca.dev/docs/cli/reference)

## 선택: SSH 방식으로 연결하기

“원격 컴퓨터에서 코딩한다”는 같은 말이지만 연결 구조가 다릅니다.

![Orca 원격 사용 구조 — SSH worktree와 Remote Orca Server의 실행 위치 비교](/assets/images/orca-remote-workspace/orca-remote-map.png)

| 질문 | SSH worktree | Remote Orca Server |
| --- | --- | --- |
| 프로젝트·세션 전체를 관리하는 쪽은? | 노트북 쪽 Orca | 원격 컴퓨터의 Orca |
| 코드와 에이전트는? | SSH 호스트 | 원격 Orca 서버 |
| 주된 목적은? | 노트북에서 원격 개발 장비 활용 | 여러 기기에서 같은 작업 환경 이용 |
| 시작 방법은? | SSH 대상 등록 → Run on 선택 | 원격 앱 공유 또는 `serve` → 페어링 |

이 구분은 공식 [Ways to run Orca](https://www.onorca.dev/docs/ways-to-run)에 기반합니다. Orca가 VPS를 제공하는 서비스는 아닙니다.

이 글에서 원하는 **“집에 있는 컴퓨터가 작업하고, 밖에서는 확인하고 지시하기”**에는 Remote Orca Server 구성이 잘 맞습니다. 반면 원격 Linux 개발 장비를 노트북 한 대에서 다루는 목적이면 SSH 방식부터 검토할 수 있습니다.

### SSH 연결 절차

이미 SSH로 접속 가능한 개발 서버가 있다면 다음 경로를 사용할 수 있습니다. 이 방식에서는 원격 Orca 전체 런타임을 페어링하는 대신 **설정 → SSH(Settings → SSH)**에 호스트를 등록합니다. [SSH worktrees](https://www.onorca.dev/docs/ssh)

먼저 일반 터미널에서 서버에 접속되는지 확인합니다.

```bash
ssh dev@dev-mac
```

`dev`는 서버의 OS 사용자명, `dev-mac`은 Tailscale의 서버 이름 예시입니다. 이름 해석이 안 되면 서버의 실제 Tailscale IP로 확인할 수 있습니다.

`~/.ssh/config` 예시:

```sshconfig
Host orca-home
    HostName dev-mac
    User dev
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

1. Orca **설정 → SSH → 대상 추가(Add Target)**에서 호스트 정보를 넣거나 SSH config를 선택합니다.
2. **연결 테스트(Test)**로 연결을 확인하고 저장합니다.
3. worktree 생성 시 **실행 위치(Run on)**에서 해당 호스트를 선택합니다.

공식 SSH 문서는 호스트의 관리 서버가 원격 터미널 프로세스를 유지하므로 노트북 Orca를 닫아도 세션이 살아남는다고 설명합니다. 이것을 서버 재부팅 후에도 같은 프로세스가 유지된다는 뜻으로 확대하면 안 됩니다. 연결이 끊겼을 때도 새 에이전트를 중복 기동하기 전에 기존 상태를 확인합니다. [SSH 세션 지속성](https://www.onorca.dev/docs/ssh#sessions-across-app-close)

**Tailscale을 통한 일반 SSH와 Tailscale SSH는 다릅니다.** 위 예시는 서버의 기존 SSH 서비스를 사설 주소로 이용할 수 있습니다. Tailscale SSH는 인증·인가까지 Tailscale이 관리하는 별도 기능이며 서버 측 지원 플랫폼과 정책 조건이 있습니다. macOS App Store·standalone 앱을 설치했다고 Tailscale SSH 서버가 자동 활성화되지는 않습니다. [Tailscale SSH 공식 조건](https://tailscale.com/docs/features/tailscale-ssh)

## 선택: 창 없는 서버에서 실행하기

Linux 서버 등에서는 CLI로 런타임을 실행할 수 있습니다. **같은 컴퓨터의 데스크톱 앱이 이미 서버로 공유 중이라면 추가 `serve` 프로세스를 실행하지 않습니다.** 데스크톱 앱 공유 대신 선택하는 방식으로, 다음은 **Linux 예시**입니다. IP는 실제 서버 주소로 바꿉니다.

```bash
orca-ide serve --port 6768 --pairing-address 100.64.1.20
```

macOS CLI에서는 실행 파일 이름을 `orca`로 바꿉니다. `6768`은 여기서 **명시적으로 고정한 예시 포트**입니다. 실행 결과의 접속 주소(endpoint)와 페어링 링크를 확인하세요.

로컬 1.4.224의 `orca serve --help`로 확인한 사항은 다음과 같습니다.

- 명령을 실행한 터미널에서 계속 동작하며 `Ctrl+C`로 종료합니다.
- `--pairing-address`는 **클라이언트에 알릴 주소**를 바꿉니다. 서버의 바인딩 주소를 Tailscale 인터페이스로 제한하는 옵션이 아닙니다.
- 일반 런타임 페어링과 모바일용 페어링 옵션이 구분됩니다.
- 원격 OS 데스크톱 제어 권한은 일반 런타임 연결과 별개입니다. 터미널 관리에 `--grant-desktop-control`이 필요한 것은 아닙니다.

따라서 “Tailscale 주소를 적었으니 다른 인터페이스에서는 접근할 수 없다”고 판단하지 마세요. 호스트 방화벽과 tailnet 정책을 별도로 확인합니다.

최신 [CLI reference](https://www.onorca.dev/docs/cli/reference#runtime-commands)에는 서비스 설치·상태 확인 명령도 나옵니다. 다만 **이 글에서 확인한 1.4.224의 `serve --help`에는 그 하위 명령이 없습니다.** 최신 문서를 그대로 붙여넣기보다 설치 버전의 도움말을 우선하고, 장기 운영은 해당 버전의 서비스 지원을 확인한 뒤 구성하세요.

## 문제 해결과 운영 기준

접속 장애는 **네트워크 → 서비스 → 인증 → 작업 환경** 순서로 좁히면 됩니다.

| 증상 | 먼저 확인할 것 |
| --- | --- |
| 서버가 안 보임 | 양쪽 Tailscale 온라인 여부, 실제 서버 이름·주소, 서버 절전 |
| `tailscale ping`은 되지만 Orca 연결 실패 | Orca 프로세스, 실제 포트, 호스트 방화벽과 tailnet 정책 |
| 페어링·인증 실패 | 링크 종류, 만료·사용 여부, 해당 기기의 접속 권한, 양쪽 버전 |
| 연결됐지만 작업이 없음 | 다른 서버나 저장소를 고르지 않았는지, 서버 경로·화면 필터 |
| 에이전트 실행 실패 | 서버의 `PATH`, CLI 설치, 인증, 작업 디렉터리 |
| 명령 전송 후 조용함 | 출력과 전송 결과, 에이전트 질문 대기, 중복 전송 여부 |

네트워크와 서비스의 확인 순서는 [Tailscale 기기 연결 가이드](https://tailscale.com/docs/how-to/connect-to-devices#troubleshooting)를 참고하세요. 프로토콜 불일치는 Orca 양쪽 버전을 확인합니다.

접근 제어는 두 겹입니다. Tailscale 정책으로 **접근 가능한 기기와 포트**를 좁히고, Orca에서 **페어링한 클라이언트 권한**을 관리합니다. tailnet에 들어왔다고 모든 서비스에 접근해야 할 이유는 없습니다. Tailscale은 새 정책 작성에 grants(접근 허용 규칙) 사용을 안내합니다. 기존 정책 전체를 예제 하나로 덮어쓰지 말고, 현재 사용자·기기·태그에 맞게 필요한 접근을 설정합니다. **grants는 허용 규칙의 합집합**이므로 좁은 규칙을 추가해도 기존의 넓은 허용이 남아 있으면 접근이 제한되지 않습니다. [Grants](https://tailscale.com/docs/features/access-control/grants), [규칙 합성 방식](https://tailscale.com/docs/reference/syntax/grants)

**Tailscale Serve와 Funnel도 구분해야 합니다.** Serve는 tailnet 내 공유, Funnel은 공개 인터넷 노출 용도입니다. 이번 구성은 양쪽 Tailscale 연결을 사용하므로 Funnel을 켤 필요가 없습니다. [Serve](https://tailscale.com/docs/features/tailscale-serve), [Funnel](https://tailscale.com/docs/features/tailscale-funnel)

“연결이 끊김”, “앱이 재시작됨”, “서버가 재부팅됨”도 같은 사건이 아닙니다. Orca의 [Session restore](https://www.onorca.dev/docs/model/session-restore)는 작업 화면과 복구 흐름을 설명합니다. **UI 복원이나 대화 재개를 중단 없는 프로세스 실행과 혼동하지 마세요.** 장시간 작업이라면 산출물과 진행 상황을 파일로 남기고, 서버 재시작 후 실제 프로세스·테스트 상태를 다시 확인하는 운영이 필요합니다.

### 연결은 되는데 느리다면

Tailscale은 가능한 경우 기기끼리 직접 연결하고, 환경에 따라 DERP 등 릴레이 경로를 사용합니다. 릴레이 연결이라고 반드시 장애인 것은 아니지만 지연·성능은 달라질 수 있습니다. [연결 유형](https://tailscale.com/docs/reference/connection-types)

## 공식 참고 자료

본문의 링크는 해당 설명을 확인한 공식 자료입니다. 시작점으로 읽기 좋은 문서는 다음과 같습니다.

- [Orca 소개·설치](https://www.onorca.dev/docs)와 [첫 세션](https://www.onorca.dev/docs/first-session)
- [원격 실행 방식 비교](https://www.onorca.dev/docs/ways-to-run), [Remote Orca Servers](https://www.onorca.dev/docs/remote-servers), [SSH worktrees](https://www.onorca.dev/docs/ssh)
- [Orca CLI reference](https://www.onorca.dev/docs/cli/reference), [Mobile companion](https://www.onorca.dev/docs/mobile)
- [Tailscale 기기 연결](https://tailscale.com/docs/how-to/connect-to-devices), [CLI](https://tailscale.com/docs/reference/tailscale-cli), [Tailscale SSH](https://tailscale.com/docs/features/tailscale-ssh)

설정 화면은 Orca **1.4.225**, CLI 예시는 **1.4.224**를 기준으로 합니다. 서비스 명령은 설치된 버전의 도움말을 확인하세요.
