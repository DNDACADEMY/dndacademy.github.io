---
layout: post
title: "[React] 핵심 로직은 어디에 위치해야하는가? (Component vs Hooks)"
author: 이재왕
categories: [React.JS]
tags: [React, Component, Hooks, Next.JS]
image: assets/images/react-where-business-logics/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---
# [React] 핵심 로직은 어디에 위치해야하는가? (Component vs Hooks)

<aside>
💡 개요: 리액트에서 핵심로직은 “컴포넌트 내부” 나 “Custom Hooks”에 담을 수 있다. 어느곳에 로직을 담든 구현은 가능하지만, 어디에 담느냐에 따라서 확장성, 테스트코드 작성 방식 등이 달라질 수 있다. 어디에 작성을 하는게 이점이 많을까?

</aside>

# 1. 리액트에서 핵심 비즈니스로직은 어디에 위치하는가?

리액트로 웹어플리케이션을 개발할때 핵심 비즈니스로직이 담길 수 있는 부분은 “Component 내부“ 와 ”Custom Hooks” 2개가 있습니다.

예를들어 봅시다. 소셜 미디어 서비스를 만들고 있고, 흔히 볼 수 있는 “좋아요 기능” 을 만드는 상황입니다. 요구조건은 아래의 2가지 기능을 구현하는 것입니다.

```
1. 좋아요 카운트 증가

2. 좋아요 아이콘 outline -> fill로 변경
```

## (1) Component 내부

Component 내부에 로직이 위치시킨다면 “좋아요 버튼” 안에 위의 로직을 담고, 하나의 완성된 컴포넌트를 사용할 것입니다.

```tsx
// preseneation/components/organisms/button_like.tsx
export function ButtonLike(postLikeCount: number): JSX.Element {
  const [likeCount, setLikeCount] = useState<number>(postLikeCount);
  
  const onLikeClick = (): void {
    setLikeCount((prev) => prev + 1);
  }

  return (
    <>
      <IconHeart data-testid="ic_heart" fill={likeCount !== postLikeCount} onClick={onLikeClick} />
      <p data-testid="like_count">{likeCount}</p>
    </>
  );
}
```

## (2) Custom Hooks

useLike 와 같이 custom hooks 를 만들어서 안에 로직을 담는다면 useLike + ButtonLike 의 조합으로 기능이 완성될 것이고, ButtonLike는 그 자체로는 로직이 존재하지 않는 순수하게 아이콘 표시만 담당하는 컴포넌트로 남을것입니다.

```tsx
// application/hooks/logics/use_like.ts
export function useLike(postLikeCount: number) {
  const [likeCount, setLikeCount] = useState<number>(postLikeCount);
  
  const handleLikeClick = (): void {
    setLikeCount((prev) => prev + 1);
  }

  return { likeCount, handleLikeClick }
}

// preseneation/components/organisms/button_like.tsx
export function ButtonLike(postLikeCount: number): JSX.Element {
  const { likeCount, handleLikeClick } = useLike({ postLikeCount });
  
  const onLikeClick = (): void {
    handleLikeClick();
  }

  return (
    <>
      <IconHeart data-testid="ic_heart" fill={likeCount !== postLikeCount} onClick={onLikeClick} />
      <p data-testid="like_count">{likeCount}</p>
    </>
  );
}
```

# 2. Custom Hooks 가 로직을 담기에 장점이 많다.

Component 내부와 Custom Hooks 모두 비즈니스 로직을 담기에 충분하나, **Custom Hooks 가 좀 더 유리한 점이 많습니다.** 어떤 측면에서 장점을 가지고 있는지 알아보겠습니다.

## (1) 테스트코드 작성

Component내부에 로직이 있을때와 Hooks안에 로직이 있을때는 테스트코드 작성시 큰 차이를 보이는데, **Component는 유저의 행동을 통해 테스트**를 진행하고, **Hooks는 함수의 결과를 통해 테스트**를 진행합니다. 

소셜미디어의 “좋아요 기능” 을 만든다고 가정하고 테스트코드를 작성해보겠습니다.

```tsx
describe('좋아요 버튼 기능 테스트', () => {
  it('아이콘 outline -> fill 변경 테스트', () => {
    const { getByTestId } = render(<ButtonLike postLikeCount={5} />);
    const iconHeart = getByTestId('ic_heart');

    expect(iconHeart).toHaveAttribute('fill', 'false');

    fireEvent.click(iconHeart);

    expect(iconHeart).toHaveAttribute('fill', 'true');
  });

  it('좋아요 카운트 증가 테스트', () => {
    const { getByTestId } = render(<ButtonLike postLikeCount={5} />);
    const iconHeart = getByTestId('ic_heart');
    const likeCount = getByTestId('like_count');

    expect(likeCount.textContent).toBe('5');

    fireEvent.click(iconHeart);

    expect(likeCount.textContent).toBe('6');
  });
});
```

위는 Componnent를 통해 테스트를 한 경우입니다. testId를 통해 아이콘을 찾고 fireEvent 함수를 통해 아이콘 클릭 전/후의 결과를 확인합니다.

```tsx
describe('useLike 기능 테스트', () => {
  it('좋아요 카운트 증가 테스트', () => {
    const { result } = renderHook(() => useLike(5));
    
    act(() => {
      result.current.handleLikeClick();
    });

    expect(result.current.likeCount).toBe(6);
  });
});
```

위는 Hooks를 통해 테스트를 한 경우입니다. Hooks 내부의 함수를 작동시키고 변수의 값이 잘 변했는지 변수값을 확인합니다.

**유저의 행동을 통한 테스트는 로직이 잘 작동하는 것 외에도 UI의 상태변화까지 잘 작동해야만 통과**합니다. 만약 좋아요 카운트를 담당하는 useState에 문제가 있으면 로직은 잘작동했지만 UI상에서는 바뀐게 없기때문에 테스트가 실패합니다. 따라서, 로직 그 자체가 잘 작동하는지를 확인하기 위해서는 hooks에 복잡핮 로직을 담는 것이 유리합니다.

## (2) 재사용성

일반적으로 좋아요 기능은 좋아요 버튼에서만 발생하지 않습니다. 인스타그램은 좋아요 버튼을 누를때도 기능이 활성화되지만, 릴스나 포스트슬 더블탭 했을때도 좋아요 기능이 활성화됩니다.

이처럼 **하나의 로직이 여러 UI에서 사용될 수 있기 때문에** custom hooks 에 로직을 담아놓고 여러 컴포넌트에서 사용하는 것이 더 유리합니다.

# 3. 언제 Component 내부에 로직을 담아야 할까?

일반적으로 모든 케이스에서 재사용성때문에 hooks에 로직을 담는게 선호되지만, 모든 로직을 hooks에 담으면 hooks의 양이 엄청나게 늘어나기도 하고, 오히려 유지보수에 어려움이 있습니다. 간단한 로직이나 하나의 컴포넌트에서만 사용되는 로직을 굳이 따로 관리할 필요가 없기 때문에 이번에는 어떤 상황에서 Component 내부에 로직을 담는게 좋은지에 대해서 알아보겠습니다.

## (1) UI와 직접적인 연관성이 있을때

Toggle 버튼이나 동영상 재생의 음소거를 위한 On/Off 로직 등은 로직이 완성된 한나의 컴포넌트(Switch 컴포넌트, 음소거 버튼 등)를 여러 페이지에서 공용으로 사용합니다.

또, 이런경우에는 Toggle이 제대로 되었는지 안되었는지 **유저에게 보여주는 결과가 중요**합니다. 따라서, 잘 작동되어도 시각화에 문제가 있으면 의미가 없기때문에 컴포넌트 내에 로직을 담고 유저행동에 대한 테스트를 진행하는 것이 좋습니다.

## (2) 하나의 컴포넌트에서만 사용될 때

블로그 플랫폼을 만든다고 가정해봅시다. 보통 작성중이던 포스트를 관리하기위해 Draft 기능을 개발할텐데, Draft기능이 사용되는 페이지는 “포스팅 작성” 페이지 하나밖에 없습니다.

위와같이 하나의 컴포넌트, 하나의 페이지에서만 사용되는 기능일때는 확장성이 상대적으로 덜 중요하기때문에 따로 로직을 담은 hooks를 분리시킬 필요가 없습니다.

결국 각자의 역할이 있고 장단점이 있습니다. 하지만, 일반적으로 **복잡한 로직(특히, API호출과 함께하는 로직들)이나 서비스에 중심이 되는 핵심기능들은 hooks에 로직을** 담고 언제든지 재사용될 수 있게 확장성을 유지하는 것이 중요합니다.