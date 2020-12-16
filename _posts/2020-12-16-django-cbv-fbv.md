---
layout: post
title: "Django 클래스 기반 뷰(Class-Based Views) vs 함수 기반 뷰(Function-Based Views)"
author: Gidong
categories: [Django]
tags: [python, 파이썬, CBV, FBV, 장고]
image: assets/images/django-cbv-fbv/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

## 참조하기 좋은 사이트

- [ccbv](https://ccbv.co.uk/) : CBV에서 놓치기 쉬운 숨어있는 코드들에 대해서 확인이 가능하다.

---

> 이 글은 https://yuda.dev/245의 글을 가져왔습니다.

1. 클래스 기반 뷰(Class-Based Views)

클래스 기반 뷰이든 함수 기반 뷰이든 뷰가 실행하는 것은 함수이다.
우리가 View.as_view() 클래스 메소드를 사용하여 URL 정의에 뷰를 추가하면 이는 view라는 함수를 리턴한다.
as_view() 메소드가 어떻게 짜여 있는지 보자.

```python
class View:
    @classonlymethod
    def as_view(cls, **initkwargs):
        """Main entry point for a request-response process."""
        for key in initkwargs:
            # Code omitted for clarity
            # ...

        def view(request, *args, **kwargs):
            self = cls(**initkwargs)
            if hasattr(self, 'get') and not hasattr(self, 'head'):
                self.head = self.get
            self.request = request
            self.args = args
            self.kwargs = kwargs
            return self.dispatch(request, *args, **kwargs)
        # Code omitted for clarity
        # ...
        return view
```

따라서 클래스 기반 뷰를 직접 불러오고 싶다면 다음과 같이 하면 된다.

```python
return MyView.as_view()(request)
```

as_view() 메소드에 의해 리턴되는 view 함수는 dispatch() 메소드에 request를 전달한다.
그러면 dispatch() 메소드는 request 타입(GET, POST, PUT 등)에 따른 적합한 메소드를 실행한다.

만약 당신이 django.views.View 클래스를 상속받아 뷰를 생성한다면, dispatch() 메소드가 HTTP 메소드 로직을 처리할 것이다.
request가 POST라면 뷰 안에 있는 post() 메소드를 실행할 것이고, GET이라면 get() 메소드를 실행할 것이다.

views.py

```python
from django.views import View

class ContactView(View):
    def get(self, request):
        # Code block for GET request

    def post(self, request):
        # Code block for POST request
```

urls.py

```python
urlpatterns = [
    url(r'contact/$', views.ContactView.as_view(), name='contact'),
]
```

2. 함수 기반 뷰(Function-Based Views)

함수 기반 뷰는 django.views.View 클래스를 상속받는 대신, 직접 함수를 작성하여 request를 처리한다.
보통 @api_view()로 request 메소드가 무엇인지 명시해주고, 다수의 request 메소드를 사용할 경우 if 조건문으로 구분하여 처리한다.

views.py

```python
@api_view(['GET', 'POST'])
def contact(request):
    if request.method == 'POST':
        # Code block for POST request
    else:
        # Code block for GET request (will also match PUT, HEAD, DELETE, etc)
```

urls.py

```python
urlpatterns = [
    url(r'contact/$', views.contact, name='contact'),
]
```

이것이 함수 기반 뷰와 클래스 기반 뷰의 가장 큰 차이점이다.
이렇게 보면 함수 기반 뷰가 훨씬 간단해보여 이를 사용해야 할 것 같지만 클래스 기반 뷰에는 강력한 무기가 있다.
바로 제네릭 클래스 기반 뷰이다.

3. 제네릭 클래스 기반 뷰(Generic Class-Based Views)

제네릭 클래스 기반 뷰는 새로운 객체 생성, 폼 처리, 리스트 뷰, 페이징, 아카이브 뷰 등과 같은 웹 어플리케이션의 일반적인 사용 사례를 해결하기 위해 도입되었다.
이들은 Django 코어에 자리잡아 django.views.generic 모듈에 의해 구현된다.
이 기능은 매우 훌륭하며 개발 프로세스 속도를 높여준다. 사용가능한 뷰들의 목록은 다음과 같다.

```python
Simple Generic Views
- View
- TemplateView
- RedirectView

Detail Views
- DetailView

List Views
- ListView

Editing Views
- FormView
- CreateView
- UpdateView
- DeleteView

Date-Based Views
- ArchiveIndexView
- YearArchiveView
- MonthArchiveView
- WeekArchiveView
- DayArchiveView
- TodayArchiveView
- DateDetailView
```

장단점 비교

함수 기반 뷰

- 장점: 구현이 간단함, 읽기 편함, 직관적인 코드, 데코레이터 사용이 간단함

- 단점: 코드를 확장하거나 재사용하기 어려움, 조건문으로 HTTP 메소드 구분

(제네릭) 클래스 기반 뷰

- 장점: 코드를 확장하거나 재사용하기 쉬움, mixin(다중 상속) 같은 객체지향 기술을 사용할 수 있음, 분리된 메소드로 HTTP 메소드 구분, 내장 제네릭 클래스 기반 뷰

- 단점: 읽기 힘듦, 직관적이지 않은 코드, 부모 클래스/mixin에 숨어있는 코드들, 뷰 데코레이터를 사용하려면 따로 import를 하거나 메소드를 오버라이드 해야 함수

무엇이 더 좋고 나쁘고를 따지기보다는 상황에 맞게 사용하는 게 좋다. 예를 들어, 리스트 뷰를 구현할 때엔 ListView를 상속받고 어트리뷰트를 오버라이드하면 된다.
반면 여러 폼들을 한꺼번에 다뤄야 하는 복잡한 연산을 할 땐 함수 기반 클래스를 사용하면 된다.
