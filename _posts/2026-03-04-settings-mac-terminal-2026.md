---
layout: post
title: "2026 Mac 터미널 완벽 세팅 (Ghostty + Starship + AI 코딩 환경)"
author: Gidong
categories: [설정]
tags: [terminal, ghostty, zsh, starship, claude-code, ai, mac, environment, cli]
image: assets/images/settings-mac-terminal-2026/logo.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> 2021년에 작성했던 [Mac 터미널 세팅하기 (zsh & iterm)](https://blog.dnd.ac/settings-mac-terminal/) 글의 2026년 버전입니다.
> iTerm2 + Powerlevel9k 조합에서 **Ghostty + Starship + AI 코딩 도구**로 완전히 새롭게 구성했습니다.
> 모든 설정은 복사-붙여넣기만으로 설치할 수 있도록 작성되었습니다.

## 최종 결과물

터미널을 열면 fastfetch가 시스템 정보를 보여주고, Starship의 미니멀한 Catppuccin 프롬프트가 맞이합니다.
`ls`를 입력하면 아이콘과 함께 파일 목록이 표시되고, `cat` 대신 구문 강조가 적용된 `bat`이 실행됩니다.
`cd`를 입력하면 zoxide가 자주 가는 디렉토리를 자동 추천하고, `claude`를 입력하면 AI 코딩 에이전트가 바로 시작됩니다.

![Starship 프롬프트 + lsd 파일 목록](/assets/images/settings-mac-terminal-2026/terminal-prompt.png)

---

## 원클릭 설치 스크립트

아래 스크립트는 이 글에서 사용하는 **주요 패키지를 한 번에 설치하는 초기 세팅 스크립트**입니다.
설치 후에는 Ghostty, Starship, `.zshrc` 설정 파일을 적용하면 동일한 환경을 빠르게 재현할 수 있습니다.

> **주의:** 원격 설치 스크립트를 실행하기 전에는 내용을 한 번 확인하는 것을 권장합니다.
> AI에게 실행을 맡기더라도, 실제 실행 전에는 명령어를 직접 검토하세요.

```bash
#!/bin/bash
set -euo pipefail

echo "🚀 Mac 터미널 기본 패키지 설치를 시작합니다..."

# ============================================
# 1. Homebrew 설치 (없는 경우)
# ============================================
if ! command -v brew &>/dev/null; then
  echo "📦 Homebrew 설치 중..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================
# 2. Ghostty 설치
# ============================================
echo "👻 Ghostty 설치 중..."
brew install --cask ghostty

# ============================================
# 3. 폰트 설치
# ============================================
echo "🔤 폰트 설치 중..."
brew install --cask font-hack-nerd-font
brew install --cask font-noto-sans-cjk-kr

# ============================================
# 4. CLI 도구 설치
# ============================================
echo "🛠️ CLI 도구 설치 중..."
brew install lsd bat fzf fd ripgrep git-delta btop dust duf fastfetch neovim
brew install zoxide lazygit navi starship mise
brew install gemini-cli

# ============================================
# 5. Oh My Zsh 설치
# ============================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "💎 Oh My Zsh 설치 중..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ============================================
# 6. Zinit 설치
# ============================================
if [ ! -d "$HOME/.local/share/zinit/zinit.git" ]; then
  echo "🔌 Zinit 설치 중..."
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

# ============================================
# 7. SCM Breeze 설치
# ============================================
if [ ! -d "$HOME/.scm_breeze" ]; then
  echo "🌿 SCM Breeze 설치 중..."
  git clone https://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
  ~/.scm_breeze/install.sh
fi

# ============================================
# 8. Node.js 설치 (AI 도구용)
# ============================================
echo "📐 mise로 Node.js 설치 중..."
eval "$(mise activate bash)"
mise use --global node@24

# ============================================
# 9. AI 도구 설치
# ============================================
echo "🤖 AI 코딩 도구 설치 중..."

# Claude Code
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Codex CLI
if ! command -v codex &>/dev/null; then
  npm install -g @openai/codex
fi

echo ""
echo "✅ 기본 패키지 설치가 완료되었습니다!"
echo "👉 이제 아래 설정 파일(ghostty, starship, .zshrc)을 적용하세요."
echo "👉 첫 실행 인증: claude / codex / gemini"
```

---

## 상세 설정 가이드

### 1. Ghostty 터미널

[Ghostty](https://ghostty.org)는 Zig로 작성된 GPU 가속 터미널입니다. iTerm2 대비 체감 속도가 확연히 빠르고, 네이티브 macOS 경험을 제공합니다.

#### 설치

```bash
brew install --cask ghostty
```

#### 설정 파일

`~/.config/ghostty/config` 파일을 생성합니다.

> 아래 설정은 `Hack Nerd Font Mono`를 기본 폰트로 사용하고,
> 한글 fallback용으로 `Noto Sans CJK KR`를 추가한 구성입니다.
> 한글 fallback이 필요 없다면 두 번째 `font-family` 줄은 제거해도 됩니다.

```bash
mkdir -p ~/.config/ghostty
cat << 'EOF' > ~/.config/ghostty/config
# Ghostty Configuration - Dark Modern (Catppuccin Mocha)

# Theme
theme = Catppuccin Mocha

# Font
font-family = "Hack Nerd Font Mono"
font-family = "Noto Sans CJK KR"

# Window
window-padding-x = 12
window-padding-y = 10
window-decoration = true
macos-titlebar-style = tabs

# Background (반투명 + 블러)
background-opacity = 0.9
background-blur-radius = 20

# Autosuggestion color (가독성을 위해 밝게)
palette = 8=#7f849c

# Cursor
cursor-style = block
cursor-style-blink = false

# Mouse
mouse-hide-while-typing = true

# Clipboard
copy-on-select = true
clipboard-paste-protection = false

# Scrollback
scrollback-limit = 10000

# macOS
macos-option-as-alt = true

# Shell Integration
shell-integration = zsh
shell-integration-features = cursor,sudo,title

# Keybindings - Split/Tab
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down
keybind = cmd+w=close_surface
keybind = cmd+alt+left=goto_split:left
keybind = cmd+alt+right=goto_split:right
keybind = cmd+alt+up=goto_split:top
keybind = cmd+alt+down=goto_split:bottom
EOF
```

**핵심 설정 설명:**

| 설정                          | 설명                                |
| ----------------------------- | ----------------------------------- |
| `theme = Catppuccin Mocha`    | 부드러운 다크 테마 (눈의 피로 감소) |
| `background-opacity = 0.9`    | 10% 투명도로 배경이 살짝 비침       |
| `background-blur-radius = 20` | 투명 배경에 블러 효과               |
| `macos-titlebar-style = tabs` | macOS 네이티브 탭 스타일            |
| `macos-option-as-alt = true`  | Option 키를 Alt로 사용              |
| `cmd+d` / `cmd+shift+d`       | 화면 수직/수평 분할                 |

---

### 2. Zsh + Oh My Zsh + Starship

기존 Powerlevel9k/10k에서 **[Starship](https://starship.rs)**으로 교체했습니다. Rust로 작성되어 빠르고, `~/.config/starship.toml` 하나로 설정을 관리합니다.

#### 설치

```bash
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Starship
brew install starship
```

#### .zshrc에 추가

Oh My Zsh의 `ZSH_THEME`를 비워두고, Starship을 oh-my-zsh 이후에 로드합니다.

```bash
# oh-my-zsh 설정
ZSH_THEME=""    # Starship이 프롬프트를 관리하므로 비워둠
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# Starship 프롬프트 (oh-my-zsh 이후에 로드해야 테마가 덮어쓰이지 않음)
eval "$(starship init zsh)"
```

#### Starship 설정 (`~/.config/starship.toml`)

미니멀하게 **디렉토리 + Git + 실행 시간**만 표시하고, Catppuccin Mocha 팔레트로 통일했습니다.
Powerline 스타일의 구분자를 사용한 1줄 프롬프트입니다.

```bash
mkdir -p ~/.config
cat << 'EOF' > ~/.config/starship.toml
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](mauve)\
$directory\
[](fg:mauve bg:blue)\
$git_branch\
$git_status\
[](fg:blue) \
$cmd_duration\
$character"""

palette = 'catppuccin_mocha'

[directory]
style = "bg:mauve fg:crust"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = " "
style = "bg:blue"
format = '[[ $symbol$branch ](fg:crust bg:blue)]($style)'

[git_status]
style = "bg:blue"
format = '[[($all_status$ahead_behind )](fg:crust bg:blue)]($style)'

[line_break]
disabled = true

[character]
success_symbol = '[❯](bold fg:green)'
error_symbol = '[❯](bold fg:red)'

[cmd_duration]
min_time = 2_000
format = "[ 󱎫 $duration](fg:overlay1) "

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
mauve = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"
EOF
```

**프롬프트 구성:**

```
 디렉토리  Git브랜치 상태  실행시간 ❯ _
```

- `mauve`(보라) 배경에 디렉토리 경로
- `blue`(파랑) 배경에 Git 브랜치 + 상태
- 2초 이상 걸린 명령어만 실행 시간 표시
- `❯` 커서 (성공: 초록, 실패: 빨강)

#### 다른 프리셋으로 시작하기

더 많은 정보를 표시하고 싶다면 빌트인 프리셋을 적용한 후 커스터마이징하세요.

```bash
# 예: Catppuccin Powerline (풀 프리셋)
starship preset catppuccin-powerline -o ~/.config/starship.toml

# 예: Tokyo Night
starship preset tokyo-night -o ~/.config/starship.toml
```

---

### 3. Zinit 플러그인 매니저 + 필수 플러그인

oh-my-zsh의 기본 플러그인 시스템 대신 **Zinit**을 사용합니다. 병렬 로딩으로 쉘 시작 속도가 빠릅니다.

#### 설치

```bash
mkdir -p "$HOME/.local/share/zinit"
git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
```

#### .zshrc에 추가

```bash
# Zinit 로드
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# 필수 플러그인 3종
zinit light zdharma-continuum/fast-syntax-highlighting    # 명령어 구문 강조
zinit light zsh-users/zsh-autosuggestions                  # 히스토리 기반 자동 완성
zinit light zsh-users/zsh-completions                      # 추가 자동 완성 정의
```

**플러그인 역할:**

| 플러그인                   | 효과                                                      |
| -------------------------- | --------------------------------------------------------- |
| `fast-syntax-highlighting` | 올바른 명령어는 초록, 잘못된 명령어는 빨강으로 표시       |
| `zsh-autosuggestions`      | 이전 히스토리를 기반으로 회색 텍스트로 제안 (→ 키로 적용) |
| `zsh-completions`          | docker, npm, brew 등 수백 개 도구의 자동 완성             |

---

### 4. 모던 CLI 도구 (기본 명령어 업그레이드)

기존 Unix 명령어를 더 빠르고, 더 보기 좋은 Rust/Go 기반 도구로 교체합니다.

#### 한 번에 설치

```bash
brew install lsd bat fzf fd ripgrep git-delta btop dust duf fastfetch neovim
brew install zoxide lazygit navi
```

> 위 명령은 **이 섹션에서 소개하는 모던 CLI 도구만** 설치합니다.
> `starship`, `mise`, `gemini-cli`는 각각 뒤 섹션에서 별도로 설치합니다.

#### .zshrc 별칭 설정

```bash
# ============================================
# 모던 CLI 별칭
# ============================================
alias ls="lsd"
alias ll="lsd -la"
alias lt="lsd --tree"
alias cat="bat"
alias find="fd"
alias grep="rg"
alias top="btop"
alias df="duf"
alias du="dust"
alias vim="nvim"
alias vi="nvim"

# 빠른 접근
alias lg="lazygit"      # Git TUI
alias c="clear"
alias ..="cd .."
alias ...="cd ../.."
```

> **참고:** `fd`, `rg`, `bat`은 기존 `find`, `grep`, `cat`과 사용 방식이 완전히 같지는 않습니다.
> 기존 Unix 명령어 문법에 익숙하다면 별칭 대신 별도 명령으로 먼저 적응한 뒤 바꾸는 것을 추천합니다.

#### 각 도구 소개

| 기존 명령어 | 대체 도구                                             | 특징                                                   |
| ----------- | ----------------------------------------------------- | ------------------------------------------------------ |
| `ls`        | [lsd](https://github.com/lsd-rs/lsd)                  | 파일 아이콘, 컬러, Git 상태 표시                       |
| `cat`       | [bat](https://github.com/sharkdp/bat)                 | 구문 강조, 줄 번호, Git diff 표시 (아래 스크린샷 참고) |
| `find`      | [fd](https://github.com/sharkdp/fd)                   | 직관적 문법, `.gitignore` 자동 적용                    |
| `grep`      | [ripgrep (rg)](https://github.com/BurntSushi/ripgrep) | 초고속 정규식 검색                                     |
| `cd`        | [zoxide](https://github.com/ajeetdsouza/zoxide)       | 자주 가는 디렉토리 자동 추천 (`z` 명령어)              |
| `diff`      | [delta](https://github.com/dandavison/delta)          | Git diff를 구문 강조 + side-by-side로 표시             |
| `top`       | [btop](https://github.com/aristocratos/btop)          | 그래프 기반 시스템 모니터                              |
| `du`        | [dust](https://github.com/bootandy/dust)              | 디스크 사용량 트리 시각화                              |
| `df`        | [duf](https://github.com/muesli/duf)                  | 디스크 정보를 테이블로 표시                            |
| git UI      | [lazygit](https://github.com/jesseduffield/lazygit)   | 터미널 기반 Git GUI                                    |
| 치트시트    | [navi](https://github.com/denisidoro/navi)            | `Ctrl+G`로 명령어 치트시트 검색                        |

![bat 구문 강조 예시](/assets/images/settings-mac-terminal-2026/terminal-bat.png)

#### fzf + zoxide + navi 연동

```bash
# fzf (퍼지 검색) - Ctrl+R로 히스토리 검색, Ctrl+T로 파일 검색
source <(fzf --zsh)

# zoxide (스마트 cd) - cd 명령어를 zoxide로 대체
eval "$(zoxide init --cmd cd zsh)"

# navi (치트시트) - Ctrl+G로 명령어 검색
eval "$(navi widget zsh)"
```

#### Git Delta 설정

`~/.gitconfig`에 추가하면 `git diff`, `git log` 등이 자동으로 delta를 사용합니다.

```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
```

#### Fastfetch (터미널 시작 시 시스템 정보)

![Fastfetch 시스템 정보 표시](/assets/images/settings-mac-terminal-2026/terminal-fastfetch.png)

`.zshrc` 최상단에 추가합니다.

```bash
# .zshrc 최상단에 추가
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi
```

터미널을 열 때마다 OS, 호스트, 커널, 업타임, 패키지 수 등의 시스템 정보가 표시됩니다.

---

### 5. SCM Breeze (Git 단축키)

[SCM Breeze](https://github.com/scmbreeze/scm_breeze)는 `git status` 결과에 번호를 매겨서 파일을 숫자로 선택할 수 있게 해줍니다.

```bash
git clone https://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
~/.scm_breeze/install.sh
source ~/.scm_breeze/scm_breeze.sh
```

`install.sh`는 기본 설정 파일을 생성하고 `.zshrc` 또는 `.bashrc`에 SCM Breeze 로드 구문을 추가합니다.
다만 Claude Code 환경에서는 그 자동 추가 줄 대신 아래의 **조건부 로드 방식**으로 바꾸는 것을 추천합니다.

**사용 예시:**

```bash
$ gs              # git status (파일에 번호 부여)
# ➤ [1] modified: src/app.ts
# ➤ [2] modified: src/utils.ts

$ ga 1            # git add src/app.ts (번호로 스테이징)
$ gd 2            # git diff src/utils.ts
```

> **참고:** Claude Code 환경에서는 SCM Breeze가 쉘 스냅샷과 충돌할 수 있어 조건부로 로드합니다.

```bash
# Claude Code 환경에서는 SCM Breeze 제외
if [[ -z "$CLAUDECODE" ]]; then
  [ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"
fi
```

---

### 6. mise (런타임 버전 관리자)

nvm, pyenv, rbenv 등을 **mise 하나로 통합**합니다.
프로젝트별 설정 파일로 Node, Python, Go 등의 버전을 관리할 수 있습니다.

```bash
# 설치
brew install mise

# .zshrc 맨 아래에 추가
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Node.js 설치 예시
mise use --global node@24
```

`.mise.toml` 예시:

```toml
[tools]
node = "24.9.0"
```

---

### 7. AI 코딩 도구 세팅

2026년 터미널 환경에서 가장 큰 변화 중 하나는 **AI 코딩 에이전트가 일상적인 개발 도구가 되었다는 점**입니다.
터미널에서 바로 AI와 함께 코딩할 수 있습니다.

#### Claude Code

![Claude Code AI 코딩 에이전트](/assets/images/settings-mac-terminal-2026/terminal-claude.png)

[Claude Code](https://code.claude.com/docs/ko/overview)는 Anthropic의 공식 CLI 코딩 에이전트입니다.

```bash
# 설치
curl -fsSL https://claude.ai/install.sh | bash

# 실행
claude
```

**oh-my-claudecode (OMC) 플러그인:**

Claude Code에 멀티 에이전트 오케스트레이션 워크플로우를 추가해 주는 플러그인입니다.
autopilot, team, ultrawork 같은 실행 모드를 통해 여러 작업을 체계적으로 분배할 수 있습니다.

```bash
# Claude Code 실행 후 아래 명령어 입력
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
```

Claude Code의 알림 설정 예시(`~/.claude/settings.json`):

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff &"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Ping.aiff &"
          }
        ]
      }
    ]
  }
}
```

- **Stop Hook**: 작업이 끝나면 효과음 재생
- **Notification Hook**: 확인이 필요한 상황에 효과음 재생

**headless 빌드 검증 별칭:**

Claude Code를 비대화형으로 실행하여 빌드 검증을 자동화할 수 있습니다.

```bash
# .zshrc에 추가
alias cc-check="claude -p 'Run tsc --noEmit, then eslint, then run all unit tests. Report any failures with file paths and line numbers.' --allowedTools 'Bash,Read,Grep' --output-format json > build-report.json && echo '✅ build-report.json 생성 완료'"
```

#### Codex CLI (OpenAI)

```bash
npm install -g @openai/codex
```

#### Gemini CLI (Google)

```bash
brew install gemini-cli
```

#### 첫 실행 인증

설치만으로 바로 사용할 수 있는 것은 아니고, 각 도구는 첫 실행 시 로그인 또는 API 키 설정이 필요합니다.

**Claude Code**

```bash
claude
```

**Codex CLI**

```bash
codex
# 또는
codex login
```

**Gemini CLI**

```bash
gemini
```

개인 사용자는 Claude/Google/OpenAI 계정 로그인 흐름으로 시작하는 것이 가장 간단합니다.

#### 세 AI를 함께 사용하기

oh-my-claudecode의 워크플로우를 활용하면 Claude + Codex + Gemini를 함께 운영할 수 있습니다.
예를 들어 백엔드 작업은 Codex에, 프론트엔드 작업은 Gemini에 분배한 뒤 Claude가 결과를 통합하는 식으로 사용할 수 있습니다.

---

### 8. 도구 런처 (`tools` 함수)

fzf를 활용한 커스텀 도구 런처입니다. 터미널에 `tools`를 입력하면 설치된 도구들을 퍼지 검색으로 선택하여 실행할 수 있습니다.

```bash
# .zshrc에 추가
function tools() {
  local cmds=(
    "btop:🖥️  시스템 모니터링"
    "lazygit:📦 Git UI"
    "duf:💾 디스크 사용량"
    "dust:📁 폴더 크기 분석"
    "fastfetch:ℹ️  시스템 정보"
  )
  local selected=$(printf '%s\n' "${cmds[@]}" | fzf --delimiter=: --with-nth=2 --height=40% --reverse --border --prompt="도구 선택: ")
  local cmd="${selected%%:*}"
  [[ -n "$cmd" ]] && eval "$cmd"
}
```

---

### 9. 기본형 .zshrc 예시

모든 설정을 통합한 **기본형** `.zshrc` 레퍼런스입니다.
본인의 기존 `.zshrc`에 맞게 필요한 부분만 참고하여 수정하세요.

```bash
# ============================================
# 2026 Mac Terminal Configuration
# ============================================

# Fastfetch (인터랙티브 셸에서만)
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# Starship 프롬프트
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ============================================
# Zinit 플러그인 매니저
# ============================================
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  command mkdir -p "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# ============================================
# SCM Breeze (Git 단축키)
# ============================================
if [[ -z "$CLAUDECODE" ]]; then
  [ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"
fi

# ============================================
# 모던 CLI 별칭
# ============================================
alias ls="lsd"
alias ll="lsd -la"
alias lt="lsd --tree"
alias cat="bat"
alias find="fd"
alias grep="rg"
alias top="btop"
alias df="duf"
alias du="dust"
alias vim="nvim"
alias vi="nvim"
alias lg="lazygit"
alias c="clear"
alias ..="cd .."
alias ...="cd ../.."

# ============================================
# fzf + zoxide + navi
# ============================================
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

if command -v navi &>/dev/null; then
  eval "$(navi widget zsh)"
fi

# ============================================
# mise (런타임 버전 관리자)
# ============================================
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ============================================
# 도구 런처
# ============================================
function tools() {
  local cmds=(
    "btop:🖥️  시스템 모니터링"
    "lazygit:📦 Git UI"
    "duf:💾 디스크 사용량"
    "dust:📁 폴더 크기 분석"
    "fastfetch:ℹ️  시스템 정보"
  )
  local selected=$(printf '%s\n' "${cmds[@]}" | fzf --delimiter=: --with-nth=2 --height=40% --reverse --border --prompt="도구 선택: ")
  local cmd="${selected%%:*}"
  [[ -n "$cmd" ]] && eval "$cmd"
}
```

> **Tip:** 새로 세팅하는 경우 위 내용을 기준으로 시작하면 됩니다.
> 기존 설정이 있다면 `cp ~/.zshrc ~/.zshrc.backup`으로 백업 후 필요한 블록만 추가하세요.

---

## 이전 세팅과의 비교

| 항목          | 2021년       | 2026년                               |
| ------------- | ------------ | ------------------------------------ |
| 터미널        | iTerm2       | **Ghostty** (GPU 가속, 네이티브)     |
| 프롬프트      | Powerlevel9k | **Starship** (Rust 기반, 미니멀)     |
| 컬러 스킴     | Brogrammer   | **Catppuccin Mocha**                 |
| ls 도구       | logo-ls      | **lsd** (Rust 기반)                  |
| 플러그인 관리 | 수동 설치    | **Zinit** (병렬 로딩)                |
| 버전 관리     | nvm          | **mise** (통합 관리)                 |
| AI 도구       | 없음         | **Claude Code + Codex + Gemini**     |
| cat 대체      | 없음         | **bat** (구문 강조)                  |
| diff 뷰어     | 기본 diff    | **delta** (side-by-side)             |
| cd 도구       | 기본 cd      | **zoxide** (스마트 이동)             |
| 검색          | 기본 grep    | **ripgrep + fzf** (초고속 퍼지 검색) |
| Git UI        | 없음         | **lazygit** (터미널 Git GUI)         |
| 치트시트      | 없음         | **navi** (Ctrl+G 검색)               |

---

## 마무리하며

2021년에는 "아름다운 터미널"을 목표로 했다면, 2026년에는 **"AI와 함께 일하는 생산적인 터미널"**이 핵심입니다.

Ghostty의 빠른 렌더링 위에 Starship의 미니멀한 프롬프트,
모던 CLI 도구들의 향상된 가독성,
그리고 Claude Code를 비롯한 AI 에이전트가 합쳐져
터미널이 단순한 명령어 입력 도구를 넘어 **AI 코딩 워크스테이션**에 가까워졌습니다.

이 글의 스크립트로 기본 패키지를 설치한 뒤,
Ghostty / Starship / `.zshrc` 설정까지 적용하면 새 Mac에서도 비교적 빠르게 같은 환경을 재현할 수 있습니다.

AI에게 설치 과정을 보조하게 할 수는 있지만,
실제 명령 실행 전에는 스크립트 내용을 직접 검토하는 것을 권장합니다.

궁금한 점이 있다면 댓글로 남겨주세요!
