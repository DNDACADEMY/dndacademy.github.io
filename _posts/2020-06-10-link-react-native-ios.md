---
layout: post
title: "React-Native 초기 세팅"
author: Gidong
categories: [React Native]
tags: [Developer]
image: assets/images/link-react-native-ios/reactnative2.jpeg
# rating: 4.5
sitemap:
  changefreq: daily
  priority: 1.0
---

공식문서 Getting Started의 Xcode & CocoaPods 단계까지 설정한 후 진행하시면 됩니다.

[Getting Started · React Native](https://facebook.github.io/react-native/docs/getting-started)

## 1. RN Project 생성

프로젝트를 생성해 봅시다. 공식 문서에는 **npx react-native init AwesomeProject 를 쓰라고 나와있지만**

저는 react-native init 명령어를 통해 생성하겠습니다. ( 이미 react-native가 설치 되어 있기 때문입니다.)

```bash
react-native init test_rn

cd test_rn

react-native run-ios
```

![/assets/images/link-react-native-ios/Untitled.png](/assets/images/link-react-native-ios/Untitled.png)

시뮬레이터에 정상적인 화면이 나온다면 bundle server와 시뮬레이터를 끄고 다시 진행합니다.

![/assets/images/link-react-native-ios/2020-02-21__3.01.09.png](/assets/images/link-react-native-ios/2020-02-21__3.01.09.png)

프로젝트 구조는 위와 같이 구성합니다.

## 2. React Navigation 구축

SPA인 리액트의 특성상 Routing을 위해선 다른 라이브러리가 필요합니다.

대표적인 라이브러리로는 [React Native Navigation](https://github.com/wix/react-native-navigation)과 [React Navigation](https://reactnavigation.org/)이 있습니다. 저희는 R-Nav를 사용합니다. 이유는

1. 가장 널리 사용 되고 활발하게 개발 된 라이브러리

2. React Native팀이 권장 하는 솔루션

3. Facebook이 가장 많이 추진하는 커뮤니티 솔루션

[React Navigation · Routing and navigation for your React Native apps](https://reactnavigation.org/)

공식 문서의 Getting started를 그대로 진행 합니다.

```bash
npm install @react-navigation/native
npm install react-native-reanimated react-native-gesture-handler
	react-native-screens react-native-safe-area-context
	@react-native-community/masked-view
```

예전에는 하나의 Package였지만, 버전이 올라감에 따라 나눠 지게 되어서 설치 과정이 늘어났습니다.

npm이 다 되고 나면 linking을 해야 합니다. RN 0.6x 버전 이상부터는 Auto Linking을 지원하기 때문에 link 과정이 필요 없고 아래 처럼 진행하면 됩니다.

### IOS

```bash
cd ios; pod install; cd ..
```

### Android

android/app/build.gradle 파일에 추가

```java
implementation 'androidx.appcompat:appcompat:1.1.0-rc01'
implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0-alpha02'
```

여기 까지 진행 후 실행을 해보시면 정상적으로 작동이 됩니다.

## 3. Stack, Bottom Tab, Drawer Navigation

R-Nav 업데이트로 인해 기존에 포함되어 있던 Stack과 Bottom Tab, Drawer Navigation들도 따로 설치 해 야 합니다.

```bash
npm install @react-navigation/bottom-tabs
npm install @react-navigation/stack
npm install @react-navigation/drawer
```

## 4. Navigation Example

지금부터 Bottom Tab과 Drawer Menu를 가진 Stack App을 하나 생성 해보겠습니다.

밑에 예제는 router.js 파일로 관리 하는 방법입니다.

```jsx
// App.js

import * as React from "react";
import Router from "./src/settings/router";

export default function App() {
  return (
    <>
      <Router />
    </>
  );
}
```

```jsx
// src/settings/router.js

import * as React from "react";
import { Button, View, Text } from "react-native";
import { createStackNavigator } from "@react-navigation/stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createDrawerNavigator } from "@react-navigation/drawer";
import { NavigationContainer } from "@react-navigation/native";

const Stack = createStackNavigator();
const Drawer = createDrawerNavigator();
const Tab = createBottomTabNavigator();

function SplashScreen({ navigation }) {
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Button
        onPress={() => navigation.navigate("Drawer")}
        title="Main으로 이동"
      />
    </View>
  );
}

function HomeScreen({ navigation }) {
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Button
        onPress={() => navigation.navigate("Notifications")}
        title="다른 화면으로 이동"
      />
    </View>
  );
}

function NotificationsScreen({ navigation }) {
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Button onPress={() => navigation.navigate("Tab")} title="Go back home" />
    </View>
  );
}

function SettingsScreen() {
  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <Text>Settings!</Text>
    </View>
  );
}

function MyDrawer() {
  return (
    <Drawer.Navigator>
      <Stack.Screen name="Tab" component={MyTab} />
      <Drawer.Screen name="SettingsScreen" component={SettingsScreen} />
    </Drawer.Navigator>
  );
}

function MyTab() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

export default function Router() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Notifications" component={NotificationsScreen} />
        <Stack.Screen name="Tab" component={MyTab} />
        <Stack.Screen name="Drawer" component={MyDrawer} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

구체적인 사용법 ( Header, Tab icon 등)은 공식 문서를 참고하시면 됩니다.

## 5. MobX

windevel에서는 상태 관리 라이브러리로 mobx를 사용하고 있습니다.

지금부터는 test app에 mobx를 적용하여 상태 관리를 해보도록 하겠습니다.

[Introduction · MobX](https://mobx.js.org/README.html#getting-started)

```bash
npm install mobx --save
npm install mobx-react --save
npm install @babel/plugin-proposal-decorators --save
```

mobx와 mobx-react를 설치합니다.

plugin-proposal-decorators를 설치하는 이유는 decorator문법으로 편하게 사용하기 위해서 입니다.

babel.config.js 파일을 아래와 같이 수정합니다.

```jsx
module.exports = {
  presets: ["module:metro-react-native-babel-preset"],
  plugins: [
    [
      "@babel/plugin-proposal-decorators",
      {
        legacy: true,
      },
    ],
  ],
};
```

settings 폴더 밑에 stores 폴더를 만듭시다.

```bash
mkdir stores
cd stores
```

stores 폴더 밑에 index.js , user.js 파일을 만들어서 간단한 유저 정보를 만듭시다.

```jsx
// index.js
import UserStore from "./user";

class RootStore {
  constructor() {
    this.userStore = new UserStore(this);
  }
}

export default new RootStore();
```

```jsx
// user.js
import { observable, action } from "mobx";

export default class UserStore {
  constructor(rootStore) {
    this.rootStore = rootStore;
  }

  @observable user_name = "김한솔";

  @action
  userNameChange(data) {
    this.user_name = data;
  }
}
```

App.js 를 Mobx Provider로 래핑해야 합니다.

```jsx
// App.js
import * as React from "react";
import Router from "./src/settings/router";
import { Provider } from "mobx-react";
import rootStore from "./src/settings/stores";

export default function App() {
  return (
    <Provider {...rootStore}>
      <Router />
    </Provider>
  );
}
```

이제 mobx를 쓰고 싶은 화면에서 mobx를 쓰면 됩니다.

Splash 화면을 router에서 빼서 새로 만듭시다.

데코레이터를 편하게 사용하기 위해 class component를 사용합니다.

```jsx
// pages/Splash.js

import React, { Component } from "react";
import { Button, View } from "react-native";
import { observer, inject } from "mobx-react";

@inject("userStore")
@observer
export default class SplashScreen extends Component {
  render() {
    return (
      <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
        <Button
          onPress={() => this.props.navigation.navigate("Drawer")}
          title="Main으로 이동"
        />
        <Button
          onPress={() => navigation.navigate("Notifications")}
          title={this.props.userStore.user_name}
        />
      </View>
    );
  }
}
```

router.js 파일도 아래와 같이 수정합니다.

```jsx
// router.js
import * as React from "react";
import { Button, View, Text } from "react-native";
import { createStackNavigator } from "@react-navigation/stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createDrawerNavigator } from "@react-navigation/drawer";
import { NavigationContainer } from "@react-navigation/native";

import SplashScreen from "../pages/Splash";

const Stack = createStackNavigator();
const Drawer = createDrawerNavigator();
const Tab = createBottomTabNavigator();
const Splash = SplashScreen;

function HomeScreen({ navigation }) {
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Button
        onPress={() => navigation.navigate("Notifications")}
        title="다른 화면으로 이동"
      />
    </View>
  );
}

function NotificationsScreen({ navigation }) {
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Button onPress={() => navigation.navigate("Tab")} title="Go back home" />
    </View>
  );
}

function SettingsScreen() {
  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <Text>Settings!</Text>
    </View>
  );
}

function MyDrawer() {
  return (
    <Drawer.Navigator>
      <Stack.Screen name="Tab" component={MyTab} />
      <Drawer.Screen name="SettingsScreen" component={SettingsScreen} />
    </Drawer.Navigator>
  );
}

function MyTab() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

export default function Router() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Splash" component={Splash} />
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Notifications" component={NotificationsScreen} />
        <Stack.Screen name="Tab" component={MyTab} />
        <Stack.Screen name="Drawer" component={MyDrawer} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

실행하면 mobx props를 확인할 수 있습니다.

![/assets/images/link-react-native-ios/Untitled%201.png](/assets/images/link-react-native-ios/Untitled%201.png)

버튼을 누르면 user_name이 바뀌게 해보겠습니다.

```jsx
<Button
  onPress={() => this.props.userStore.userNameChange("정기열")}
  title={this.props.userStore.user_name}
/>
```

버튼을 누르면 확인할 수 있습니다.

![/assets/images/link-react-native-ios/Untitled%202.png](/assets/images/link-react-native-ios/Untitled%202.png)

소스는 아래 리포지토리에서 확인이 가능합니다.

[hansol775/test_rn_app](https://github.com/hansol775/test_rn_app)
