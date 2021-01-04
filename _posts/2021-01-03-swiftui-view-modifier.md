---
layout: post
title: "SwiftUI의 ViewModifier"
author: Cheolwoo
categories: [SwiftUI]
tags: [IOS, Swift]
image: assets/images/swiftui-view-modifier/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

> SwiftUI의 ViewModifier가 무엇인지 알아보자.

# 1. ViewModifier란?

> A modifier that you apply to a view or another view modifier, producing a different version of the original value.

- 애플 공식문서에 따르면, SwiftUI 프레임워크에 내장되어있는 한 프로토콜이고, 기존의 뷰 또는 다른 view modifier에 적용시켜 또 다른 버전을 만들 수 있는 modifier이다.

- 다시 말해, 기존에 생성한 뷰 또는 modifier에 추가적으로 꾸며줄 수 있는 것이다.

## 2. ViewModifier 구현

- [공식문서](https://developer.apple.com/documentation/swiftui/viewmodifier)를 보면 Overview에 구현하는 방법이 나와있다.
- iOS 플랫폼으로 SwiftUI프로젝트를 생성한 후에 간단하게 Text에 적용할 ViewModifier를 만들어보자.
- **TextModifier.swift**라는 파일을 생성해주고, 물론 SwiftUI를 사용하기 위해 **import SwiftUI**를 해준 뒤에 ViewModifier를 채택한 구조체를 선언해준다.
- 이후 에러메세지를 볼 수 있을텐데, 이는 해당 프로토콜에서 선언된 뷰를 생성해주는 body가 없거나, Content가 없어서 발생하는 오류이기 때문에 구조체 내에 body를 입력하면 자동완성으로 나타나는 메소드를 입력해주자.
  ```Swift
  struct TextModifier: ViewModifier {
      
      func body(content: Content) -> some View {
          
      }
      
  }
  ```
- 이후 **some View** 타입을 반환해주어야하는데, 자동완성 된 메소드의 파라미터를 보면 **content: Content**가 있다. 이 파라미터가 Modifier가 적용될 뷰를 불러온다.
- 간단하게 폰트와 색상만 변경해보고자 하는데 아래와 같이 content 이후에 스타일링을 해주면 된다.
  ```Swift
  /*
    TextModifier.swift
  */
  func body(content: Content) -> some View {
    content
      .font(.system(size: 22, weight: .bold, design: .default))
      .foregroundColor(.orange)
  }
  ```

## 3. ViewModifier 적용

- 간단한 Modifier를 작성했으면 다시 **ContentView.swift**로 돌아와 Hello World!라고 기존에 자동 생성된 텍스트에 Modifier를 적용해보자.
- 적용 방법은 아래처럼 View 뒤에 **.modifier(modifier: T)**를 작성해주면 된다.
  ```Swift
  struct ContentView: View {
    var body: some View {
      Text("Hello, world!")
        .modifier(TextModifier())
    }
  }
  ```

## 4. 적용 전 / 후

<center>
<img src="../assets/images/swiftui-view-modifier/01.png" width=300>
&nbsp;
&nbsp;
<img src="../assets/images/swiftui-view-modifier/02.png" width=300>
</center>
<br>

## 5. 마치면서

- 최근 SwiftUI로만 개발을 진행하면서 불편한 것도 많지만, 그 불편함에 비해 편한 것이 더 많다고 느끼고 있는 중이다.
- 물론 WKWebView, Delegate Pattern 등을 사용해야 할 상황이 필요할 경우가 아직은 많기 때문에 UIKit에 대한 학습 또한 많이 필요한 것은 사실이고, 이에 대한 대응책으로 Apple이 Representable 프로토콜 및 Coordinator Instance를 만들어 두었으며, 위 기능들을 SiwftUI 버전 업데이트를 통해 추가로 내놓지 않을 것으로 보이지만, SwiftUI로 개발을 하다 보면 UIKit에 대한 지식과 존재감을 잊어버릴 정도로 너무 편하게 사용하고 있다.
- 더불어 스크롤뷰, Constraints, Auto Layout 등에 대한 코드의 양도 확실히 줄어들 뿐만 아니라 보기도 편해 졌다고 느끼고 있고, 짜증났던 Constraints에 대한 Conflict를 못 보게 되었다. 또한, 필수적으로 사용할 수 밖에 없었던 ViewController가 필요 없어지면서 확실한 MVVM 아키텍처 등의 적용이 가능해졌다고 생각한다.


### 예제 프로젝트
- [GitHub](https://github.com/aaronLab/swiftui-exercise/tree/main/ViewModifierExample)
- [.zip](https://downgit.github.io/#/home?url=https://github.com/aaronLab/swiftui-exercise/tree/main/ViewModifierExample)
