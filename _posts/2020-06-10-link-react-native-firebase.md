---
layout: post
title: "React Native - Firebase"
author: Gidong
categories: [React Native]
tags: [Developer, Firebase]
image: assets/images/link-react-native-firebase/reactnative.jpg
# rating: 4.5
sitemap:
  changefreq: daily
  priority: 1.0
---

[React Native 개발 도전 - 생성된 프로젝트에 Firebase 연동하기 (2)](http://cheonbrave.blogspot.com/2018/04/react-native-firebase-2.html)

- 1. ios 파이어베이스 연동

  - 맥에서 터미널 실행후 프로젝트 경로로 이동

  1강에서 생성한 프로젝트 폴더가 있을것이다

  예상되는 경로는.. /Users/{username}/myapp 정도 ?

  - 아래 명령 수행

  npm install --save react-native-firebase

  - 다운받은 GoogleService-Info.plist 파일은 프로젝트폴더/ios/앱이름/ 하위에 저장

  - ios 디렉토리에 있는 myapp.xcodeproject 를 더블클릭해서 xcode 실행

  - 저장했던 GoogleService-Info.plist 파일을 xcode 의 Info.plist 가 있는 같은경로에 add

  - 아래 이미지에서 보여지는것처럼 타겟이 여러게 있을탠데 tvOS, tvOSTests에 해당하는것들은 우클릭후 제거해주자

  ![https://4.bp.blogspot.com/-X-wkH85bQKc/Wt_OlNXXzBI/AAAAAAAASjM/_mDKmJOPNToQWO4z4kh69SSKnU9awdmugCLcBGAs/s320/123.png](https://4.bp.blogspot.com/-X-wkH85bQKc/Wt_OlNXXzBI/AAAAAAAASjM/_mDKmJOPNToQWO4z4kh69SSKnU9awdmugCLcBGAs/s320/123.png)

  - AppDelegate.m open

  - 아래 코드 작성

  #import <Firebase.h>

  didFinishLaunchingWithOptions:(NSDictionary \*)launchOptions 함수 안에

  [FIRApp configure]; 작성 (주의 : RTCview 관련 내용보다 위에 작성해야함)

  - xcode 종료

  - 터미널을 열고 아래위치에 해당하는 경로로 이동

  cd /Users/~~/프로젝트명/ios/

  - pod init 수행

  : Podfile 생성됨

  - Podfile 이 생성되어있을것이다, vi Podfile 명령으로 파일을 열고 아래내용 작성

  platform :ios, '9.0' <<< # 으로 주석처리되어있을탠데 주석해제

  pod 'Firebase/Core' <<< 가장 하단에 아래 명령줄을 추가

  - /Users/~~/프로젝트명/ios/ 경로에서 pod install 명령 수행

  : 프로젝트명.xcodeproj 외에 프로젝트명.xcworkspace 가 생겼을것이다 앞으로는 프로젝트명.xcworkspace로 열도록 하자

- 2. Android 파이어베이스 연동
