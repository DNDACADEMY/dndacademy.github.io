---
layout: post
title: "타입스크립트의 기본타입"
author: Gidong
categories: [TypeScript]
tags: [React.JS, javascript]
image: assets/images/typescript-default-type/main.jpeg
sitemap:
  changefreq: daily
  priority: 1.0
---

가장 기본이 되는 타입들에 대해 알아봅니다.  
타입스크립트 공식문서를 참조하여 타입스크립트의 가장 기본이 되는 타입들에 대해 알아보겠습니다.

## boolean

true 혹은 false 값의 타입입니다.

```javascript
const isAvailable: boolean = true;
```

## number

숫자 값을 나타내는 타입입니다.

```javascript
const numberOfPeople: number = 100;
```

숫자의 타입은 한 가지이기 때문에 소숫점을 포함한 것, 큰 숫자 등에 관계 없이 모두 number 타입을 사용합니다.

```javascript
const largeNumber: number = 9007199254740991;
const pi: number = 3.14;
```

참고로 숫자 값에 대해서 numeric separator도 지원합니다.

```javascript
const population: number = 50_000_000;
```

## string

문자열에 대한 타입입니다.

```javascript
const hello: string = "world";
const world: string = "hello";
```

**single quote**과 **double quote**은 기능적으로 동일하므로 같은 `string`타입을 사용합니다.  
**template literal**로 생성된 문자열 또한 `string` 타입이됩니다.

```javascript
const greeting: string = `Welcome ${user}, to our web site!`;
```

## array

배열에 대한 타입입니다. 배열은 다른 타입들을 원소로 가지는 타입인데 두 가지 방법으로 표현할 수 있습니다.

```javascript
const animals: string[] = ["cat", "dog", "cow"];
```

혹은,

```javascript
const animals: Array<string> = ["cat", "dog", "cow"];
```

**Array**로 표현하는 방식은 보통 표현할 타입이 복잡할 때 많이 사용합니다.

```javascript
const users: Array<{ name: string, age: number }> = [
  {
    name: "John",
    age: 23,
  },
  {
    name: "Jane",
    age: 24,
  },
];
```

만약 2차원 배열을 만든다면 이렇게 표현할 수 있습니다.

```javascript
const matrix: number[][] = [
  [1, 2, 3],
  [4, 5, 6],
];
```

## tuple

투플은 원소의 갯수가 정해진 배열의 타입입니다.  
배열은 한 가지 타입의 원소가 무한하게(?) 포함될 수 있음을 표시하는데 반해 투플은 정해진 위치에 갯수 만큼의 원소를 표시하는데 사용합니다.

```javascript
const countAndNames: [number, string, string, string] = [
  3,
  "James",
  "Jane",
  "John",
];
```

혹은 아래와 같이 표현하는 것도 가능합니다.

```javascript
const countAndNames: [number, ...string[]] =
  [3, "James", "Jane", "John"];
```

물론 아래와 같이 표현했을 때는 계속해서 string 타입의 값을 추가할 수 있습니다.

```javascript
const countAndNames: [number, string, string, string] =
  [3, "James", "Jane", "John", "Jason"]; // 길이가 맞지 않는다는 에러 발생
const countAndNames: [number, ...string[]] =
  [3, "James", "Jane", "John", "Jason"]; // OK
```

인덱스를 통해 접근할 때는 튜플을 통해 정의된 타입에 대해서는 해당 타입을 나타내지만 그 범위를 벗어났을 때는 튜플 내 타입들의 유니온타입으로 표시해줍니다.

```javascript
const countAndNames: [number, string, string, string] = [
  3,
  "James",
  "Jane",
  "John",
];
countAndNames.push("Jason");
const string = countAndNames[3]; // string 타입
const numberOrString = countAndNames[4]; // number | string 타입
```

## enum

enum은 자바스크립트에는 없는 데이터 타입으로서 특정 값들을 묶어서 관리할 수 있으며 아래와 같이 정의하고 사용할 수 있습니다.

```javascript
enum Color {
  Red,
  Green,
  Blue
}
let c: Color = Color.Green;
```

이때 c의 타입은 Color가 되며 c에 저장되는 값은 숫자 1이 됩니다.
만약 첫 요소가 1부터 시작하도록 하고 싶다면,

```javascript
enum Color {
  Red = 1,
  Green,
  Blue
}
let c: Color = Color.Green; // 2
```

와 같이 임의로 시작 값을 정할 수 있습니다.
또한 역으로 인덱스로 값을 가져올 수 있습니다.

```javascript
enum Color {
  Red,
  Green,
  Blue
}
const firstColor = Color[0]; // 타입은 string, 값은 "Red"
```

필요에 따라 인덱스가 아닌 문자열을 이용해 enum을 만들 수도 있습니다.

```javascript
enum Color {
  Red = "RED",
  Green = "GREEN",
  Blue = "BLUE"
}
let c: Color = Color.Green; // GREEN
```

## any

타입스크립트의 타입 체킹 시스템은 서로 호환되지 않는 두 타입의 사용을 방지해줍니다.

```javascript
let myNumber: number = 10;
myNumber = "Hello"; // Hello를 number 타입에 할당할 수 없다는 에러 발생
```

그런데 어떤 때는 해당 값의 타입을 모르거나 혹은 여러 가지 타입이 모두 허용되도록 하고 싶을 수 있습니다. 그럴 때 any를 사용할 수 있습니다.

```javascript
let myNumber: any = 10;
myNumber = "Hello"; // no error
```

any는 주로 타입 정보가 없는 외부 라이브러리에 대한 타이핑하거나 혹은 자바스크립트와 타입스크립트를 혼용할 때 유용합니다.
any를 남용하면 코드 분석에 타입체킹의 도움은 받을 수 없으므로 주의해야 합니다.

## unknown

역시 any와 비슷하게 현재 타입 정보를 모를 때 사용합니다.  
any와의 차이점은 해당 값을 사용할 때 타입을 확인해야 한다는 점입니다.  
any의 경우 아래의 예시가 가능합니다만,

```javascript
const printOut = (message: string) => {
  console.log(message);
}
const anyValue: any = "Hello";
printOut(anyValue); // no error
unknown은 불가능합니다.
const printOut = (message: string) => {
  console.log(message);
}
const unknownValue: unknown = "Hello";
printOut(unknownValue); // unknown 타입을 string 타입에 사용할 수 없다는 에러
대신 unknown 타입의 값이 사용 될 때 타이핑 정보를 제공해주어야 합니다.
if (typeof unknownValue === 'string') {
  printOut(unknownValue);
}
```

혹은 아래와 같이 강제로 지정해주는 것도 가능합니다.

```javascript
printOut(unknownValue as string);
void
void는 어떤 타입과도 호환되지 않는 타입입니다. 주로 반환값이 없는 함수의 반환값에 대한 타이핑에 사용됩니다.
const printOut = (message: string): void => {
  console.log(message);
}
```

void로 타이핑된 변수에는 undefined만 할당할 수 있으므로 변수의 타이핑에는 거의 사용되지 않습니다.

## null과 undefined

null과 undefined 타입은 자바스크립트에 있는 각각의 값에서 가져온 타입입니다.  
역시 자기 자신 이외에는 할당할 수 없기 때문에 변수 할당에는 거의 쓰이지 않습니다.

```javascript
let undefinedValue: undefined;
undefinedValue = "Hello"; // Hello를 undefined에 할당할 수 없음
```

그런데 옵션에 따라 null은 다른 타입의 서브타입처럼 동작하게 할 수 있습니다. 만약 strictNullChecks = false인 경우,

```javascript
let myString: string = "Hello";
myString = null; // no error
```

와 같이 어떤 값이든 null로 만드는 것이 가능합니다.

## never

never는 어떤 타입과도 호환되지 않는 타입입니다. 논리적으로 끝까지 실행될 수 없는 함수의 반환 값은 never타입이 됩니다.

```javascript
const alwaysError = (): never => {
  throw new Error("Always error here");
};
```

if문 등으로 경우의 수가 좁혀진 변수의 경우 never타입이 될 수 있습니다.

```javascript
const handleMultitypeValue = (myValue: string | number) => {
  if (typeof myValue === "string") {
    console.log("string:", myValue);
    return;
  }
  if (typeof myValue === "number") {
    console.log("number:", myValue);
    return;
  }
  return myValue; // never
};
```

## object

object는 프로퍼티에 관계 없이 임의의 자바스크립트 오브젝트를 가리키기 위해 사용합니다.

```javascript
const handleObject = (passedObject: object) => {
  // passedObject를 사용
};
handleObject({ hello: "World" });
```

## 타입 단언(type assertion)

대개의 경우에는 타입스크립트 컴파일러의 타입 추론(type inerence) 결과를 받아 들이고 이를 사용하여 프로그래밍을 할 수 있지만 컴파일러에게 제공된 타이핑 정보가 부족하다던가 혹은 타입스크립트의 기능상 한계 때문에 컴파일러의 제안을 무시하고 타입을 강제로 지정(type assertion)해야 할 때도 있습니다.
타입 단언을 하는 방법은 두 가지가 있습니다만,

```javascript
<string>myValue.toLowerCase();
(myValue as string).toLowerCase();
```

jsx에서는 <string>과 같은 문법은 사용할 수 없습니다.
