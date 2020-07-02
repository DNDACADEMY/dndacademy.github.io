---
layout: post
title: "React Hooks와 Context를 이용한 설계 패턴"
author: Gidong
categories: [React.JS]
tags: [Developer]
image: assets/images/link-react-js/reacthooks.jpeg
# rating: 4.5
sitemap:
  changefreq: daily
  priority: 1.0
---

당신이 React를 즐겨 쓰는 사람이라면 끊임없이 변화하는 이 변덕스러운 도구를 감당하지 못했던 적도 있을 것이다. [Fiber(v16.0)](https://tech.wanted.co.kr/frontend/2018/01/07/react-fiber.html)가 등장한 게 2017년 겨울이었는데 어느 새 최근 8월 8일 [v16.9](https://github.com/facebook/react/releases/tag/v16.9.0) 정식 버전이 릴리즈되었다. 2년 사이에 React는 거의 모든 것이 바뀌었다. 렌더링 방식뿐만 아니라 패러다임 자체가 클래스형 컴포넌트에서 함수형 컴포넌트로 넘어갔다. 라이프사이클의 각 시점마다 유저가 개입하던 방식에서 Hooks를 이용해 상태 변수의 레퍼런스 변화를 추적하는 방식을 사용하게 되었다. 변화가 너무 빨랐던 탓일까? 여전히 대중들은 새 인터페이스에 적응하지 못한 듯하다. 시중에 유통되는 서적이나 튜토리얼 영상 대부분이 Redux를 중심으로 클래스형 컴포넌트를 구축하는 예전 패턴을 벗어나지 못하고 있는 걸로 보인다.

코드 스플리팅, 메모이제이션도 그렇지만 상태 관리만큼은 더 이상 서드파티를 고려할 필요가 없을 정도로 React는 발전했다. v16.3 부터는 [Context API](https://reactjs.org/blog/2018/03/29/react-v-16-3.html) 를 이용해 프로젝트 전체가 아닌 사용자가 원하는 범위 안에서 개별적으로 스토어를 구축할 수 있게 되었다. v16.8 에 정식 출시된 [Hooks](https://ko.reactjs.org/docs/hooks-intro.html)를 이용하면 useState를 이용해 함수형 컴포넌트 안에서도 상태를 만들 수 있다. 심지어 기본 Hooks를 조합해 자신만의 커스텀 Hooks를 만들어 프로젝트 여기저기서 재사용이 가능하다. 내가 원하는 레시피로 구성된 상태 및 메서드 세트를 자유롭게 가져다 쓰는 것이다. 예를 들어 페이지네이션을 제공하는 커스텀 Hooks를 만든다고 생각해 보자. 아티클 목록과 페이지 단위 숫자를 인자로 제공하면 페이지네이션 Hooks는 현재 페이지, 슬라이스된 목록, 그리고 다음 페이지나 이전 페이지로 이동할 수 있게 하는 메서드를 리턴해준다. 청사진의 형태로 선언되어 있다가 컴포넌트 안에 할당되는 순간 일종의 캡슐화된 상태를 보유하게 된다.

문제는 React 측에서 베스트 프랙티스를 만들어주지 않는다는 것이다. 커뮤니티가 넓기에 유저들이 자기만의 방식을 만들게 내버려 두는 쪽을 택하는 것 같긴 하지만 짧은 시간 안에 수많은 새 개념이 도입된 상태에서 초심자들이 모든 도구를 자유자재로 사용하기란 쉬운 일이 아니다. 나 또한 React가 제공하는 도구들만 이용해서 상태 관리를 납득 가능한 방식으로 해내려고 꽤 긴 시간 삽질을 했다(…). 이제야 오늘 소개하려는 Context와 Hooks를 조합한 패턴을 자신 있게 쓸 수 있게 된 것 같다. 함수형 컴포넌트 세계에서, 메서드를 재사용하면서 지역적으로 공유 가능한 상태를 관리하는 방식이다.

### Hooks만 쓰는 경우: 컴포넌트 간 상태 공유가 어려움

예시를 위해 페이지네이션 생성을 도와주는 Hooks 하나를 들고 왔다.

```jsx
// usePage.tsx
import React, { useMemo, useState } from 'react';
const usePage = (PAGE_VOLUME: number) => {
const FIRST_PAGE = 1;
const [currentPage, setCurrentPage] = useState<number>(FIRST_PAGE);
const [list, setList] = useState<any[]>([]);
 // 리스트 데이터 추가
 function addListData(data: any[]): void {
 setList(data);
 }

 // 리스트의 마지막 페이지
 const LAST_PAGE = useMemo(() => {
 const result = Math.ceil(list.length / PAGE_VOLUME);
 return result > 0 ? result : 1;
 }, [list]);

 // 페이지네이션 리스트
 function paginatedList(page: number): any[] {
 return list.slice((page - 1) * PAGE_VOLUME, page * PAGE_VOLUME);
 }

 // 페이지 변경
 function handlePage(e: React.BaseSyntheticEvent): void {
 setCurrentPage(parseInt(e.currentTarget.value, 10));
 }

 return {
 CURRENT_PAGE: currentPage,
 FIRST_PAGE,
 LAST_PAGE,
 addListData,
 handlePage,
 paginatedList,
 };
};

export type usePageProps = ReturnType<typeof usePage>;

export default usePage;
```

이 Hooks는 몇 가지 상태와 메서드를 제공한다. 초기화 시점에서 `PAGE_VOLUME`, 즉 페이지 당 요소를 몇 개로 할지 정하고 `addListData()` 함수로 전체 목록을 주입하면 첫 페이지, 현재 페이지, 마지막 페이지, 1페이지 크기로 슬라이스된 리스트 그리고 페이지를 바꾸는데 쓰이는 `handlePage()` 함수가 제공된다. 이 Hooks만 있으면 프로젝트 내의 어느 영역에든 페이지네이션을 적용할 수 있을 것이다.

문제는 도입 이후에 벌어진다. 회원 목록 컴포넌트에 페이지네이션 Hooks이 할당된다. 그런데 회원 목록 컴포넌트는 대략 서너 개의 자식 컴포넌트로 찢어져 있다. 실제 목록을 렌더링하는 컴포넌트, 페이지네이션 인디케이터를 그리는 컴포넌트, 심지어는 회원 종류를 카테고리 별로 필터링하는 버튼 컴포넌트도 있다 치자. 각 컴포넌트는 어떻게 Hooks에 정의된 상태를 받아 볼 수 있을까?

![https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/use_page_01.png](https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/use_page_01.png)

방법이 없다. 부모 컴포넌트가 자식들에게 일일이 Props로 전달하는 수밖에. 그러면 회원 목록 컴포넌트 하위에 만들어지는 모든 자식 컴포넌트는 usePage Hooks의 모든 값을 주렁주렁 받아들어야 한다. 여기까진 괜찮다. 그런데 만일 기간별 조회 필터링을 담당하는 컴포넌트가 자식으로 추가되었는데, 그 컴포넌트가 리스트 상태를 직접 수정해야 한다면? 혹은 새로고침 버튼 컴포넌트가 추가되어 버튼이 눌릴 때마다 AJAX 요청을 받아 리스트를 다시 구성하도록 해야 한다면? 요컨대 자식이 부모의 상태를 변경해야 하는 상황이 발생한다면? 이 패턴에서는 소화하기 매우 힘들어질 것이다.

![https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/use_page_02.png](https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/use_page_02.png)

커스텀 Hooks란 컴포넌트 안에 작성할 Hooks를 따로 모아놓은 것에 불과하다. 따라서 ‘Hooks의 상태를 어떻게 공유할 것인가?’ 라고 묻는다면 React 초창기에 제기된 상태 관리 문제가 반복되고 있음을 시인할 뿐이다. 이래서는 안 된다.

### Context만 쓰는 경우: 지역적으로만 사용 가능

Context는 일정 범위에 속한 컴포넌트 트리에 데이터를 제공해주는 간이 스토어다. Provider를 이용해 컴포넌트 트리를 감싸면, 그 안에 속한 모든 자식들은 부모를 신경쓰지 않고 곧장 Consumer를 호출해 데이터를 꺼내 쓸 수 있다.

```jsx
// pageContext.tsx
import React from 'react';
const FIRST_PAGE = 1;
const PAGE_VOLUME = 10;
export const PageContext = React.createContext<{
CURRENT_PAGE: number;
 FIRST_PAGE: number;
 LAST_PAGE: number;
 addListData: (data: any[]) => void;
 handlePage: (e: React.BaseSyntheticEvent) => void;
 paginatedList: any[];
}>({
 CURRENT_PAGE: FIRST_PAGE,
 FIRST_PAGE,
 LAST_PAGE: FIRST_PAGE,
 addListData() {},
 handlePage() {},
 paginatedList() {
 return [];
 },
});

export const PageProvider: React.FC = ({ children }) => {
 const [currentPage, setCurrentPage] = useState<number>(FIRST_PAGE);
 const [list, setList] = useState<any[]>([]);

 // 리스트 데이터 추가
 function addListData(data: any[]): void {
 setList(data);
 }

 // 리스트의 마지막 페이지
 const LAST_PAGE = useMemo(() => {
 const result = Math.ceil(list.length / PAGE_VOLUME);
 return result > 0 ? result : 1;
 }, [list]);

 // 페이지네이션 리스트
 function paginatedList(page: number): any[] {
 return list.slice((page - 1) * PAGE_VOLUME, page * PAGE_VOLUME);
 }

 // 페이지 변경
 function handlePage(e: React.BaseSyntheticEvent): void {
 setCurrentPage(parseInt(e.currentTarget.value, 10));
 }

 const initialValue = {
 CURRENT_PAGE: currentPage,
 FIRST_PAGE,
 LAST_PAGE,
 addListData,
 handlePage,
 paginatedList,
 }

 return <PageContext.Provider value={initialValue}>{children}</PageContext.Provider>;
}
```

아까 Hooks의 형태로 구현했던 것을 Context로 다시 구현했다. Provider의 경우 initialValue를 제공하기 위해 Provider 컴포넌트를 감싸는 [컴포넌트 합성 패턴](https://ko.reactjs.org/docs/composition-vs-inheritance.html)을 사용했다.

이제 PageProvider 내부에 담기는 모든 컴포넌트들은 자유롭게 Context 값을 호출할 수 있다. useContext를 이용하면 코드가 더 깔끔해진다.

```jsx
// somePage.tsx
import React from 'react';
import { PageProvider } from './pageContext';
import Category from './category';
import List from './list';
import Indicator from './indicator';
const SomePage: React.FC = () => {
 return (
 <PageProvider>
 <Category />
 <List />
 <Indicator />
 </PageProvider>
 );
};

export default SomePage;

// list.tsx

import React, { useContext, useEffect } from 'react';
import { PageContext } from './pageContext';

const List: React.FC = () => {
 const { addListData, paginatedList } = useContext(PageContext);

 // Ajax로 raw data 받아오는 예시
 useEffect(() => {
 someAJAXToGetList().then(data => addListData(data));
 }, []);

 return (
 <div>
 {Array.prototype.map.call(paginatedList, item => (
 <div key={item.id}>
 <p>{item.contents}</p>
 </div>
 ))}
 </div>;
 );
};

export default List;
```

![https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/context_01.png](https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/context_01.png)

지역적인 스토어를 제공한다는 건 분명 장점이지만 Context에서 정의된 코드는 재사용될 수 없다는 게 치명적이다. 다른 지역 컴포넌트에서 또다시 페이지네이션이 필요해질 경우, 그쪽 Context에 사용할 코드를 중복 구현하는 수밖에 없게 된다.

![https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/context_02.png](https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/context_02.png)

### Hooks + Context => 메서드 재사용 + 상태 공유

재사용하려는 메서드는 Hooks로 선언하고, 이 Hooks를 Context에 할당함으로써 재사용과 상태 공유의 이점을 둘다 가져간다. 이번 포스팅의 핵심 포인트다.

```jsx
// pageContext.tsx
// usePage 코드는 기존 것과 동일하다고 가정

import React from "react";
import usePage, { usePageProps } from "./usePage";

const FIRST_PAGE = 1;
const INIT_PAGE_VOLUME = 10;

export const PageContext =
  React.createContext <
  usePageProps >
  {
    CURRENT_PAGE: FIRST_PAGE,
    FIRST_PAGE,
    LAST_PAGE: FIRST_PAGE,
    addListData() {},
    handlePage() {},
    paginatedList() {
      return [];
    },
  };

export const PageProvider: React.FC = ({ children }) => {
  const pageProps = usePage(INIT_PAGE_VOLUME);
  return (
    <PageContext.Provider value={pageProps}>{children}</PageContext.Provider>
  );
};
```

코드 변화는 작지만 개발자가 갖는 이점은 커진다. usePage로 정의된 Custom Hooks는 이제 프로젝트 어디서나 재사용이 가능해진다. 포인트는 그런 usePage를 컴포넌트가 직접 사용하는 게 아니라, 각 지역 컴포넌트에 할당된 Context가 사용하게 하는 것이다. 이제 Context Provider 내부에 담기는 모든 컴포넌트는 계층 관계를 신경쓰지 않고 직접 usePage의 요소들을 호출할 수 있게 된다.

![https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/solution.png](https://www.huskyhoochu.com/react-pattern-hooks-and-contexts/solution.png)
