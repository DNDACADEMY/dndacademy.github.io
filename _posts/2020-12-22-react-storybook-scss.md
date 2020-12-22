---
layout: post
title: "scss를 활용한 스토리북 개발"
author: Gidong
categories: [React.JS]
tags: [scss, Storybook, javascript]
image: assets/images/react-storybook-scss/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> 들어가기에 앞서, 본 프로젝트는 TypeScript/CRA기반의 Storybook에서 진행하였습니다.

1. Storybook에서 Scss 사용 및 classnames를 사용하기 위해서 아래의 내역을 install 한다.

```bash
yarn add --dev node-sass
yarn add --dev classnames
yarn add --dev @types/classnames
```

2. .storybook에 main.js파일에 다음과 같이 추가를 해준다.

> 추가내역 : '@storybook/preset-scss'

![image1](/assets/images/react-storybook-scss/image1.png)

3. 그러면 다음과 같은 scss등을 작성할 수 있다.

```css
@import "Styles/default.scss";

$color: $blue;
.simpleButton{
    display: inline-flex;
    align-items: center; // 텍스트를 버튼의 중앙에 위치 시키게 하는 것들
    justify-content: center;
    color: $text-color;
    font-weight: bold;
    outline: none;
    border: none; // 원래 버튼에는 테두리가 있는데 그것을 없앰
    border-radius: 4px; // 둥글게 하는것
    cursor: pointer; // 커서를 올리면 포인터 모양으로 됨

    // 버튼 크기
    &.large {
        height: 3rem;
        padding-left: 1rem;
        padding-right: 1ren;
        font-size: 1rem;
    }

    &.medium {
        height: 2.25rem; // 버튼 크기
        padding-left: 1rem;
        padding-right: 1rem;
        font-size: 1rem; // 크롬 기본 폰트 크기 16px * 1 rem =16px   
    }

    &.small {
        height: 1.75rem;
        font-size: 0.875rem;
        padding-left: 1rem;
        padding-right: 1rem;
    }

    // disabled
    &.disabled {
        background: $disabled-color;
    }

    background: $color; // 위에 변수로 지정한 것을 사용

    &:hover {
        // & 연산자는 button 자기 자신을 가르키게 됨
        background: lighten($color, 10%); // lighten이라는 함수로 밝기를 조절 가능, 두번째 파라미터에는 얼마나 밝게 할지 지정
    }

    &:active {
        // 클릭 했을 때
        background: darken($color, 10%);
    }

    &+& {
        // 버튼 사이 여백
        margin-left: 1rem;
    }
}
```

4. 컴포넌트 개발

각 컴포넌트에서의 size조절, disabled일때의 색상조정 등을 위해서 다양한 className을 사용해야한다.
다중 className을 사용하기 위해서 다음과 같은 `import classNames from 'classnames/bind'`가 필요하다.
해당 부분은 앞서 **@types/classnames**, **classnames**를 통해서 설치가 되었기 때문에 이상없이 사용할 수 있다.

```javascript
import React from "react";
import styles from "./SimpleButton.module.scss";
import classNames from 'classnames/bind';

const cx = classNames.bind(styles);
```

이렇게 bind된 class를 실제 컴포넌트에서 아래와 같이 사용할 수 있다.

```javascript
<button className={[cx('simpleButton', size, disabled && 'disabled')]}
    disabled={disabled}
    onClick={onClick}
    {...props}
>
    {children}
</button>
```

결과적으로 `simpleButton`의 css를 사용하면서, **size**에 'small','large','middle'와 같은 문자열이 들어왔을 경우에
css에 미리 정의되어 있는 'small','large','middle'를 호출하여 css가 추가됨으로써 버튼의 크기가 커지거나 줄어드는 형태의 이벤트를
확인할 수 있다.
이를 통해서 다양한 이벤트적인 처리를 추가하여 사용할 수 있다.