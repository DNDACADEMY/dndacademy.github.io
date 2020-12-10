---
layout: post
title: "Django 인증 뷰"
author: Gidong
categories: [Django]
tags: [python, 파이썬, Form, 장고]
image: assets/images/django-authentication-system/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

Django는 로그인, 로그아웃 및 비밀번호 관리 작업에 사용할 수있는 몇 가지 보기를 제공합니다. 이들은 스톡 인증 양식을 이용하지만, 자신의 양식을 전달할 수 있습니다.

Django는 인증 뷰의 기본 템플릿을 제공하지 않습니다. 사용하는 뷰에 대한 자신의 템플릿을 작성해야합니다. 템플릿 context는 각 뷰에 문서화되어 있습니다. 모든 인증 뷰를 참조하십시오.

## Using the views

이러한 뷰를 프로젝트에 구현하는 다양한 방법이 있습니다.
가장 쉬운 방법은 자신의 URLconf에 django.contrib.auth.urls 를포함하는 것입니다.
for example:

```django
urlpatterns = [
    path('accounts/', include('django.contrib.auth.urls')),
]
```

이것은 다음의 URL 패턴이 포함되어 있습니다.

```django
accounts/login/ [name='login']
accounts/logout/ [name='logout']
accounts/password_change/ [name='password_change']
accounts/password_change/done/ [name='password_change_done']
accounts/password_reset/ [name='password_reset']
accounts/password_reset/done/ [name='password_reset_done']
accounts/reset/<uidb64>/<token>/ [name='password_reset_confirm']
accounts/reset/done/ [name='password_reset_complete']
```

뷰는 참조 할 수 있도록 URL 이름을 제공합니다. 명명된 URL 패턴의 사용에 대한 자세한 내용은 URL의 문서를 참조하십시오.
URL을 보다 효율적으로 관리하고 싶은 경우는 URLconf에서 특정 뷰를 볼 수 있습니다.

```django
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('change-password/', auth_views.PasswordChangeView.as_view()),
]
```

뷰는 뷰의 동작을 변경하는 데 사용할 수 있는 옵션의 인수가 있습니다.
예를 들어, 뷰가 사용하는 템플릿 이름을 변경하는 경우 **template_name** 인수를 지정할 수 있습니다.
이렇게하는 방법은 URLconf에 키워드 인수를 지정하는 것입니다. 이들은 뷰에 전달됩니다.
for example:

```django
urlpatterns = [
    path(
        'change-password/',
        auth_views.PasswordChangeView.as_view(template_name='change-password.html'),
    ),
]
```

모든 뷰는 클래스 기반이기 때문에 서브 클래스화하여 보기 쉽게 사용자 정의 할 수 있습니다.

---

## All authentication views

이것은 django.contrib.auth이 제공하는 모든 뷰의 목록입니다.

**class LoginView**

- URL name: **login**
  - See the URL documentation for details on using named URL patterns.
- Attributes:
  - **template_name** : 사용자 로그인에 사용되는 뷰에 표시 할 템플릿의 이름입니다. 기본값은 `registration/login.htm`
  - **redirect_field_name** : 로그인 후 리디렉션되는 URL을 포함하는 GET 필드의 이름입니다. 기본값은 `next`입니다.
  - **authentication_form** : 인증에 사용하는 호출 가능 (보통 폼 클래스). 기본값은 `AuthenticationForm`입니다.
  - **extra_context** : 템플릿에 전달되는 기본 context data에 추가되는 context data 사전.
  - **redirect_authenticated_user** : 로그인 페이지에 액세스하는 인증 된 사용자가 로그인에 성공한 것처럼 리디렉션되는지 여부를 제어하는 ​​Bool값입니다. 기본값은 `False`입니다.
  - **success_url_allowed_hosts** : request.get_host() 외에도 로그인 후 리디렉션에 안전한 호스트 set 입니다. 기본값은 빈 set 입니다.

LoginView의 기능은 다음과 같습니다:

- GET을 통해 호출 된 경우 동일한 URL에 POST 로그인 양식이 표시됩니다. 이에 대해 좀 더 자세히 설명합니다.
- 사용자가 제출 한 자격 증명을 사용하여 POST를 통해 호출 된 경우 사용자가 로그인을 시도합니다. 로그인이 성공하면 뷰는 다음 지정된 URL로 리디렉션 됩니다. `next`가 지정되어 있지 않은 경우는 `settings.LOGIN_REDIRECT_URL` (기본값은 `/accounts/profile/`)로 리디렉션됩니다. 로그인에 실패하면 로그인 폼이 다시 표시됩니다.

기본적으로 `registration/login.html`라는 로그인 템플릿 html을 제공하는 것은 당신의 책임입니다.
이 템플릿에는 다음의 4 가지 템플릿 컨텍스트 변수가 전달됩니다.

- **form** : `AuthenticationForm`을 나타내는 Form 개체.
- **next** : 로그인에 성공한 후 리디렉션되는 URL. 여기에는 쿼리 문자열을 포함 할 수 있습니다.
- **site** : `SITE_ID` 설정에 따른 현재의 사이트. 사이트 프레임 워크가 설치되어 있지 않은 경우, 이것은 `RequestSite`의 인스턴스로 설정됩니다. 이것은 현재 `HttpRequest`에서 사이트 이름과 도메인을 가져옵니다.
- **site_name** : `site.name`의 별칭. 사이트 프레임 워크가 설치되어 있지 않은 경우, 이것은 `request.META['SERVER_NAME']`의 값으로 설정됩니다.

템플릿 `registration/login.html`를 호출하지 않으면 추가 인수를 통해 `template_name` 매개 변수를 URLconf의 `as_view` 메소드에 전달할 수 있습니다. 예를 들어,이 URLconf 줄은 `myapp/login.html`을 사용합니다.

```django
path('accounts/login/', auth_views.LoginView.as_view(template_name='myapp/login.html')),
```

또한 `redirect_field_name`를 사용하여 로그인 후 리디렉션되는 URL을 포함 GET 필드의 이름을 지정할 수도 있습니다.
기본적으로 필드는 `next`라고합니다.

시작점으로 사용할 수 `registration/login.html` 템플릿 샘플을 보여줍니다.
콘텐츠 블록을 정의하는 `base.html` 템플릿이있는 것을 전제로 하고 있습니다.

```django
{ % extends "base.html" % }

{ % block content % }

{ % if form.errors % }
<p>Your username and password didn't match. Please try again.</p>
{ % endif % }

{ % if next % }
    { % if user.is_authenticated % }
    <p>Your account doesn't have access to this page. To proceed,
    please login with an account that has access.</p>
    { % else % }
    <p>Please login to see this page.</p>
    { % endif % }
{ % endif % }

<form method="post" action="{ % url 'login' % }">
{ % csrf_token % }
<table>
<tr>
    <td>{{ form.username.label_tag }}</td>
    <td>{{ form.username }}</td>
</tr>
<tr>
    <td>{{ form.password.label_tag }}</td>
    <td>{{ form.password }}</td>
</tr>
</table>

<input type="submit" value="login">
<input type="hidden" name="next" value="{{ next }}">
</form>

{# Assumes you setup the password_reset view in your URLconf #}
<p><a href="{ % url 'password_reset' % }">Lost password?</a></p>

{ % endblock % }
```

인증을 사용자 정의하는 경우 (인증의 정의 참조) `authentication_form` 속성을 설정하여 사용자 정의 인증 양식을 사용할 수 있습니다. 이 양식은 `__init__()` 메소드에서 `request` 키워드 인수를 받아, 인증 된 사용자 개체를 반환 `get_user()` 메소드를 제공해야합니다.
(이 방법은 양식 유효성 검사가 성공한 후에만 ​​호출됩니다)
