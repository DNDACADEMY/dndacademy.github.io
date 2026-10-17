# Orca 원격 사용과 Tailscale — 공식 출처 검증 메모

확인일: 2026-10-17 (Asia/Seoul). 실제 장치 설정·원격 접속은 실행하지 않았다. 아래는 공식 문서에서 확인한 사실과 문서 작성 시의 해석을 분리한 조사 기록이다.

## 핵심: Tailscale은 연결 경로, Orca는 런타임 접근 권한

[Orca Remote Servers](https://www.onorca.dev/docs/remote-servers): 공식 권장 경로는 양쪽 PC의 Orca 데스크톱 앱 + 같은 Tailscale tailnet이다. 서버는 깨어 있고 온라인이며 Orca가 실행 중이어야 한다. 설정에서 서버의 Tailscale 주소를 선택해 access link를 생성하고, 클라이언트의 Settings → Remote Orca Servers → Add Server에 붙인다. 이 경로에서는 `orca serve`가 필요 없다. Remote Orca Servers는 **beta**다.

같은 문서의 보안 절: pairing URL은 비밀번호처럼 취급한다. 페어링한 클라이언트마다 취소 가능한 별도 토큰이 생기며 Shared Server Access에서 취소하면 해당 연결도 즉시 끊긴다. 새 링크 생성은 아직 사용하지 않은 이전 링크를 대체한다. Orca 포트를 공용 인터넷에 직접 포워딩하지 말고 사설 경로를 사용한다.

문서 작성 해석: tailnet에 가입했다고 Orca 페어링이 생기지는 않는다. 반대로 pairing URL만으로 네트워크 경로가 만들어지지도 않는다. 연결 경로와 Orca 접근 토큰을 각각 준비해야 한다.

## 일반 SSH와 Tailscale SSH는 구별해야 한다

[Protect your SSH servers using Tailscale](https://tailscale.com/docs/reference/ssh-over-tailscale): 기존 SSH 서버·클라이언트를 그대로 두고 Tailscale IP 또는 MagicDNS 이름으로 접속할 수 있다. 예: `ssh username@100.100.123.123`. 기존 SSH 인증·설정은 별도로 필요하다.

[Tailscale SSH](https://tailscale.com/docs/features/tailscale-ssh): Tailscale이 SSH 인증·권한을 관리하는 별도 기능이다. 목적지에서 기능을 켜고 네트워크 허용 규칙과 SSH 정책을 모두 준비해야 한다. 서버 지원은 Linux와 macOS의 오픈소스 `tailscale` + `tailscaled` 변형이다. macOS GUI 배포판을 설치했다고 Tailscale SSH 서버까지 지원한다고 쓰면 틀린다. 접속하는 클라이언트는 Tailscale을 실행하는 모든 플랫폼이 가능하다.

문서 작성 해석: Orca Remote Server의 추천 시작 경로에 SSH 설정을 필수 단계로 넣지 않는다. SSH worktree 또는 서버 운영 쉘 접속이 필요할 때만 별도 설명한다.

## Serve와 Funnel

[Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve)는 tailnet 내부의 로컬 서비스 공유, [Tailscale Funnel](https://tailscale.com/docs/features/tailscale-funnel)은 Tailscale 미설치 사용자를 포함한 공용 인터넷 공유다. Serve에도 tailnet 접근 규칙이 적용된다.

문서 작성 해석: 둘은 `orca serve`와 다른 명령이다. 공식 Orca 추천 구성은 Tailscale 주소로 직접 페어링하므로 Tailscale Serve/Funnel은 필수 도구가 아니다. Funnel로 Orca 제어 포트를 공개하는 예제는 제공하지 않는다. HTTPS가 있다는 사실과 사설 접근 제한은 별개다.

## 최소 권한

[Tailscale Grants](https://tailscale.com/docs/features/access-control/grants): `src`, `dst`, `ip`로 출발 사용자·장치, 목적지, 허용 프로토콜·포트를 지정할 수 있다. 예를 들어 `"ip": ["tcp:6768"]`은 TCP 6768에 한정한다. Grants는 deny-by-default 원칙을 따른다.

[Grants syntax](https://tailscale.com/docs/reference/syntax/grants): 일치하는 여러 grant는 허용 권한의 합집합을 적용하고, 더 구체적인 grant가 넓은 grant를 덮어쓰지 않는다. 실제 정책을 먼저 확인한다. 개별 좁은 허용 규칙을 추가해도 기존의 넓은 허용 규칙이 사라지지는 않는다는 점을 설명해야 한다. 정책 조각을 전체 정책 대체용으로 복사하게 만들지 않는다.

문서 작성 해석: 예시 포트 6768을 모든 Orca 데스크톱 서버의 고정 기본값이라고 단정하면 안 된다. 실제 endpoint·포트를 확인하거나 headless 실행에 `--port 6768`을 명시한 경우에만 해당 정책 예시를 적용한다. Tailscale 정책의 네트워크 권한이 Orca 안의 세밀한 읽기/쓰기 역할까지 자동 제공한다고 주장하지 않는다.

## 연결 품질과 진단

[Connection types](https://tailscale.com/docs/reference/connection-types): 연결은 DERP 중계로 시작해 직접 연결을 시도하며, 불가능하면 peer relay 또는 DERP를 사용한다. UDP 차단·복잡한 NAT는 직접 연결을 방해한다. 중계 연결도 사용 가능하므로 `relay` 표시는 곧 실패가 아니다. 일반적으로 직접 연결보다 지연·처리량에 불리하다.

[Tailscale CLI](https://tailscale.com/docs/reference/tailscale-cli): 다음은 읽기 전용 진단 예시다.

```bash
tailscale status
tailscale ip -4
tailscale ping <server-tailscale-ip-or-name>
tailscale netcheck
```

`status`의 `direct`, `relay`, `peer-relay`로 경로를 본다. `netcheck`는 UDP·NAT·DERP 지연 등 현재 물리 네트워크 진단에 쓰인다. 문서 작성 해석: `tailscale ping` 성공만으로 Orca 앱 포트·페어링·프로토콜 호환까지 검증했다고 쓰지 않는다. 그 다음 Orca의 Connected 상태와 실제 터미널 동작을 확인한다.

## 확인 범위의 한계

이 기록은 현재 공식 문서의 내용 검증이다. 사용자의 Orca/Tailscale 설치 버전, OS 변형, ACL/grants, 방화벽과 실제 장치 연결은 조사하지 않았다. Orca와 Tailscale의 UI·CLI는 갱신될 수 있으므로 게시물에는 확인일과 공식 링크를 둔다.

## 로컬 CLI 대조와 게시물 검증

부모 에이전트가 macOS에 설치된 Orca 1.4.224에서 `orca --version`, `orca --help`, `orca serve --help`, `orca environment add --help`, `orca terminal send --help`, `orca skills get orca-cli --json`을 읽었다. 페어링 링크 생성이나 원격 명령 전송은 실행하지 않았다.

- `--environment`와 `environment add --name ... --pairing-code ...`가 도움말에 존재한다.
- `--pairing-address`는 advertised address만 바꾸며 bind 제한 옵션이 아니다.
- 번들 스킬은 `wait.satisfied`, 입력 수락과 턴 시작의 구분, runtime-scoped terminal handle 재조회, 중복 전송 방지를 명시한다.
- 최신 웹 reference의 `serve service install/status/uninstall`은 설치된 1.4.224의 `serve --help`에 없다. 게시글은 최신 문서와 로컬 버전의 차이를 명시하고, 이 명령들의 실동작을 확인했다고 주장하지 않는다.

추가로 읽은 Orca 공식 문서: [소개](https://www.onorca.dev/docs), [설치](https://www.onorca.dev/docs/install), [첫 세션](https://www.onorca.dev/docs/first-session), [Worktrees](https://www.onorca.dev/docs/model/worktrees), [실행 방식](https://www.onorca.dev/docs/ways-to-run), [SSH](https://www.onorca.dev/docs/ssh), [CLI](https://www.onorca.dev/docs/cli/reference), [Mobile](https://www.onorca.dev/docs/mobile), [Session restore](https://www.onorca.dev/docs/model/session-restore), [Diff viewer](https://www.onorca.dev/docs/review/diff-viewer), [Browser](https://www.onorca.dev/docs/browser/overview), [Design Mode](https://www.onorca.dev/docs/browser/design-mode). Design Mode는 조사했지만 본문 범위를 줄이기 위해 상세 사용법을 포함하지 않았다.

독립 검토에서 GUI 공유와 serve의 중복 실행 방지, 모바일 직접 페어링의 Tailscale 주소 선택을 보완했다. 이미지 3장은 실제 스크린샷이 아닌 직접 작성한 SVG 구조도다.

## 사용자 제공 설정 화면 반영

사용자가 제공한 원격 Orca 서버 설정 스크린샷에서 호스트에 연결 / 이 호스트 공유 / 클라우드 VM 탭, 서버 카드의 연결됨·macOS·호환됨·Orca v1.4.225·최신 상태, Server updates·연결 해제·휴지통, 고급 접기를 직접 확인했다. 이미지 원본을 게시물 자산으로 복사하고 한글 UI 기준 안내를 추가했다. 버전은 첨부 화면의 관찰값이며 로컬 CLI 1.4.224 또는 현재 최신 버전과 동일하다고 주장하지 않는다. 업데이트·연결 해제·삭제 버튼은 실행하지 않았다.
