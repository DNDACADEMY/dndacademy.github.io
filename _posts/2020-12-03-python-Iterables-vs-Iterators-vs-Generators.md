---
layout: post
title: "Python Iterables vs Iterators vs Generators"
author: Gidong
categories: [python]
tags: [파이썬, Iterables, Iterators, Generators]
image: assets/images/python-Iterables-vs-Iterators-vs-Generators/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

파이썬에서 다음과 같은 개념들간의 차이점에 대해서 알아보자.

- 컨테이너 (Container)
- 이터레이블 (Iterable)
- 이터레이터 (Iterator)
- 제너레이터 (Generator)
- 제너레이터 표현식 (Generator expression)
- {list, set, dict} 컴프리헨션 ({list, set, dict} comprehension)

### 컨테이너 (Container)

1. 컨테이너(Container)는 원소들을 가지고 있는 데이터 구조
2. 메모리에 상주하는 데이터 구조로, 보통 모든 원소값을 메모리에 가지고 있다.
3. 기술적으로, 어떤 객체가 특정한 원소를 포함하고 있는지 아닌지를 판단할 수 있으면 컨테이너라고 한다.

- 컨테이너의 종류
  - list, deque, …
  - set, frozonset, …
  - dict, defaultdict, OrderedDict, Counter, …
  - tuple, namedtuple, …
  - str

### 이터레이블 (Iterable)

1. 반복 가능한 객체
2. 이터레이블은 무한한 데이터 소스를 나타낼 수도 있다.
3. 대표적으로 iterable한 타입 - list, dict, set, str, bytes, tuple, range
4. 컨테이너는 또한 이터레이블(iterable)하다.
5. 반드시 데이터 구조일 필요는 없다.

### 이터레이터 (Iterator)

1. 값을 차례대로 꺼낼 수 있는 객체입니다.
2. 일부는 무한 시퀀스를 생성한다.

- 파이썬 내장함수 iter()를 사용해 iterator 객체를 만들어봅니다. REPL을 실행합니다.

```python
>>> a = [1, 2, 3]
>>> a_iter = iter(a)
>>> type(a_iter)
<class 'list_iterator'>
```

- iterable객체는 매직메소드 __iter__ 메소드를 가지고 있습니다. 이 메소드로 iterator를 만들어보겠습니다

```python
>>> b = {1, 2, 3}
>>> dir(b)
['__and__', '__class__', '__contains__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__iand__', '__init__', '__init_subclass__', '__ior__', '__isub__', '__iter__', '__ixor__', '__le__', '__len__', '__lt__', '__ne__', '__new__', '__or__', '__rand__', '__reduce__', '__reduce_ex__', '__repr__', '__ror__', '__rsub__', '__rxor__', '__setattr__', '__sizeof__', '__str__', '__sub__', '__subclasshook__', '__xor__', 'add', 'clear', 'copy', 'difference', 'difference_update', 'discard', 'intersection', 'intersection_update', 'isdisjoint', 'issubset', 'issuperset', 'pop', 'remove', 'symmetric_difference', 'symmetric_difference_update', 'union', 'update']
>>> b_iter = b.__iter__()
>>> type(b_iter)
<class 'set_iterator'>
```

- iterator가 값을 차례대로 꺼낼 수 있는 객체라는 것의 의미를 한번 코드로 살펴봅니다.
- next내장함수를 사용할때 마다 첫번째, 두번째, 세번째 값이 출력됩니다.
- 네번째 실행에서는 StopIteration 이라는 예외가 발생합니다.

```python
>>> next(a_iter)
1
>>> next(a_iter)
2
>>> next(a_iter)
3
>>> next(a_iter)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

- iterator 매직 메소드 'next'를 통해 하나씩 값을 꺼내봅니다.

```python
>>> b_iter.__next__()
1
>>> b_iter.__next__()
2
>>> b_iter.__next__()
3
>>> 
```

### 제너레이터 (Generator)

1. 특별한 종류의 이터레이터이다.
2. 모든 제너레이터는 이터레이터이다 (그 반대는 성립하지 않는다)
3. 모든 제너레이터는 게으른 팩토리이다 (즉, 값을 그 때 그 때 생성한다)

`yield` - 사용하면 값을 함수 바깥으로 전달하면서 코드 실행을 함수 바깥에 양보합니다. 따라서 yield는 현재 함수를 잠시 중단하고 함수 바깥의 코드가 실행되도록 만듭니다.


[참조글]
- [[번역] 이터레이터와 제너레이터](https://mingrammer.com/translation-iterators-vs-generators/)