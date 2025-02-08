---
layout: post
title: "프론트엔드 개발자가 Next.js로 알아보는 Gemini"
author: Gidong
categories: [Gemini]
tags: [developer, 개발, Gemini, Next.js]
image: assets/images/nextjs-with-gemini/01.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> Next.js 프레임워크를 기반으로하여서 @google/generative-ai 라이브러리를 활용하여 Gemini를 만들어보도록 하겠습니다.

# 1. Get API key

[//]: # (![/assets/images/nextjs-with-gemini/01.png]&#40;https://blog.dnd.ac/assets/images/nextjs-with-gemini/01.png&#41;)

[gemini](https://gemini.google.com/app) 사이트에 접속해보면 아래와 같은 화면을 볼 수 있습니다.

![/assets/images/nextjs-with-gemini/03.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/03.png)

그리고 다음에 보실 화면은 Next.js로 구현한 페이지입니다.

![/assets/images/nextjs-with-gemini/02.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/02.png)

조금의 차이는 있을지몰라도 상당부분 비슷한형태로 구성된 부분을 볼 수 있습니다.<br/>
실제로 프롬포트를 기반으로 답변을 준다거나 하는 동작원리도 동일하게 구현되어 있습니다.<br/>
이 글을 통해서 어떻게 gemini를 Next.js 프레임워크와 연결할 수 있는지에 대해서 알아보는 시간을 가져보려고 합니다.<br/>
우선 gemini를 사용하기 위해서는 API Key 발급 과정이 필요합니다.<br/>
- https://aistudio.google.com/app/apikey

1. "Create API Key" 버튼을 클릭합니다.
![/assets/images/nextjs-with-gemini/04.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/04.png)

2. 최초 발급일 경우 "Create APi Key in new Project" 버튼을 클릭합니다. (최초가 아닐경우 프로젝트 생성 후 API Key 연결작업을 진행하면됩니다.)
![/assets/images/nextjs-with-gemini/05.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/05.png)

3. 발급된 Key를 복사하여 따로 저장해둡니다.
![/assets/images/nextjs-with-gemini/06.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/06.png)

# 2. Go to Next.js

```bash
npx create-next-app@latest
```

명령어 입력 후 아래와 같이 선택을 하게되면 Next.js 프로젝트가 생성이 됩니다.

![/assets/images/nextjs-with-gemini/07.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/07.png)

## Installation

```bash
yarn add @google/generative-ai lucide-react

yarn add -D eslint-config-prettier prettier
```

gemini를 사용하기 위한 라이브러리(@google/generative-ai)와 UI를 꾸미는데 사용할 라이브러리(lucide-react)를 설치합니다.<br/>
라이브러리 설치 이후 `package.json` 파일을 확인하면 다음과 같습니다.

![/assets/images/nextjs-with-gemini/08.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/08.png)

## add Prettier

프리티어룰을 설정하여 개발의 편의성을 증대시킵니다.<br/>
`.prettierrc.js`
![/assets/images/nextjs-with-gemini/09.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/09.png)

## update eslintrc

`.eslintrc.json`

![/assets/images/nextjs-with-gemini/10.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/10.png)

## add .env

환경변수를 설정합니다.<br/>
`NEXT_PUBLIC_API_KEY` 부분에 발급된 Key의 값을 입력해줍니다.

![/assets/images/nextjs-with-gemini/11.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/11.png)

## 폴더구조

📦src <br/>
┣ 📂app <br/>
┃ ┣ 📜favicon.ico <br/>
┃ ┣ 📜globals.css <br/>
┃ ┣ 📜layout.tsx <br/>
┃ ┗ 📜page.tsx <br/>
┣ 📂components <br/>
┃ ┗ 📜GeminiBody.jsx <br/>
┣ 📂context <br/>
┃ ┗ 📜ContextProvider.jsx <br/>
┗ 📂lib <br/>
┃ ┗ 📜gemini.js <br/>

> 각 파일들간의 관계는 아래와 같습니다.

![/assets/images/nextjs-with-gemini/12.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/12.png)

# 3. 파일구조 설명

## 1. layout.tsx

ContextProvider를 감싸는 형태로 layout을 구성합니다.

![/assets/images/nextjs-with-gemini/13.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/13.png)

## 2. page.tsx

GeminiBody 컴포넌트를 호출합니다.

![/assets/images/nextjs-with-gemini/14.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/14.png)

## 3. GeminiBody

`useContext`를 통해서 gemini API 통신에 필요한 변수와 함수들을 가져옵니다.

![/assets/images/nextjs-with-gemini/15.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/15.png)

`displayResult` 값이 `false`일 경우 아래의 화면이 나오도록 되어있습니다.

![/assets/images/nextjs-with-gemini/16.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/16.png)

`displayResult` 값이 `true`일 경우 아래의 화면이 나오도록 되어있습니다.

![/assets/images/nextjs-with-gemini/17.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/17.png)

가장 아래부분에 프롬포트 입력이 될 수 있도록 `input` 컴포넌트로 구성되어 있습니다.

![/assets/images/nextjs-with-gemini/18.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/18.png)

## 4. ContextProvider

상태 정의부분 입니다.

![/assets/images/nextjs-with-gemini/20.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/20.png)


사용자가 입력하였을때 실행되는 함수로써 `runChat` 함수를 통해서 gemini api를 호출합니다.

![/assets/images/nextjs-with-gemini/21.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/21.png)

컨텍스트에 포함될 값들을 정의합니다.

![/assets/images/nextjs-with-gemini/22.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/22.png)

Context.Provider를 사용하여 contextValue를 자식 컴포넌트로 전달합니다.

![/assets/images/nextjs-with-gemini/23.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/23.png)

ContextProvider 전체코드로 보면 아래와 같습니다.

![/assets/images/nextjs-with-gemini/19.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/19.png)

## 5. lib/gemini

`@google/generative-ai` 라이브러리를 실질적으로 호출하는 부분입니다. <br/>
API Key와 모델을 설정하여서 gemini 챗봇을 생성하여서 메시지를 전송후 그 응답값에 대해서 반환하는 함수입니다.

![/assets/images/nextjs-with-gemini/24.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/24.png)

Gemini의 응답에 대해서 특정 유형의 해로운 콘텐츠를 차단하기 위한 설정이 있습니다.<br/>
이에 대한 안전 속성은 다음과 같습니다.

![/assets/images/nextjs-with-gemini/32.png](https://blog.dnd.ac/assets/images/nextjs-with-gemini/32.png)

모든 설정을 끝내면 프롬포트 요청에 대해서 응답하는 gemini 챗봇 시스템을 간단하게 만들수 있습니다. <br/>
감사합니다.

[전체코드 보러가기 >>](https://github.com/sgd122/nextjs-with-gemini)