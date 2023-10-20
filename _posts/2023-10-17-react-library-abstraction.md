---
layout: post
title: "[React] 라이브러리의 추상화"
author: 이재왕
categories: [React.JS]
tags: [React, Library, Third-Party, Next.JS]
image: assets/images/react-library-abstraction/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---
# [React] 라이브러리의 추상화

<aside>
💡 개요: 현대의 어플리케이션은 많은 오픈소스의 조합으로 구성된다. 그만큼 하나의 기능을 구현하기위해 다양한 라이브러리가 존재한다. 만약 내가 사용하던 라이브러리보다 좋은 라이브러리가 나온다면 어떻게 해야할까? 어떻게 변경가능성을 최소화 할 수 있을까?

</aside>

# 1. 왜 라이브러리의 추상화가 필요할까?

대부분의 어플리케이션은 많은 종류의 라이브러리로 구성됩니다. React에 한해서는 아래와 같은 라이브러리들이 필수적으로 사용될 것입니다.

| 목적 | 라이브러리 | 대안 |
| --- | --- | --- |
| 서버상태 관리 | React-Query | SWR |
| 클라이언트 전역상태 관리 | Redux | Zustand |
| HTTP API 호출 | Axios | Native Fetch |
| 날짜 관리 | DayJS | Moment |

서비스가 커지고 기능이 다양해질수록 더 많은 라이브러리를 찾게됩니다.

그런데, 표에 나와있듯이 하나의 기능을 위해서 하나의 라이브러리만 존재하는 상황은 드뭅니다.  React-Query 와 SWR 같이 **서로 장단점은 다르지만 해결하고자 하는 목적은 같은 경우**도 있고, Moment 와 DayJS 같이 더 가볍고 최신화된 대안이 생겨나면서 **트렌드가 변경하는 사례**도 많습니다.

```tsx
// 폴더구조
- apis
--- product.ts
--- auth.ts
--- order.ts
```

```tsx
// apis/product.ts
import axios from 'axios';

export function getAllProducts(): Promise<Pagable<ProductDTO>> {
  const res = await axios.get<Pagable<ProductDTO>>('/products');
  return res.data; 
}
```

만약, API 호출을 위해서 위와같이 Axios 를 이용하여 코드를 작성했다가 Native Fetch 로 변경해야되는 상황이 온다면 apis 에 존재하는 모든 파일을 열어 코드를 변경해줘야 합니다. 그러면 호출하는 API 가 많아질수록 변경해야하는 코드도 많아집니다.

# 2. 추상화는 변경 가능성을 최소화한다.

위와 같은 상황을 방지하기 위해서는 추상화를 통해 소스코드의 변경 가능성을 최소화 해야합니다. 위의 예를 응용하여 axios 를 그대로 사용하지 않고 API 호출 부분을 하나의 독립함수로 만들어 아래와 같이 다시 작성한다면 추후 다른 라이브러리로 변경시 network/index.ts 파일만 수정하면 됩니다.

```tsx
// 폴더구조
- apis
--- product.ts
--- auth.ts
--- order.ts
- network
--- index.ts
```

```tsx
// network/index.ts
import axios from 'axios';

**export function requestGet<T>(url: string): Promise<T> {
  const res = await axios.get<T>(url);
  return res.data; 
}**
```

```tsx
// apis/product.ts
import { requestGet }from '../network';

export function getAllProducts(): Promise<Pagable<ProductDTO>> {
  **return requestGet.get<Pagable<ProductDTO>>('/products')**;
}
```

# 3. 자바스크립트의 추상화

위의 예시에서는 axios 라이브러리를 직접사용하지 않고 requestGet 이라는 공통함수를 만들고 공통함수를 사용하게 함으로써 추상화를 만족시켰습니다.

하지만, 추상화는 위와같은 방식만 있는것이 아닐뿐더러, 인터넷에 추상화 검색시 객체지향에서 자주 사용되는 abstract 클래스를 사용하는예시와 interface 를 사용하는 예시가 더 많습니다.

자바스크립트도 타입스크립트와 함께 abstract 클래스와 interface를 사용할 수 있지만, 저는 언어 본연의 방식을 유지하는 것을 좋아합니다.

자바스크립트는 여러 프로그래밍 패러다임을 지원하기 때문에 함수형 프로그래밍 언어는 아니지만, 일반적으로 순수함수사용과 불변성 지향을 선호합니다. 그래서 저는 자바스크립트 사용시 클래스 사용을 지양하고, 특히 **리액트로 개발시 클래스를 사용하는것보다 함수로 선언하는 것이 일관성이 높기때문에** 위와 같은방식으로 라이브러리를 추상화합니다.

이것은 개인적인 선호이기 때문에 자신의 스타일을 찾으면 되는 문제이고, 중요한 것은 아래의 요구사항을 만족하고 유지하는 것이라고 생각합니다.

```
1. **코드의 일관성**을 유지하는 것

2. **"구체적인 세부사항을 숨기고 중요한 부분만 노출시키기”** 라는 목적을 달성하는 것
```