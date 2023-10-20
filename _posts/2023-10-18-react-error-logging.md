---
layout: post
title: "[React] API 에러 로깅"
author: 이재왕
categories: [React.JS]
tags: [React, Error, Logging, React-Query, ErrorBoundary, Next.JS]
image: assets/images/react-error-logging/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---
# [React] API 에러 로깅
mai
<aside>
💡 개요: 어플리케이션 에러는 대부분 서버와 통신하는 과정에서 발생한다. 서버에러에 대한 로깅은  API Call함수, 서버상태관리 라이브러리, ErrorBoundary 등 다양한 구간에서 처리할 수 있는데, 어디서 처리하는 것이 가장 이상적일까? 또한, 에러로깅에는 어떤 정보가 담겨야 할까?

</aside>

# 1. 설계시 어떤 에러를 고려해야할까?

웹에서는 크게 3가지 유형의 에러가 존재합니다.

```
1. UI Error

2. Network Error

3. Business Logic Error
```

UI Error 는 버튼이 작동을 안하거나, null인 데이터를 표시하다가 발생하는 등 **웹을 표시하는 과정에서 발생하는 오류**를 의미합니다.

Network Error는 일반적으로 백엔드와 통신하는 과정에서 body의 형식이 맞지않거나, 존재하지 않는 데이터를 요청하거나, 서버의 상태가 불안정하는 등 **API 를 요청하고 응답을 받는 과정에서 발생하는 오류**를 의미합니다.

Business Logic Error는 사용자가 허가되지 않은 페이지에 접속하거나, 수량이 남지않은 제품의 구매버튼이 눌렸다거나, 회원가입시 입력한 데이터가 원하는 조건을 충족하지 못하는 등 **서비스가 정의한 기능의 요구사항을 만족하지 못하면서 발생하는 오류**를 의미합니다.

# 2. 왜 Network Error 가 가장 중요할까?

UI Error나 Business Error는 개발환경과 코드리뷰 문화가 잘 갖추어져 있고 특히, 테스트케이스 작성 문화가 존재한다면 대부분 개발단계에서 발견됩니다. 또, production - staging - development 환경이 잘 분리가 되어있다면 QA 단계에서 발견되는 일이 대부분이기 때문에 실제 사용자까지 전달되지 않는 경우가 많습니다.

그에 비해서 서버는 항상 안정하지 않을뿐더러 백엔드 개발자도 실수를 할 수 있기 때문에 Network Error는 예측이 불가능합니다. 실제로 **대부분의 어플리케이션 에러는 서버와 통신하면서 발생**합니다. 따라서, Network Error를 잘 다루고 로그를 남기는 것이 가장 중요합니다.

# 3. 어디에서 에러로깅을 처리를 할 수 있을까?

서버상태 관리를 위해 React Query나 SWR 같은 라이브러리를 사용하고, API Call 을 위한 함수를 서버상태 라이브러리와 분리하여 관리한다면 아래의 3가지 부분에서 에러를 처리할 수 있습니다.

```
1. API Call 함수

2. 서버상태관리 라이브러리의 Error Callback

3. ErrorBoundary
```

## (1) API Call 함수

API Call 함수에서 에러를 처리한다면 아래와 같이 try/catch 문을 사용하여 API Call 을 하는 부분에서 처리를 하거나, axios와 같이 interceptor 을 지원하는 라이브러리를 사용할 경우 interceptor에서 처리할 수도 있습니다.

API Call 부분은 네트워크 에러에 반응하는 첫번째 구간이기 때문에 Exception 을 원하는 방식대로 변경하거나, 커스텀한 에러메세지지나 변수를 추가하는 등의 작업이 가능합니다.

```tsx
// API Call 에서 처리
import axios from 'axios';

export async function getCatalog(): Promise<ProductDTO> {
  try {
    const res = await axios.get<ProductDTO>('/products');
    return res.data;
  } catch (err) {
    **if (axios.isAxiosError(err) {
      console.error(err.response?.data.message || '알수없는 에러');
    } else {
      console.error('알수없는 에러');
    }**
  }
}
```

```tsx
// Interceptor 에서 처리
import axios from 'axios';

const axiosInstance = axios.create({
  timeout: 5000,
});

axiosInstance.interceptors.response.use(
  response => response,
  err => {
    **if (error.response) {
      console.error(err.response.data.message || '알수없는 에러');
    } else {
      console.error('알수없는 에러');
    }**
    return Promise.reject(err);
  }
);
```

## (2) 서버상태관리 라이브러리의 Error Callback

서버상태를 위한 라이브러리의 Error Callback에서 에러를 처리할경우 아래와 같이 처리할 수 있습니다. 해당부분은 네트워크 에러에 반응하는 두번째 구간으로 에러가 발생했을 때, 후속조치를 할 수 있는 장점이 있습니다. 특히, React의 Hooks 함수를 사용할 수 있기 때문에 순수자바스크립트 코드가 존재하는 API Call 부분에 비해서 다양한 후속조치를 할 수 있습니다.

예를들어 쇼핑몰사이트의 상품주문이라고 상황을 가정할 때, 주문이 실패했을 경우 다른페이지로 자동으로 이동하거나 hooks 함수로 작동하는 toast나 dialog 등을 띄울 수 있습니다.

```tsx
import { useQuery } from '@tanstack/react-query';

export function useCatalog() {
  const { data, error, isError, isLoading } = useQuery(['catalog'], getCatalog, {
    useErrorBoundary: true,
  });

  useEffect(() => {
    **if (isError) {
      console.error(error!);
    }**
  }, [isError]);
  
  return {
    data,
    error,
    isError,
    isLoading,
  }
}
```

## (3) ErrorBoundary

ErrorBoundary에서 처리할 경우 아래와 같이 react-error-boundary의 onError 함수에서 처리하거나 [원래ErrorBoundary의 componentDidCatch함수 내](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)에서 처리할 수 있습니다. ErrorBoundary는 페이지나 컴포넌트와 밀접하게 붙어있기때문에 에러메세지 작성시 컴포넌트명, 오류가 발생한 페이지url 등 다양한 메타데이터를 활용할 수 있는 장점이 있습니다.

```tsx
import { ErrorBoundary } from 'react-error-boundary';

export function CatalogPage(): JSX.Element {
  const { data } = useCatalog();

  const logError = (error: Error, info: { componentStack: string }) => {
    **if (axios.isAxiosError(err) {
      console.error(err.response?.data.message || '알수없는 에러');
    } else {
      console.error('알수없는 에러');
    }**
  };

  return (
    <ErrorBoundary FallbackComponent={ErrorFallback} **onError={logError}**>
      <p>상품 리스팅 페이지</p>
    </ErrorBoundary>
  );
}
```

# 4. 핵심은 어디에서가 아닌 로깅의 중앙화이다.

위에서 설명했듯이 각 구간은 각자의 장점을 가지고 있습니다. 하지만, **로깅처리가 중앙화되지 않거나 통일된 포맷이 없다면 서비스가 커질수록 유지보수에 어려움이 생깁니다.**

예를들어 원래 로그에 오류발생시간을 기록하지 않았다고 가정해봅시다. 만약 추후 시간정보를 기록해야 하는데 로그처리가 중앙화되어있지 않다면, 해당 로직을 수행하는 모든 함수에 오류발생시간을 추가해야 합니다.

**어디에서 중앙화를 할지는 상황에따라 달라집**니다. 저는 큰 범주로 봤을 때 “프레임워크를 React만 사용할 것인가?” 를 두고 결정합니다.

## (1) 여러 프레임워크를 사용하는 경우

많은 프로젝트에서 다양한 프레임워크를 혼합하여 사용합니다. 대표적인 예를 들자면, 관리자 페이지는 Vue로 작성하고 사용자 어플리케이션은 React로 작성하는 경우입니다.

이럴경우 **axios interceptor에 중앙화**를 하는 것이 좋습니다. axios는 프레임워크에 종속적이지 않기때문에 infrastructure레이어에 두고 로깅을 중앙화하면 여러 프로젝트에서 공통적으로 사용할 수 있어서 재사용성이 높아집니다.

```tsx
import axios from 'axios';

const axiosInstance = axios.create({
  baseURL: '...',
});

axiosInstance.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {  
    const { config, response, request } = error;

    **if (response) {
      sendLogError({
        message: '서버에러',
        endpoint: config.url,
        status: response.status,
        data: response.data,
        headers: response.headers
      });
    } else  {
      sendLogError({
        message: '응담없음',
        endpoint: config.url,
        requestData: config.data
      });
    }**

    return Promise.reject(new CustomNetworkError(error));
  }
);
```

예시에서 마지막 Promise.reject 시 CustomNetworkError를 반환하는데, 이것은 추후 axios가 아닌 다른 라이브러리나 native fetch 등으로 교체할 경우에도 리턴되는 에러타입을 동일하게 가져가기 위한 것입니다. 여기에 대한 자세한 내용은 [[React] 라이브러리의 추상화](https://www.notion.so/React-bee62640afe04bb991a84df7c319aa97?pvs=21) 에서 확인할 수 있습니다.

## (2) React만 사용하는 경우

**모든 프로젝트가 React에 기반할 경우 react-query에 중앙화를 하는 것이 좋습니다.** 앞에서 언급했듯이 React-Query는 리액트 라이프사이클과 함께 동작하기 때문에 axios에서 처리하기 힘들었던 다른 hooks 함수와의 조합 등이 가능합니다.

그 중에서 react-query를 사용하는 가장 큰 장점은 **retry 기능이 내장되어있는 것**과 **컴포넌트 추적**이 가능하다는 것입니다.

```tsx
// use cases
useQuery(['querykey'], fetchFunction, {
  **context: { componentName: 'Custom Component' }**
});

// default client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      onError: (error, _variables, context, queryInstance) => {
        const { componentName, failureCount } = context;
        if (failureCount === 0) {
          return;
        }
        sendLogError({
          message: '서버에러',
          endpoint: _variables[0],
          status: error.response.status,
          data: error.response.data,
          headers: error.response.headers,
          **componentName,**
        });
      },
    },
  },
});
```

예제에서 failureCount 가 0일때, 로그데이터를 보내지 않도록 했는데 클라이언트가 일시적으로 네트워크 상태가 불안정해지거나 할 수 있기때문에 실제 production 환경에서는 2~3번 같은 오류가 발생했을때 에러로깅을 보내도록 하고있습니다. 또한, context에 componentName이라는 변수를 수동적으로 할당함으로써 어떤 컴포넌트에서 오류가 발생했는지도 확인할 수 있습니다.

이처럼 **일반적으로 axios보다 react-query 에서 전역에러에 대한 로그를 처리하는 것이 더 많은 metadata를 얻을 수** 있습니다.

하지만, **“어디에서 중앙화를 할것인가?” 보다는 “중앙화를 해야한다.” 그 자체가 중요**하다고 생각합니다.