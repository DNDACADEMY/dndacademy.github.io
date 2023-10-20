---
layout: post
title: "[React] 폴더구조 정의"
author: 이재왕
categories: [React.JS]
tags: [React, Folder Structure, Next.JS]
image: assets/images/react-folder-structure/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---
# [React] 폴더구조 정의

<aside>
💡 개요: 리액트는 폴더구조나 코드 스타일을 강제화하지 않는다. 그렇다면 어떻게 폴더구조를 정의해야 유지보수에 유리하고 팀의 크기가 커질때 새로운 팀원의 프로젝트 이해를 위한 비용을 최소화 할 수 있을까?

</aside>

# 1. 리액트는 어떠한 것도 강제하지 않는다.

[리액트의 공식홈페이지](https://ko.legacy.reactjs.org/)는 "사용자 인터페이스를 만들기 위한 JavaScript 라이브러리” ****로 정의하고 있습니다. 다른말로 표현하자면 **리액트는 사용해도되고 안해도되며 어떠한 강제사항도 없습니다.** 리액트의 핵심이라고 할 수 있는 JSX 확장자 또한 필수가 아닙니다.

일반적으로 생각하는 JSX 를 이용한 페이지 구현은 아래와 같습니다.

```tsx
// home.tsx
export function HomePage(): ReactElement {
  return <h1>안녕 HomePage에 온 걸 환영해</h1>;
}
```

하지만, JSX 문법을 사용하지않고도 아래와 같은 문법을 통해 같은 페이지를 만들 수 있습니다.

```tsx
// home.ts
export function Welcome(): ReactElement {
  return React.createElement('h1', null, '안녕 HomePage에 온 걸 환영해');
}
```

리액트는 JSX 사용과 Hooks 사용 등 권장사항들은 존재하지만 권장사항 또한 강제하지 없으며, 폴더구조 또한 마찬가지입니다.

# 2. 일반적인 폴더구조의 문제점은 무엇일까?

```
apis (API 호출 함수)
components (컴포넌트; Atomic Design 기반)
-- atoms
-- molecules
-- organisms
configs (설정 번수 관리)
hooks (custom hooks)
layouts (레이아웃)
-- base
-- auth
pages (페이지)
store (전역상태 관리)
styles (css 스타일)
utils (유틸리티 함수)
```

일반적인 리액트기반 프로젝트의 폴더구조는 위와 같습니다. 폴더명을 통해 해당폴더에 어떤 함수들이 어떤목적을 가지고 존재하는지 직관적으로 알 수 있습니다. 예를들어, atomic design을 이해하고 있다면 typography 나 button 같은 컴포넌트들은 components > atoms 폴더에 존재한다고 유추할 수 있습니다.

하지만, 이런 폴더구조는 핵심적인 비즈니스 로직을 담고있는 **고수준 영역과 비즈니스로직을 서포트 하기위한 기술적인 부분을 포함하는 저수준 영역을 구분하는 전통적인 좋은설계원칙에서 벗어납니다.**

기술적인 부분이 변경되더라도 핵심 비즈니스로직에 영향을 주지않을려면 고수준 영역과 저수준 영역을 분리하는 것이 중요한데, **리액트의 경우 하나의 컴포넌트안에 핵심적인 로직과 기술적인 부분이 함께 존재**하다보니 영역을 분리하는 것이 쉽지 않습니다.

# 3. 순수 자바스크립트 코드와  React 관련 코드를 분리하는 것은 가능하다.

리액트는 컴포넌트 중심의 패러다임을 기본으로해서 기능과 화면이 모두 컴포넌트 내에 존재하는 방식으로 개발되었기 때문에 비즈니스로직과 presentation 부분을 분리하는 것이 오히려 리액트가 추구하는 Component-Centric 방식에서 벗어날 수 있습니다.

또, 기술적인 부분도 정확히 분리되기 어려운게 **리액트에서 사용되는 패키지들은 비즈니스로직과 해당 라이브러리가 함께 사용되게 설계된** 경우가 많습니다. 예를들어 서버상태 관리를 위해 react-query 를 사용한다면 아래와 같이 기술적인 라이브러리와 비즈니스 로직이 하나의 hooks 안에서 처리되어야 합니다.

```tsx
export function useOrder() {
  const { mutateAsync } = useMutation();

  const order = () => {
    const res = await mutateAsync();
    if (res) {
      toast('주문 성공');
    }
  }

  return { order }
}
```

따라서, 아래와같이 3개의 레이어로 나눈다면

| 레이어 이름 | 역할 | 영역구분 |
| --- | --- | --- |
| presentation | 사용자에게 보여줄 화면을 담음 | 저수준 |
| application | 핵심 비즈니스 로직을 담음 | 고수준 |
| infrastructure | 비즈니스로직을 서포트 하기위한 기술을 담음 | 저수준 |

리액트에서는 컴포넌트 중심이라는 특성으로인해 presentation과 application을 분리하는 것도 모호하고, 리액트 라이브러리의 특성으로인해 application과 infrastructure 을 분리하는 것도 모호합니다.

하지만, 위에서 언급한 문제들은 대부분 리액트의 성질로 인해 발생하는 문제이기 때문에 **리액트와 관련없이 사용될 수 있는 코드를 분리하는 것은 가능**합니다. 또한, 순수한 자바스크립트 함수를 다루는 부분과 React 와 관련된 코드를 분리하는 것만으로도 많은 이점을 가져올 수 있습니다. 각 부분의 예시를 들면 아래와 같습니다.

| 구분 | 예시 상황 | 예시 라이브러리 |
| --- | --- | --- |
| 순수한 자바스크립트 함수 | - API 호출 - 저장소 접근 - 자바스크립트 유틸리티 | - axios

- localforage

- lodash |
| React 활용 함수 | - Custom Hooks - 전역상태 관리 - 서버상테 관리 | - react-query

- recoil |

생각해보면 리액트 기반으로 웹어플리케이션을 제작할때 react-toastify 나 react-query 처럼 리액트를 타겟으로 사용하는 라이브러리도 있지만, 리액트와 관련없는 라이브러리나 코드도 많습니다. 이런 함수들을 분리한다면 위에서 언급한 3개의 레이어를 아래와 같이 재정의 할 수 있습니다.

| 레이어 이름 | 역할 | 영역구분 |
| --- | --- | --- |
| presentation | 핵심비즈니스로직과 사용자에게 보여줄 화면을 담음 | 고수준 |
| application | 리액트와 관련된 기술과 핵심비즈니스로직을 담음 | 고수준 |
| infrastructure | 리액트와 관련이 없는 기술들을 담음 | 저수준 |

새로워진 레이어분리는 **infrastructure 를 리액트와 관련없이 순수자바스크립트만으로도 구현가능한 기술**들을 담는 레이어로 보고, presentation와 application사이에는 여전히 모호성이 존재하기 때문에 둘다 고수준 레이어로 봅니다. 이렇게만 하더라도 아래의 장점들을 취할 수 있습니다.

```
1. 재사용성: 리액트를 사용하다가 다른 인터페이스 라이브러리를 사용하거나 완전히 다른 프레임워크를 사용할때도 그대로 사용할 수 있습니다.

2. TDD: 리액트의 특성을 고려할 필요없이 테스트코드 작성이 가능하고, infrastructure 레이어를 mocking 하면 실제 api 호출이나 스토리지 사용없이 웹어플리케이션을 테스트 할 수 있습니다.

3. 변경가능성 감소: 사용 라이브러리가 변경되거나 기술로직이 변경될때 핵심 로직이 존재하는 고수준 레이어를 건드리지 않고 저수준레이어에서 해당 부분만 바꾸면 됩니다.

4. 가독성: 어떤 팀원이 합류하더라도 리액트와 관련된 코드와 관련없는 코드가 어디에 존재하는지 직관적으로 알 수 있습니다.

```

프레임워크에 종속되지 않기때문에 변경가능성을 낮추고 재사용성을 높이는 것이 가능합니다.

# 4. 모호성이 있음에도 application 레이어는 로직에 집중해야한다.

presentation 레이어와 application이 모호성이 존재하고 둘다 고수준 레이어로 볼 수 밖에 없다고 하더라도 2개 레이어를 구분해서 application은 로직, presentation은 화면표시에 집중할 수 있게 하는 것이 중요합니다.

**로직과 화면표시를 구분했을때와 안했을때는 테스트케이스 작성시 큰 차이를 보입니다.** 예를들어 소셜미디어 서비스의 좋아요 기능에 대한 테스트코드를 작성한다고 가정해보겠습니다.

## (1) application/presentation 구분이 없을때

```tsx

// presentation/LikeButton.tsx
export function LikeButton(): JSX.Element {
  const [liked, setLiked] = useState(false);

  const onLikeClick = (): void => {
    setLiked(!liked);
  };

  return (
    <button onClick={onLikeClick }>
      {liked ? '좋아요 취소' : '좋아요'}
    </button>
  );
}
```

```jsx
// presentation/LikeButton.test.ts
test('좋아요 버튼 기능 테스트', () => {
  const { getByText } = render(<LikeButton />);

  const button = getByText('좋아요');
  **fireEvent.click(button);**
  expect(getByText('좋아요 취소')).toBeTruthy();

  **fireEvent.click(button);**
  expect(getByText('좋아요')).toBeTruthy();
});
```

## (2) application/presentation 구분이 있을때

```jsx
// application/useLike.ts
export function useLike() {
  const [liked, setLiked] = useState(false);

  const toggleLike = () => {
    setLiked(!liked);
  };

  return { liked, toggleLike };
}

// presentation/LikeButton.tsx
function LikeButton(): JSX.Element {
  const { liked, toggleLike } = useLike();

  return (
    <button onClick={toggleLike}>
      {liked ? '좋아요 취소' : '좋아요'}
    </button>
  );
}
```

```jsx
// application/useLike.test.ts
test('좋아요 기능 테스트', () => {
  const { result } = renderHook(() => useLike());

  expect(result.current.liked).toBe(false);

  **act(() => {
    result.current.toggleLike();
  });**

  expect(result.current.liked).toBe(true);

  **act(() => {
    result.current.toggleLike();
  });**

  expect(result.current.liked).toBe(false);
});
```

예시를 위한 간단한 코드이지만 application/presentation이 구분이 없을때는 화면과 연관성이 깊기 때문에 “유저의 액션” 을 이용한 테스트 코드를 작성해야 합니다. 반면에, application 에 비즈니스 로직을 집중하고 presentation을 화면표시만 집중했을때는 순수로직의 결과값을 가지고 테스트를 수행할 수 있습니다.

따라서, 모호성이 존재하더라도 로직과 화면을 분리하는 것이 소프트웨어가 복잡해질수록 필요해지는 테스트코드 작성이나 모듈화에 강점이 있기 때문에 분리할려고 노력하는 것이 중요합니다.

# 5. 핵심은 재사용성과 유지보수성이다.

사실 어떤 폴더구조를 가져가든 가장 중요한 것은 **“우리팀원이 가장 편한 구조는 무엇인가?”** 입니다. 이런 맥락으로 봤을 때, (2) 일반적인 폴더구조의 문제점은 무엇일까? 에서 언급한 일반적인 폴더구조가 가장 이상적일 수 있습니다. 일반적이기때문에 어떤 팀원이 합류하더라도 빠르게 녹아들 수 있기때문입니다.

하지만, 서비스가 커질수록 중요한것은 프레임워크에 관계없이 사용할 수 있는 공통모듈을 만들고, 테스트하기 편한 코드를 작성하는 것입니다. 정답은 없지만 **순수함수와 React에 종속적인 함수를 분리**하고, **로직과 화면표시를 분리**하는 것은 프로젝트의 재사용성과 유지보수성을 높이는데 도움이 된다는 것을 인지하고 개발을 하는 것이 좋을 것 같습니다. 저는 2023년 10월 현재기준 아래와 같이 폴더구조를 구성하고 있습니다.

```
**application (react 종속적인 비즈니스로직)**
-- hooks
---- common (useScroll 등 브라우저에서 자주 사용되는 custom hooks)
---- apis (react-query를 사용하는 custom hooks)
---- logics (useLike와 같은 비즈니스 로직 custom hooks)
-- redux
**presentation (화면표시를 위한 컴포넌트 or 페이지)**
-- components
---- atoms
---- molecules
---- organisms
-- features (페이지의 실제 컴포넌트)
----- home.tsx
-- styles
**pages**
-- home_page.tsx (페이지의 루트를 위한 컴포넌트)
**infrastructure (순수 자바스크립트 함수 or 비즈니스로직)**
-- apis
-- network
-- storage
-- helpers
```