---
layout: post
title: "Python 데코레이터(Decorator)"
author: Gidong
categories: [python]
tags: [파이썬, decorator, 장식자]
image: assets/images/python-decorator/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

## 의미파악

사전적 의미로는 "장식가" 또는 "인테리어 디자이너" 등의 의미를 가지고 있습니다.  
이름 그대로, 기존의 코드에 여러가지 기능을 추가하는 파이썬 구문입니다.
아래는 python 공식문서의 내용입니다.

```
decorator (데코레이터)

다른 함수를 돌려주는 함수인데, 보통 @wrapper 문법을 사용한 함수 변환으로 적용됩니다.
데코레이터의 흔한 예는 classmethod() 과 staticmethod() 입니다.

데코레이터 문법은 단지 편의 문법일 뿐입니다. 다음 두 함수 정의는 의미상으로 동등합니다:
```

```python
def f(...):
    ...
f = staticmethod(f)

@staticmethod
def f(...):
    ...
```

```
같은 개념이 클래스에도 존재하지만, 덜 자주 쓰입니다.
데코레이터에 대한 더 자세한 내용은 함수 정의 와 클래스 정의 의 설명서를 보면 됩니다.
```

## Decorator는 어떤 경우에 쓰는건가?

메인이 되는 함수가 있고, 여기에 부가적인 함수를 추가하고 싶을때 사용합니다.
그리고 이 부가적인 함수를 반복해서 사용하고 싶은 경우도 있습니다.
이때 부가적인(그리고 반복적인) 작업을 decorator 로 선언해서 자유롭게 사용이 가능합니다.

## 데코레이터의 구조

#### 함수형

함수로 만드는 데코레이터는 일반적으로 아래와같은 구조를 가지고 있습니다.

```python
def out_func(func):  # 기능을 추가할 함수를 인자로

    def inner_func(*args, **kwargs):

        return func(*args, **kwargs)

    return inner_func
```

example.py

```python
def base(base_number):
    def wrap(fn):
        def inner(x, y):
            return fn(x, y) + base_number
        return inner
    return wrap

@base(100)
def mysum3(x, y):
    return x + y

mysum3(1, 2)
```

다음과 같이 @ + 감싸주는 함수이름을 함수 위에 적어줄 경우, 위와 같은 효과를 가져 올 수 있습니다.

복잡한 코드가 여러 함수에 중복적으로 들어가야할 경우 decorator 를 통해서 단순화 해 줄 수 있습니다.

#### 설명

1. `wrap`가 함수(mysum3)를 fn이라는 이름으로 받아줍니다.
2. `inner`에서 fn(x,y)에다가 `base`에서 받았던 **base_number**를 더해서 return 해줍니다.
3. 그 결과, @base에 원하는 숫자를 작성후 mysum에 인자를 넣어서 호출하면 @base에 작성한 값과 x,y의 값을 더해서 호출됩니다.

---

#### 클래스형

클래스로 만드는 데코레이터 구조는 다음과 같습니다

```python
class Decorator:

    def __init__(self, function):
        self.func = function

    def __call__(self, *args, **kwargs):
        return self.func(*args, **kwargs)
```

example.py

```python
class Decorator:

    def __init__(self, function):
        self.func = function

    def __call__(self, *args, **kwargs):
        print('작업전')
        print(self.func(*args, **kwargs))
        print('작업후')
@Decorator
def example():
    return '함수실행'
example()
'''''''''
작업전
함수실행
작업후
'''''''''
```

---

#### @classmethod란?

메서드를 클래스 메서드로 변환합니다.

인스턴스 메서드가 인스턴스를 받는 것처럼, 클래스 메서드는 클래스를 묵시적인 첫 번째 인자로 받습니다. 클래스 메서드를 선언하려면 이 관용구를 사용합니다:

```python
class C:
    @classmethod
    def f(cls, arg1, arg2, ...): ...
@classmethod 형식은 함수 데코레이터 입니다 – 자세한 내용은 함수 정의를 보세요.
```

클래스 메서드는 클래스 (C.f() 처럼) 또는 인스턴스 (C().f() 처럼) 를 통해 호출할 수 있습니다. 인스턴스는 클래스만 참조하고 무시됩니다. 파생 클래스에 대해 클래스 메서드가 호출되면, 파생 클래스 객체가 묵시적인 첫 번째 인자로 전달됩니다.

클래스 메서드는 C++ 또는 자바의 정적 메서드와 다릅니다. 그것들을 원하면, 이 섹션의 staticmethod()를 보세요. 클래스 메서드에 대한 더 자세한 정보는, 표준형 계층을 참고하세요.

버전 3.9에서 변경: 클래스 메서드는 이제 property()와 같은 다른 디스크립터를 래핑 할 수 있습니다.

#### @staticmethod란?

메서드를 정적 메서드로 변환합니다.

정적 메서드는 묵시적인 첫 번째 인자를 받지 않습니다. 정적 메서드를 선언하려면, 이 관용구를 사용하세요:

```python
class C:
    @staticmethod
    def f(arg1, arg2, ...): ...
```

@staticmethod 형식은 함수 데코레이터 입니다 – 자세한 내용은 함수 정의를 보세요.

정적 메서드는 클래스 (C.f() 처럼) 또는 인스턴스 (C().f() 처럼)에 대해 호출할 수 있습니다.

파이썬의 정적 메서드는 자바 또는 C++ 에서 발견되는 정적 메서드와 비슷합니다. 대체 클래스 생성자를 만드는 데 유용한 변형을 보려면 classmethod() 도 보세요.

모든 데코레이터와 마찬가지로, staticmethod 를 정규 함수로 호출하여 그 결과로 어떤 일을 할 수도 있습니다. 이것은 클래스 바디에서 함수에 대한 참조가 필요하고 인스턴스 메서드로 자동 변환되는 것을 피하고자 할 때 필요합니다. 이 경우 다음 관용구를 사용하세요:

```python
class C:
    builtin_open = staticmethod(open)
```
