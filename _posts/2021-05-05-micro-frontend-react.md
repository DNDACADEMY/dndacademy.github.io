---
layout: post
title: "Micro-frontend React, 점진적으로 도입하기"
author: Gidong
categories: [React.JS]
tags: [CRA, Micro, Micro-frontend, Create React App]
image: assets/images/micro-frontend-react/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> react build의 긴 시간을 어떻게 줄일 수 있을까?

# React의 build Time

Webpack 기반의 create-react-app(이하 CRA)으로 구성된 환경의 개발을 진행할 경우 여러가지 간편함이 동반되기 때문에 많은 사용이 이루어지고 있다.
여기에 TypeScript를 같이 사용하게 되면 배포를 위한 빌드과정이 20분~45분까지도 걸리는 경우를 종종 볼수가 있다. 아래는 이에 대해서 어떤식의 해결방법이 있는지 같이 알아보는 시간을 가져보고자 한다. ([@토스 개발자 컨퍼런스 SLASH 의 영상을 참고하였습니다.](https://www.youtube.com/watch?v=DHPeeEvDbdo))

## 1. 소스코드를 독립적인 패키지로 분리하고 각각을 빌드

프로젝트를 진행하며 커진 소스코드를 아래의 기준을 통해서 독립적인 패키지로 분리를 시킨다.

- 동일한 빌드 툴링을 공유하기 위한 '인프라 패키지'
- 공통 소스코드를 관리하기 위한 '라이브러리 패키지'
- 페이지에서 독립적으로 작동하는 '서비스 패키지'

독립적인 패키지로 분리가 되면서, 별도로 빌드를 가질 수 있게 되고 개발을 진행하면서도 독립적인 단위의 개발이 가능하다는 장점을 가질 수 있다.

### \* 구현방법

> `yarn 2 workspace plugin`를 사용
>
> 작업 공간은 Yarn1.0 이후에 기본적으로 사용할 수있는 패키지 구조를 설정하기위한 >새로운 방법입니다. 이로 인해 여러 패키지를 설치하여 yarn install을 한 번 >실행하기만 하면 모든 패키지를 동일한 패스로 설치할 수 있습니다.
>
> package.json 파일에 다음을 추가합니다. 해당 디렉토리를 "_workspace >root_"라고합니다.
>
> ```json
> {
>   "private": true,
>   "workspaces": ["workspace-a", "workspace-b"]
> }
> ```
>
> private: true를 반드시 입력해주세요.
> 작업 공간은 공개되는 것을 의도하지 않기 때문에 실수로 공개되지 않도록하기 위해 >추가했습니다.
>
> 이 파일이 생성되면 workspace-a와 workspace-b라는 두 개의 새 하위 폴더를 >만듭니다. 각각 다음의 내용을 다른 package.json 파일을 만듭니다.
>
> workspace-a/package.json:
>
> ```json
> {
>   "name": "workspace-a",
>   "version": "1.0.0",
>
>   "dependencies": {
>     "cross-env": "5.0.5"
>   }
> }
> ```
>
> workspace-b/package.json:
>
> ```json
> {
>   "name": "workspace-b",
>   "version": "1.0.0",
>
>   "dependencies": {
>     "cross-env": "5.0.5",
>     "workspace-a": "1.0.0"
>   }
> }
> ```
>
> 마지막으로, yarn install을 *workspace root*에서 실행합니다. 정상적으로 >작동이 되었다면 다음과 같은 파일 계층이 생성되어있을 것입니다.
>
> ```
> /package.json
> /yarn.lock
>
> /node_modules
> /node_modules/cross-env
> /node_modules/workspace-a -> /workspace-a
>
> /workspace-a/package.json
> /workspace-b/package.json
> ```
>
> NOTE: *workspace-b*에있는 파일에서 *workspace-a*를 요청하면 npm에서 >공개되는 것이 아니라 프로젝트 내에 현재있는 정확한 코드가 사용되게되어, >_cross-env_ 패키지가 올바르게 중복 제거 된 프로젝트의 루트에 배치됩니다. >*workspace-a*와 _workspace-b_ 모두에서 사용할 수 있습니다.

## 2. 소스코드가 바뀐 패키지만 빌드하고 나머지는 기존 빌드 결과물을 재사용

git을 활용하여 이전 커밋의 해시와 현재 커밋의 해시를 비교하여 각각의 패키지가 변경되었는지 여부를 알아내어 바뀐 패키지만 빌드하고 나머지는 기존 빌드 결과물을 재사용

> yarn 2 zero install을 활용할 수 있다.

### yarn 2 zero install

#### 1. Yarn은 프로젝트의 안정성에 어떻게 영향을 미칩니 까?

Yarn은`yarn install`를 두 번 실행하면 두 경우 모두 동일한 결과를 얻을 수 있음을 보장하기 위해 최선을 다하고 있습니다. 이렇게 주요 방법은 잠금 파일을 사용하는 것입니다. 이 잠금 파일에는 프로젝트를 시스템간에 재현 가능한 방식으로 설치하는 데 필요한 모든 정보가 포함되어 있습니다. 그러나 그것으로 충분합니까?

Yarn은 현재 작동하는 것이 계속 작동하는 것을 보장하기 위해 최선을 다하고 있습니다 만, 향후 Yarn 릴리스에서 프로젝트 설치하지 못하는 문제가 발생할 가능성은 항상 있습니다. 또는 프로덕션 환경이 변경되어`yarn install`이 임시 디렉토리에 쓸 수 없게 될 가능성이 있습니다. 또는 네트워크에 장애가 발생하여 패키지를 사용할 수 없게 될 가능성이 있습니다. 또는 인증이 회전하여 인증 문제가 발생 시작할 수 있습니다. 또는 ... 아주 많이 잘못 가능성이 있고, 그들 모두는 우리가 제어 할 수있는 것은 아닙니다.

이러한 과제는 Yarn 고유의 것이 아닌 점에 유의하십시오. 릴리스 중 하나에 도달 한 버그로 인해, npm이 프로덕션 서버를 삭제하고 있던 때의 일을 기억하고 있을지도 모릅니다. 이것은 바로 우리가 의미하는 것입니다. 실행되는 코드는 실패 할 가능성이있는 코드입니다. 그리고 머피의 법칙 덕분에 실패 할 수있는 것은 결국 실패 할 것을 알고 있습니다. 거기에서 이러한 문제를 방지하는 유일한 확실한 방법은 가능한 한 적은 코드를 실행하는것으로 밝혀집니다.

#### "zero install" 사용 방법

프로젝트를 처음 설치하려면, clone 하면 즉시 사용할 수 있어야합니다. 이것을 Yarn2에서 시작하는 것은 매우 간단합니다!

- 캐시 폴더는 기본적으로 프로젝트 폴더 (`.yarn / cache` 내)에 저장됩니다. 반드시 저장소에 추가하십시오 ([오프라인 캐시](https://next.yarnpkg.com/features/offline-cache) 참조).

  - 다시 말하지만,이 워크 플로우는 옵션입니다. 어떤 시점에서 결국 글로벌 캐시를 계속 사용하기로 한 경우 [yarnrc 설정](https://next.yarnpkg.com/configuration/yarnrc/#enableGlobalCache) 에서 `enableGlobalCache`을 선택 바꾸는 것만으로 정상 상태로 돌아갑니다.

- `yarn install`을 실행하면 Yarn은`.pnp.cjs` 파일을 생성합니다. 저장소에 추가합니다. 노드가 패키지를로드하는 데 사용 종속성 트리가 포함되어 있습니다.

- 종속 설치 스크립트가 있는지 여부에 따라 (가능하다면 그것을 피하고 wasm를 이용한 대안을 선호),`.yarn / unplugged` 항목을 추가 할 수 있습니다.

이상입니다! 변경 사항을 저장소에 푸시하고 새로운 저장소를 어딘가에 체크 아웃`yarn start` (또는 일반적으로 사용하는 다른 스크립트)의 실행이 작동하는지 여부를 확인합니다.

#### 우려 사항

##### 보안에 영향이 있나요?

설정은 저장소를 변경하는 사람을 신뢰해야하는 점에 유의하십시오. 특히 외부 사용자의 PR를 받아 프로젝트는 패키지 아카이브에 영향을 미치는 PR가 정당하다는 점에 유의해야합니다 (그렇지 않으면 악의적인 사용자가 파일의 콘텐츠를 변경 한 후 새로운 의존성 의 PR를 보낼 수 있기 때문에). 이렇게 최선의 방법은`--check-cache` 플래그를 사용하는 CI 단계 (신뢰할 수없는 PR의 경우에만)를 추가하는 것입니다.

```
$> yarn install --check-cache
```

이렇게하여 Yarn은 원격 위치에 관계없이 패키지 파일을 다시 다운로드 체크섬 불일치를 보고합니다.
