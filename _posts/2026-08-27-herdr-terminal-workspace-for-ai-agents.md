---
layout: post
title: "Herdr 파헤치기: AI 에이전트를 위한 터미널 워크스페이스 (feat. Helix + Lazygit)"
author: Gidong
categories: [설정]
tags: [terminal, herdr, tmux, multiplexer, ai, claude-code, codex, helix, lazygit, cli, workflow]
image: assets/images/herdr-terminal-workspace/herdr-anatomy.svg
sitemap:
  changefreq: daily
  priority: 1.0
---

> [2026 Mac 터미널 완벽 세팅](https://blog.dnd.ac/settings-mac-terminal-2026/) 글에서 Ghostty + Starship + AI 코딩 도구까지 구성했습니다.
> 이번 글은 그 위에 **터미널 멀티플렉서 레이어**를 올리고, 그 도구를 깊게 다룹니다.
> tmux 대신 **[Herdr](https://herdr.dev)**를 써서 Claude Code / Codex 같은 에이전트를 워크스페이스 단위로 관리하고,
> Helix + Lazygit으로 터미널 안에서 코드 수정과 diff 확인까지 끝내는 흐름을 정리했습니다.
> 글의 절반 이상은 **Herdr 자체의 사용법과 장단점**에 할애했습니다.

## 목차

1. [Herdr란 무엇인가](#herdr란-무엇인가)
2. [tmux와 무엇이 다른가](#tmux와-무엇이-다른가)
3. [설치](#설치)
4. [핵심 개념: Workspace / Tab / Pane / Agent](#핵심-개념-workspace--tab--pane--agent)
5. [기본 사용법 (마우스 · 키보드 · CLI)](#기본-사용법-마우스--키보드--cli)
6. [에이전트 상태 이해하기](#에이전트-상태-이해하기)
7. [세션은 어디까지 살아남나](#세션은-어디까지-살아남나)
8. [CLI 자동화: 다른 패널에서 에이전트 돌리기](#cli-자동화-다른-패널에서-에이전트-돌리기)
9. [실전: 오른쪽 패널로 코드 리뷰 시키기](#실전-오른쪽-패널로-코드-리뷰-시키기)
10. [Herdr의 장점과 한계](#herdr의-장점과-한계)
11. [Helix + Lazygit 조합](#helix--lazygit-터미널-안에서-수정하고-diff-보기)
12. [herdr-file-viewer 플러그인](#herdr-file-viewer-플러그인으로-파일-뷰어-붙이기)
13. [정리](#정리)

---

## Herdr란 무엇인가

Herdr는 **AI 코딩 에이전트를 위한 터미널 워크스페이스 매니저**입니다.
tmux와 같은 계열의 **멀티플렉서(multiplexer)**입니다. 즉,

- 백그라운드 **서버 프로세스**가 실제 PTY(터미널)들을 소유하고,
- **클라이언트**가 거기에 붙어서(attach) 화면을 렌더링합니다.
- 클라이언트를 닫아도(detach) 서버 쪽 프로세스는 계속 돌아갑니다.

여기까지는 tmux와 똑같습니다. 차이는 Herdr가 **그 위에서 도는 프로세스가 "코딩 에이전트"라는 걸 안다**는 점입니다.
패널 안에서 `claude`나 `codex`를 실행하면 Herdr가 화면 출력을 보고 "지금 작업 중인지 / 승인을 기다리는지 / 놀고 있는지"를 판별해서 탭 옆에 아이콘으로 보여줍니다.
그리고 그 판별 결과와 제어 기능을, **에이전트가 직접 호출할 수 있는 CLI + 소켓 API**로 노출합니다.

![Herdr 워크스페이스 구조 — Workspace / Tab / Pane / Agent 상태](/assets/images/herdr-terminal-workspace/herdr-anatomy.svg)

---

## tmux와 무엇이 다른가

| 항목 | tmux | Herdr |
| --- | --- | --- |
| 기본 조작 | 키보드 프리픽스(`Ctrl+B`) 위주 | **마우스 우선** — 패널 클릭, 경계 드래그, 우클릭 메뉴 |
| 에이전트 인식 | 없음 (그냥 셸) | 화면을 읽어 **working / blocked / done / idle / unknown** 판정 |
| 상태 가시성 | 없음 | 탭·패널마다 상태 아이콘, "Action Required" 배지 |
| 자동화 인터페이스 | `tmux send-keys` 로 키 주입 | `herdr agent prompt` 등 **에이전트 전용 명령** + 소켓 API |
| 구성 단위 | session → window → pane | workspace → tab → pane (+ agent) |
| 설정 | `~/.tmux.conf` | `~/.config/herdr/config.toml` |
| 라이선스 / 성숙도 | ISC, 20년 이상 | Apache 2.0, 아직 0.8.x (빠르게 변동) |

핵심은 **"에이전트를 여러 개 동시에 굴릴 때"** 갈립니다.
tmux에서는 창을 6개 띄워놓고 각각 어느 게 멈췄고 어느 게 승인을 기다리는지 일일이 눈으로 확인해야 합니다.
Herdr는 그 상태를 UI로 모아 보여주고, "3번 패널이 승인 대기"라는 걸 사이드바에서 바로 알 수 있습니다.

> **주의 — tmux 중첩:** Herdr의 기본 프리픽스도 tmux와 같은 `Ctrl+B`입니다.
> Herdr 패널 안에서 다시 tmux로 들어가거나, `.zshrc`가 자동으로 `tmux`에 진입하도록 되어 있으면
> **키 충돌**이 나고, Herdr는 전경(foreground)의 `tmux` 프로세스만 보게 되어 그 안의 **에이전트를 감지하지 못합니다.**
> Herdr를 쓰는 동안에는 셸 자동 tmux 진입을 꺼두는 것을 권장합니다.

---

## 설치

```bash
# Herdr (macOS / Linux)
curl -fsSL https://herdr.dev/install.sh | sh

# 또는 Homebrew / mise / Nix 패키지도 제공됩니다
brew install herdr

# 이 글에서 함께 쓰는 도구
brew install helix                 # 모달 에디터 (hx)
brew install glow git-delta bat    # herdr-file-viewer 렌더러 (선택)
```

> `lazygit`, `git-delta`, `bat`은 [2026 터미널 세팅](https://blog.dnd.ac/settings-mac-terminal-2026/) 글에서 이미 설치했다면 건너뛰어도 됩니다.

설치 후 프로젝트 디렉토리에서 실행합니다.

```bash
cd ~/projects/my-app
herdr                 # 세션을 새로 만들거나, 있으면 attach
```

- 직접 설치(curl)한 경우 업데이트는 `herdr update`.
- 패키지 매니저로 설치한 경우 해당 매니저로 업데이트.
- 안정/프리뷰 채널 전환은 `herdr channel set <stable|preview>`.

> **주의:** 원격 설치 스크립트는 실행 전에 내용을 한 번 확인하는 것을 권장합니다.
> AI에게 실행을 맡기더라도 실제 실행 전에는 명령어를 직접 검토하세요.

---

## 핵심 개념: Workspace / Tab / Pane / Agent

| 개념 | 공개 ID 예시 | 설명 |
| --- | --- | --- |
| **Workspace** | `w1` | 프로젝트 단위 컨테이너. 탭과 패널을 담습니다. |
| **Tab** | `w1:t1` | 워크스페이스 안의 레이아웃 하나. |
| **Pane** | `w1:p1` | 실제 터미널. 오른쪽 또는 아래로 분할합니다. |
| **Agent** | (패널 점유) | 패널 안에서 인식된 에이전트. 고유 이름을 붙일 수 있습니다. |

몇 가지 규칙이 실전에서 중요합니다.

- **패널은 에이전트가 없어도 존재합니다.** 그냥 셸이 도는 패널도 패널입니다.
- `agent start`는 **이미 있는 빈 셸 패널**에서 에이전트를 띄울 뿐, 레이아웃을 만들거나 분할하지 않습니다. 레이아웃은 `pane split`으로 먼저 만듭니다.
- **닫힌 탭·패널 ID는 재사용되지 않습니다.** 패널을 다른 워크스페이스로 옮기면 새 ID를 받습니다.
- 에이전트 이름은 `[a-z][a-z0-9_-]{0,31}` 형식이고, 살아 있는 에이전트 사이에서 유일해야 합니다. 그 에이전트가 종료되면 이름은 해제됩니다.

Herdr는 각 관리 패널에 **호출자 컨텍스트**를 환경변수로 주입합니다.

```bash
printf '%s\n' "$HERDR_WORKSPACE_ID" "$HERDR_TAB_ID" "$HERDR_PANE_ID"
# w1  w1:t1  w1:p1
```

덕분에 패널 안에서 `herdr pane split --current …`처럼 **"지금 이 패널"**을 기준으로 명령할 수 있습니다.

---

## 기본 사용법 (마우스 · 키보드 · CLI)

Herdr는 조작 경로가 세 가지입니다. 셋을 섞어 씁니다.

### 1. 마우스

새 사용자는 **마우스만으로 전부** 조작할 수 있습니다.

- 패널 클릭 → 포커스 이동
- 패널 경계 드래그 → 크기 조절
- 우클릭 → 분할 / 닫기 / 에이전트 메뉴
- 사이드바에서 워크스페이스·탭·상태 한눈에

### 2. 키보드

프리픽스 키는 기본 `Ctrl+B`입니다. **`prefix+?`** (`Ctrl+B`를 놓은 뒤 `?`)를 누르면 현재 활성화된 키바인딩이 전부 실시간으로 표시됩니다.
키바인딩은 `~/.config/herdr/config.toml`에서 재정의하고, `herdr config reset-keys`로 커스텀 키만 초기화할 수 있습니다.

### 3. CLI

`HERDR_ENV=1`인 패널이면 `herdr` 명령이 현재 세션에 그대로 연결됩니다.

```bash
herdr workspace list
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
herdr pane list --workspace "$HERDR_WORKSPACE_ID"
herdr pane current --current
herdr agent list
```

패널 분할 — 넓은 패널은 **오른쪽으로**, 좁고 긴 패널은 **아래로** 나누는 것이 기본입니다.

```bash
# 현재 패널 오른쪽에 분할, 포커스는 그대로, 작업 디렉토리 유지
herdr pane split --current --direction right --cwd "$PWD" --no-focus
# → 응답 JSON 의 .result.pane.pane_id 를 다음 명령에 사용
```

대부분의 제어 명령은 **JSON을 반환**합니다. ID나 상태는 예측하지 말고 응답에서 읽으세요.
`herdr <group>`을 서브커맨드 없이 실행하면 그 그룹의 사용법이 출력됩니다 (`herdr agent`, `herdr pane`, `herdr workspace` …).
단, `herdr`를 아무 인자 없이 실행하면 TUI가 뜨므로 탐색 용도로는 쓰지 않습니다.

에이전트 통합(integration)은 명시적으로 설치할 수 있습니다.

```bash
herdr integration install claude
herdr integration install codex
herdr integration status
```

> integration은 주로 **세션 식별자를 기록**해서 재시작 후 `resume`을 돕는 역할입니다.
> 권한 프롬프트를 자동으로 승인해 주는 기능이 아니며, 상태 판정은 여전히 **화면 기반**입니다.
> ([Herdr integrations 문서](https://herdr.dev/docs/integrations/))

---

## 에이전트 상태 이해하기

Herdr가 패널 출력을 읽어 붙이는 상태 라벨은 다섯 가지입니다. 이 의미를 정확히 알아야 자동화가 안전합니다.

![herdr 에이전트 상태 — idle / working / blocked / done / unknown](/assets/images/herdr-terminal-workspace/herdr-agent-states.svg)

| 상태 | 의미 | 자동화 시 주의 |
| --- | --- | --- |
| `idle` | 입력 대기. 해당 탭이 포커스된 UI에 노출된 적 있음 | 프롬프트 전송 안전 |
| `working` | 턴 진행 중 (스피너 표시) | `--wait`는 현재 턴이 끝나면 반환될 수 있음 |
| `blocked` | 승인·질문 UI를 Herdr가 인식함 | `agent prompt`는 **거부**됨(`agent_blocked`). 사람이 응답해야 함 |
| `done` | `idle`과 같은 상태지만, **안 보이는 채로** 백그라운드 작업이 끝난 경우 | 탭을 포커스하면 `idle`로 바뀜 |
| `unknown` | 에이전트는 있지만 Herdr가 분류하지 못함 | **완료의 증거가 아님** |

`idle`과 `done`을 가르는 건 "그 탭이 포커스된 Herdr UI에 보인 적 있는가"입니다.
CLI로 읽기만 하면 "봤다"로 치지 않고, 탭을 포커스하거나 `agent focus`로 대상을 지정해야 "봤다"로 처리됩니다.

---

## 세션은 어디까지 살아남나

멀티플렉서를 쓰는 가장 큰 이유가 세션 지속성입니다. Herdr가 **정확히 어디까지 지켜주는지**는 구분이 필요합니다.

| 상황 | 결과 |
| --- | --- |
| 클라이언트 detach / SSH 끊김 / 노트북 덮개 닫고 이동 | ✅ 서버 프로세스 유지, 다시 `herdr`로 attach하면 그대로 |
| **호스트가 실제로 sleep** | ⚠️ CPU가 멈추므로 그 안의 실행도 **함께 정지** (깨어나면 재개) |
| Herdr 서버 재시작 / 머신 재부팅 | ⚠️ 원래 프로세스는 사라지고 **레이아웃만 복원**됨 |
| 대화(conversation) 복구 | 공식 integration이 세션을 기록한 에이전트에 한해 `resume` 가능 |

즉 "네트워크가 끊겨도 에이전트가 계속 일한다"는 맞지만, "맥을 재워도 계속 일한다"는 아닙니다.
자세한 동작은 [Herdr session state 문서](https://herdr.dev/docs/session-state/)를 참고하세요.

---

## CLI 자동화: 다른 패널에서 에이전트 돌리기

Herdr의 진짜 장점은 **에이전트가 직접 쓰는 CLI**가 그대로 노출된다는 점입니다.
패널 안에서 `herdr` 명령으로 레이아웃을 만들고, 다른 에이전트를 띄우고, 프롬프트를 보내고, 출력을 읽을 수 있습니다.

```bash
# 1. 현재 패널 오른쪽에 새 패널 분할
herdr pane split --current --direction right --cwd "$PWD" --no-focus
#    → .result.pane.pane_id (예: w1:p2)

# 2. 그 패널에서 Codex 에이전트 기동 (빈 셸 패널이어야 함)
herdr agent start reviewer --kind codex --pane w1:p2

# 3. 프롬프트 전달 후 대기
herdr agent prompt reviewer "현재 diff를 리뷰하고 실행 가능한 지적만 알려줘." --wait --timeout 180000

# 4. 결과 읽기 (로그·트랜스크립트는 recent-unwrapped 권장)
herdr agent read reviewer --source recent-unwrapped --lines 200
```

| 명령 | 역할 |
| --- | --- |
| `herdr pane split` | 패널 분할. `--direction right\|down`, `--no-focus`로 포커스 유지 |
| `herdr agent start <name> --kind <kind> --pane <id>` | 빈 셸 패널에서 에이전트 기동 (레이아웃은 만들지 않음) |
| `herdr agent prompt <name> "<text>" --wait` | 프롬프트 전송 후 **`idle`·`done`·`blocked` 중 하나**까지 대기 |
| `herdr agent wait <name> --until blocked` | 특정 상태를 기다리는 워크플로우용 |
| `herdr agent read <name>` | 에이전트 출력 읽기 |
| `herdr agent send-keys <name> esc` | 승인 다이얼로그 등 인터랙티브 UI 제어 |

**`--wait`의 의미에 주의하세요.** `--wait`는 "작업이 성공적으로 끝날 때까지"가 아니라
**`idle` / `done` / `blocked` 중 처음 안정된 상태**까지 기다립니다.
승인·질문 화면(`blocked`)에서도 반환되므로, 반환된 JSON의 `agent_status`를 반드시 확인하고
`blocked`이면 `agent read`로 무엇을 묻는지 본 뒤 **사람이 의도적으로 응답**해야 합니다.
자동으로 `y`를 보내지 마세요. ([Herdr agent automation 문서](https://herdr.dev/docs/agent-automation/))

`kind`로 지원하는 에이전트는 `pi`, `claude`, `codex`, `gemini`, `cursor`, `opencode`, `grok` 등 20종이 넘습니다.
`herdr agent`를 인자 없이 실행하면 전체 목록이 나옵니다.

---

## 실전: 오른쪽 패널로 코드 리뷰 시키기

이 글도 그렇게 썼습니다. Claude가 초안을 쓴 뒤, **오른쪽에 Codex 패널을 띄워 리뷰**시키고 지적을 반영했습니다.

![리뷰 워크플로우 레이아웃 — 왼쪽 위 Claude, 왼쪽 아래 Helix, 오른쪽 Codex 리뷰어](/assets/images/herdr-terminal-workspace/herdr-review-layout.svg)

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus     # → w1:p2
herdr agent start reviewer --kind codex --pane w1:p2

herdr agent prompt reviewer \
  "_posts/2026-08-27-herdr-terminal-workspace-for-ai-agents.md 초안을 기술 리뷰해줘. \
   herdr/helix/lazygit CLI 명령어와 키바인딩 정확성, 사실 오류·과장 위주로 \
   실행 가능한 지적만." --wait --timeout 300000

herdr agent read reviewer --source recent-unwrapped --lines 200
```

돌아온 지적 중 실제로 반영한 것들:

- "맥이 잠들어도 계속 작업" → **"detach·네트워크 단절에는 유지되지만 host sleep 시엔 정지"**로 완화
- `prefix ?` 표기 → 공식 표기인 **`prefix+?`**로 통일
- integration이 "권한 프롬프트 자동 처리" → **삭제** (세션 식별자 기록이 실제 역할)
- `--wait` = "완료까지 대기" → **"`idle`/`done`/`blocked` 중 하나까지"**로 정정
- Lazygit `Enter` / `Tab` 키 설명, delta pager 설정 정정 (아래 Lazygit 절 참고)

> 중간에 Codex가 `blocked` 상태로 문서 fetch 명령 승인을 요청했고,
> 위 원칙대로 **사람이 직접 확인하고 승인**했습니다. `--wait`가 `blocked`에서 반환된다는 걸 실제로 확인한 셈입니다.

**패널 배치 예시:** 왼쪽 위 Claude/Codex, 왼쪽 아래 Helix, 오른쪽 Lazygit 또는 리뷰어.

---

## Herdr의 장점과 한계

몇 주 써 보고 정리한 장단점입니다.

### 장점

| 장점 | 설명 |
| --- | --- |
| **에이전트 상태 가시성** | 6개 패널에서 어느 게 멈췄고 어느 게 승인 대기인지 사이드바에서 즉시 파악. tmux엔 없는 것 |
| **CLI = API** | 사람이 쓰는 명령과 에이전트가 자동화에 쓰는 명령이 동일. "에이전트가 스스로 패널을 만들어 다른 에이전트에게 리뷰 요청" 같은 흐름이 자연스러움 |
| **마우스 우선** | tmux 프리픽스 암기 없이 바로 시작. 경계 드래그로 크기 조절이 직관적 |
| **멀티 워크스페이스** | 한 세션에서 여러 프로젝트를 워크스페이스로 분리 |
| **에이전트 무개조 호환** | Claude Code, Codex, Cursor, opencode, Grok 등 기존 도구를 그대로 실행 |
| **detach 지속성** | SSH가 끊기거나 클라이언트를 닫아도 서버 쪽 작업은 유지 |

### 한계 · 주의할 점

| 한계 | 설명 |
| --- | --- |
| **화면 기반 상태 판정** | 상태는 출력을 "보고" 추정하는 것. 낯선 UI는 `unknown`, 드물게 `done` 오판 가능. 완료 여부를 상태만으로 확신하면 안 됨 |
| **대체 화면 출력 유실** | 에이전트가 alternate screen(전체화면 TUI)에서 돌면, 스크롤을 벗어난 응답은 스크롤백에 안 남아 `agent read --lines`로도 복구 불가. 이 경우 에이전트에게 결과를 파일로 쓰게 하는 우회가 필요 |
| **host sleep 시 정지** | 위 "세션은 어디까지 살아남나" 참고. 서버 재부팅 시엔 프로세스 소멸, 레이아웃만 복원 |
| **비심사 플러그인 마켓** | `herdr-plugin` 토픽 저장소를 **자동 색인**하는 비심사 카탈로그. 설치 시 manifest의 build step이 실행될 수 있음 |
| **프리픽스 충돌** | 기본 `Ctrl+B`가 tmux와 동일 → 중첩 금지 |
| **성숙도** | 아직 0.8.x. 명령·플래그·키바인딩이 버전 사이에 변동됨. 설치된 바이너리의 `herdr --help`가 최종 기준 |

정리하면 Herdr는 **"에이전트를 여러 개, 반쯤 자동으로 굴리는" 워크플로우**에 강하고,
단일 셸 하나만 쓰는 사람에겐 tmux 대비 이점이 크지 않습니다.

---

## Helix + Lazygit: 터미널 안에서 수정하고 diff 보기

에이전트가 만든 변경을 사람이 빠르게 손보고 확인하는 조합입니다.
Herdr 패널 하나는 **Helix**(수정), 하나는 **Lazygit**(스테이징·diff·커밋)으로 둡니다.

### Helix — 모달 에디터

```bash
brew install helix
hx _posts/2026-08-27-herdr-terminal-workspace-for-ai-agents.md
```

Helix는 별도 플러그인 설치 없이 **LSP 클라이언트와 기본 언어 설정, tree-sitter 구문 강조, 파일 피커**가 내장입니다.
다만 **언어 서버 실행 파일(rust-analyzer, typescript-language-server 등)은 직접 설치**해야 하고,
`Space k`·`gd` 같은 기능은 해당 언어에 **활성 LSP가 있어야** 동작합니다. (`hx --health`로 확인)
Vim과 달리 **"선택 → 동작"** 순서(예: `w`가 단어를 먼저 선택)라는 점만 익히면 됩니다.

| 키 | 동작 |
| --- | --- |
| `space f` | 파일 피커 (퍼지 검색) |
| `space b` | 열린 버퍼 목록 |
| `space k` | 커서 심볼 문서 보기 *(활성 LSP 필요)* |
| `g d` | 정의로 이동 *(활성 LSP 필요)* |
| `] g` / `[ g` | **다음 / 이전 Git 변경 지점으로 이동** (거터에 diff 표시) |
| `:w` / `:wq` | 저장 / 저장 후 종료 |
| `:reload` / `:reload-all` | 디스크에서 다시 읽기 |

`]g` / `[g`와 거터의 변경 표시 덕분에 **에이전트가 수정한 파일에서 바뀐 줄만 빠르게 훑어볼 수 있습니다.**

> **주의:** `:reload-all`은 **모든 버퍼의 미저장 변경을 버리고** 디스크 내용으로 되돌립니다.
> 에이전트가 파일을 덮어쓴 뒤 버퍼를 최신화할 때 쓰되, 내 편집이 남아 있다면 먼저 저장하세요.

### Lazygit — diff와 스테이징

```bash
lg    # = lazygit (2026 터미널 세팅 글의 별칭)
```

| 키 | 동작 |
| --- | --- |
| `↑` `↓` | 파일 / 커밋 목록 이동 |
| `enter` | 선택 **파일** → 라인/헝크 스테이징 뷰 진입 · 선택 **디렉터리** → 접기/펼치기 |
| `space` | 파일(또는 라인/헝크) 스테이징 / 언스테이징 |
| `1` ~ `5` | Status / Files / Branches / Commits / Stash 패널 이동 |
| `tab` | main 패널에서 **staged ↔ unstaged 뷰 전환** |
| `c` | 커밋 · `P` 푸시 · `p` 풀 |

**delta를 Lazygit diff에도 적용하려면** Git의 `core.pager`만으로는 부족하고 Lazygit 설정이 별도로 필요합니다.
`~/.config/lazygit/config.yml`:

```yaml
git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never --side-by-side
```

- `--side-by-side`(또는 `~/.config/git/delta` 설정의 `side-by-side = true`)를 **직접 넣어야** 2단 표시가 됩니다.
- `delta --navigate`는 Lazygit 안에서는 동작하지 않습니다.

**워크플로우:** 에이전트가 코드를 바꾸면 → Lazygit `enter`로 헝크 확인 → Helix로 손보고 `:w` →
Lazygit `space`로 스테이징 → `c`로 커밋. 모두 Herdr 패널 안에서.

---

## herdr-file-viewer 플러그인으로 파일 뷰어 붙이기

Herdr는 GitHub `herdr-plugin` 토픽 저장소를 자동 색인하는 **커뮤니티 플러그인 마켓플레이스**를 가지고 있습니다.
그중 [`smarzban/herdr-file-viewer`](https://github.com/smarzban/herdr-file-viewer)는
왼쪽에 디렉토리 트리, 오른쪽에 파일 내용을 보여주는 **git-aware 파일 뷰어**입니다.
변경된 파일은 diff, 마크다운은 렌더링, 코드는 구문 강조로 — 모드 전환 없이 자동으로 보여줍니다.

![herdr-file-viewer — 트리 + 내용 패널(diff/렌더링)](/assets/images/herdr-terminal-workspace/herdr-file-viewer.svg)

> **설치 전 확인:** Herdr 마켓플레이스는 **비심사(non-curated)** 카탈로그입니다.
> 설치 과정에서 저장소 manifest의 **build step이 실행될 수 있으므로**,
> 설치 전 저장소·`herdr-plugin.toml`·빌드 스크립트를 직접 확인하세요.
> ([Herdr marketplace 문서](https://herdr.dev/docs/marketplace/))

### 요구사항

- Herdr **0.7.0+** (현재 stable은 0.8.x)
- Linux 또는 macOS. **native Windows도 preview로 지원**하며 별도 `-windows` action ID를 사용
- `git`이 없어도 뷰어는 열리지만 **상태 표시·필터·diff 기능이 제한**됨
- prebuilt 바이너리가 없는 플랫폼에서는 **Rust 1.96+로 소스 빌드**가 필요할 수 있음

### 설치

```bash
herdr plugin install smarzban/herdr-file-viewer

# 특정 버전 고정
herdr plugin install smarzban/herdr-file-viewer --ref v1.0.0

# 렌더러 (선택)
brew install glow git-delta bat

# 설치 확인
herdr plugin list
```

업데이트는 자동이 아니므로, 최신 버전을 원하면 `--ref` 없이 install 명령을 다시 실행합니다.

### 여는 방법

`~/.config/herdr/config.toml`에 키를 바인딩합니다.

```toml
[[keys.command]]
key = "prefix+f"
type = "plugin_action"
command = "herdr-file-viewer.open-file-viewer"
description = "파일 뷰어를 분할 패널로 열기"

[[keys.command]]
key = "prefix+shift+f"
type = "plugin_action"
command = "herdr-file-viewer.open-file-viewer-tab"
description = "파일 뷰어를 새 탭으로 열기"
```

```bash
herdr server reload-config
```

키 바인딩 없이 한 번만 띄워 볼 수도 있습니다.

```bash
herdr plugin action invoke open-file-viewer --plugin herdr-file-viewer
```

### 사용 키

| 키 | 동작 |
| --- | --- |
| `f` | 파일 퍼지 검색 |
| `p` | 현재 파일을 비교용으로 고정(pin) |
| `v` | 뷰 전환 (diff ↔ 렌더링 ↔ 구문 강조) |
| `]` / `[` | 다음 / 이전 변경 파일로 이동 |
| `b` | diff 기준(baseline) 토글 |
| `W` | Git 워크트리 전환 |
| `e` | 외부 에디터로 열기 |
| `?` | 도움말 오버레이 |

설정 파일은 아래 경로에 `config.toml`로 복사해서 커스터마이징합니다.

```bash
herdr plugin config-dir herdr-file-viewer
```

Lazygit이 "스테이징·커밋"에 강하다면, herdr-file-viewer는 **"프로젝트 전체를 트리로 훑으며 변경 파일만 골라 빠르게 확인"**하는 용도로 상호 보완됩니다.

---

## 정리

| 레이어 | 도구 | 역할 |
| --- | --- | --- |
| 터미널 | Ghostty | GPU 가속 렌더링 ([2026 세팅](https://blog.dnd.ac/settings-mac-terminal-2026/)) |
| 멀티플렉서 | **Herdr** | 워크스페이스·탭·패널 + 에이전트 상태 추적 + CLI 자동화 |
| 에이전트 | Claude Code / Codex | 코드 작성·리뷰 (패널 분할로 병렬 운영) |
| 수정 | **Helix** | 모달 에디터, `]g`로 변경 지점 탐색 |
| Git | **Lazygit** | 스테이징·헝크 diff·커밋 |
| 탐색 | **herdr-file-viewer** | 트리 + diff/렌더링 뷰어 |

tmux로도 비슷한 레이아웃은 만들 수 있지만, Herdr는 **에이전트 상태를 UI로 보여주고 그 제어 CLI를 에이전트가 직접 쓴다**는 점에서 AI 코딩 워크플로우에 잘 맞습니다.
반대로 상태 판정이 화면 기반이라 완전히 신뢰할 수는 없고, 아직 버전이 빠르게 바뀌므로 설치된 `herdr --help`를 항상 기준으로 삼으세요.

초안 작성 → 다른 패널 에이전트에게 리뷰 → Helix로 반영 → Lazygit으로 커밋까지, 터미널 하나에서 끝납니다.

궁금한 점이 있다면 댓글로 남겨주세요!
