---
layout: post
title: "Django 템플릿에 대해서 알아보자"
author: Gidong
categories: [Django]
tags: [파이썬, Template, 템플릿, python]
image: assets/images/django-template/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

Web 프레임 워크 인 Django는 HTML을 동적으로 생성하는 편리한 방법이 필요합니다. 가장 일반적인 방법은 템플릿에 의존하고 있습니다. 템플릿에 원하는 HTML 출력의 정적 부분과 동적 콘텐츠를 삽입하는 방법을 설명하는 특별한 구문이 포함되어 있습니다. 템플릿을 사용하여 HTML 페이지를 작성하는 실무 예제는 튜토리얼 3을 참조하십시오.

Django 프로젝트는 하나 이상의 템플릿 엔진에서 구성 할 수 있습니다 (템플릿을 사용하지 않는 경우는 제로로 구성 할 수도 있습니다). Django는 Django 템플릿 언어 (DTL)이라는 고유의 템플릿 시스템과 인기있는 대체 Jinja2의 내장 백엔드가 포함되어 있습니다. 다른 템플릿 언어의 백엔드는 타사에서 구할 수 있습니다. 사용자 정의 백엔드를 만들 수 있습니다. 사용자 정의 템플릿 백엔드를 참조하십시오.

Django는 백엔드에 관계없이 템플릿을 로드하고 렌더링하기 위한 표준 API를 정의하고 있습니다. 로드는 특정 식별자의 템플릿을 찾아 전처리 일반적으로 메모리의 표현에 컴파일하는 것으로 구성됩니다. 렌더링은 템플릿을 컨텍스트 데이터 보간 결과의 캐릭터 라인을 돌려주는 것을 의미합니다.

Django 템플릿 언어는 Django 자체 템플릿 시스템입니다. Django 1.8까지 사용 가능한 유일한 임베디드 옵션이었습니다. 꽤 의견이 몇 가지 특이 사항이 있지만 뛰어난 템플릿 라이브러리입니다. 다른 백엔드를 선택하는 절박한 이유가없는 경우, 특히 플러그 가능 응용 프로그램을 작성하고 템플릿을 배포하려는 경우 DTL을 사용해야합니다. django.contrib.admin 등의 템플릿을 포함 Django의 contrib 앱은 DTL을 사용합니다.

역사적인 이유로 템플릿 엔진의 일반 지원과 Django 템플릿 언어의 구현이 모두 django.template 네임 스페이스에 존재합니다.

## 변수

변수는 문맥에서 값을 출력합니다. 이것은 키를 값에 매핑하는 dict 같은 개체입니다.

변수는 다음과 같이 {{ 와 }}로 묶여 있습니다.

```python
My first name is { { first_name } }. My last name is { { last_name } }.
```

화면출력 ->

```python
My first name is John. My last name is Doe.
```

## 태그

태그는 렌더링 과정에서 어떤 논리를 제공합니다.

이 정의는 의도적으로 모호합니다. 예를 들어, 태그는 컨텐츠를 출력 할 수 있는 제어 구조로 작동합니다. "if"문 또는 "for"루프 데이터베이스에서 콘텐츠를 검색하거나 다른 템플릿 태그에 대한 액세스를 활성화 할 수 있습니다.

태그는 다음과 같이 묶여 있습니다.

```python
{ % cycle 'odd' 'even' %}
```

```python
{ % if user.is_authenticated % }Hello, { { user.username } }.{ % endif % }
```

## 필터

필터는 변수와 태그 인수 값을 변환합니다.

다음과 같이 정의를 하였을 경우에 대해서 살펴보자.:

```python
{ { django|title } }
```

**{'django': 'the web framework for perfectionists with deadlines'}**, <- 와 같이 변수가 넘어왔을 경우 아래와 같이 출력된다.

```python
The Web Framework For Perfectionists With Deadlines
```

일부 필터는 인수가 존재합니다. (아래는 날짜에 대한 필터)

```python
{ { my_date|date:"Y-m-d" } }
```

## 코멘트

코멘트는 다음과 같이 입력합니다.

```python
{# this won't be rendered #}
```
