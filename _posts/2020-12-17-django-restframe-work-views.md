---
layout: post
title: "Django REST framework의 views에 대한 이해"
author: Gidong
categories: [Django]
tags: [python, 파이썬, CBV, FBV, 장고, DRF, django rest framework]
image: assets/images/django-restframe-work-views/main.jpg
sitemap:
  changefreq: daily
  priority: 1.0
---

# Class-based Views

REST framework는 Django의 View 클래스를 상속하는 **APIView** 클래스를 제공합니다.

**APIView** 클래스는 다음과 같은 점에서 일반 View 클래스와는 다릅니다.

- handler methods에 전달 된 요청은 Django의 HttpRequest 인스턴스가 아니라 REST framework의 Request 인스턴스입니다.
- handler methods는 Django의 HttpResponse 대신 REST framework의 Response를 return 할 수 있습니다. 보기는 컨텐츠 협상을 관리하고 응답에 올바른 renderer를 설정합니다.
- 모든 APIException 예외는 적절한 응답 중개됩니다.
- 들어오는 요청은 인증된 적절한 권한과 인증 체크가 실행 된 후 요청이 handler methods에 발송됩니다.

**APIView** 클래스의 사용은 일반 View 클래스의 사용과 거의 동일합니다. 일반적으로 들어오는 요청은 `.get()`과 `.post()` 등의 적절한 handler methods에 발송됩니다. 또한 API 정책의 다양한 측면을 제어하는 ​​여러 속성을 클래스로 설정할 수 있습니다.

For example:

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import authentication, permissions
from django.contrib.auth.models import User

class ListUsers(APIView):
    """
    View to list all users in the system.

    * Requires token authentication.
    * Only admin users are able to access this view.
    """
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAdminUser]

    def get(self, request, format=None):
        """
        Return a list of all users.
        """
        usernames = [user.username for user in User.objects.all()]
        return Response(usernames)
```

### API policy attributes

- .renderer_classes
- .parser_classes
- .authentication_classes
- .throttle_classes
- .permission_classes
- .content_negotiation_class

### API policy instantiation methods

- .get_renderers(self)
- .get_parsers(self)
- .get_authenticators(self)
- .get_throttles(self)
- .get_permissions(self)
- .get_content_negotiator(self)
- .get_exception_handler(self)

### API policy implementation methods

- .check_permissions(self, request)
- .check_throttles(self, request)
- .perform_content_negotiation(self, request, force=False)

### Dispatch methods

- .initial(self, request, \*args, \*\*kwargs)
- .handle_exception(self, exc)
- .initialize_request(self, request, \*args, \*\*kwargs)
- .finalize_response(self, request, response, \*args, \*\*kwargs)

---

# Function Based Views

REST framework를 사용하면 보통의 함수 기반의 뷰를 조작 할 수 있습니다. 함수 기반의 뷰를 래핑 (일반 Django HttpRequest 대신) Request의 인스턴스를 확실히 수신 (Django HttpResponse 대신) Response 메시지를 return 할 수 있도록하는 일련의 단순한 decorators를 제공하고 방법을 구성 할 수 있도록합니다.

## @api_view()

- Signature: @api_view(http_method_names=['GET'])

이 기능의 핵심은 api_view decorator입니다.
이것은 뷰가 응답해야하는 HTTP 메소드의 목록을 가져옵니다.
예를 들어, 이것은 수동으로 데이터를 return하는 매우 간단한 뷰를 만드는 방법입니다.

```python
from rest_framework.decorators import api_view

@api_view()
def hello_world(request):
    return Response({"message": "Hello, world!"})
```

이 뷰는 설정에서 지정된 기본 renderers, parsers, authentication 클래스 등을 사용합니다.

기본적으로 GET 메서드만 사용할 수 있습니다. 다른 방법은 "405 Method Not Allowed"라고 대답합니다. 이 동작을 변경하려면 다음과 같이 뷰에서 허용되는 메소드를 지정합니다.

```python
@api_view(['GET', 'POST'])
def hello_world(request):
    if request.method == 'POST':
        return Response({"message": "Got some data!", "data": request.data})
    return Response({"message": "Hello, world!"})
```

## API policy decorators

기본 설정을 재정의하기 위해 REST framework는 뷰에 추가 할 수 있는 일련의 추가 decorators를 제공합니다.
이들은 **@api_view**장식의 뒤에 와야합니다. 예를 들어, 특정 사용자가 하루에 한 번 밖에 호출 할 수 없도록하는 뷰를 작성하려면 @throttle_classes 장식을 사용하여 throttle 클래스의 목록을 전달합니다.

```python
from rest_framework.decorators import api_view, throttle_classes
from rest_framework.throttling import UserRateThrottle

class OncePerDayUserThrottle(UserRateThrottle):
    rate = '1/day'

@api_view(['GET'])
@throttle_classes([OncePerDayUserThrottle])
def view(request):
    return Response({"message": "Hello for today! See you tomorrow!"})
```

이러한 장식은 위의 APIView 서브 클래스에 설정된 속성에 해당합니다.

- @renderer_classes(...)
- @parser_classes(...)
- @authentication_classes(...)
- @throttle_classes(...)
- @permission_classes(...)

이러한 장식은 각 클래스의 list 또는 tuple의 단일 인수를 취합니다.

## View schema decorator

함수 기반 뷰의 기본 스키마 생성을 재정의하려면 **@schema** 장식을 사용할 수 있습니다.
이것은 **@api_view** 장식의 뒤에 와야합니다.
For example:

```python
from rest_framework.decorators import api_view, schema
from rest_framework.schemas import AutoSchema

class CustomAutoSchema(AutoSchema):
    def get_link(self, path, method, base_url):
        # override view introspection here...

@api_view(['GET'])
@schema(CustomAutoSchema())
def view(request):
    return Response({"message": "Hello for today! See you tomorrow!"})
```

이 decorator는 스키마 문서에서 설명한대로 단일 **AutoSchema** 인스턴스 **AutoSchema** 서브 클래스 인스턴스 또는 **ManualSchema** 인스턴스를 취합니다. 뷰 스키마 생성에서 제외하면 None을 전달할 수 있습니다.

```python
@api_view(['GET'])
@schema(None)
def view(request):
    return Response({"message": "Will not appear in schema!"})
```
