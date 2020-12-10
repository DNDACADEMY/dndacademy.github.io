---
layout: post
title: "Django 폼(form) 사용하기"
author: Gidong
categories: [Django]
tags: [python, 파이썬, Form, 장고]
image: assets/images/django-form/main.jpg
sitemap:
  changefreq: daily
  priority: 1.0
---

아무것도 하지않고 단지 컨텐츠를 퍼블리싱하는 웹사이트 혹은 어플리케이션을 계획중인게 아니라면, 그리고 어떠한 정보로 방문자로부터 입력받지 않을 것이 아니라면 폼 사용법을 이해 할 필요가 있습니다.

Django는 사용자로 부터 입력을 받고, 이를 처리하고 응답할 폼을 생성하는 다양한 도구와 라이브러리를 제공합니다.

## HTML 폼

첫번째로 HTML 폼(Form)에 대한 간단한 개요이다. 어떤 "team"의 이름을 입력하는 단일 텍스트 필드와 관련 라벨을 가진 간단한 HTML 폼을 생각해보자:

폼은 HTML에서 적어도 한 개 이상의 `type="submit"`인 `input` 요소를 포함하는 `<form>...</form>` 태그 사이의 요소들의 집합으로 정의된다.

```html
<form action="/team_name_url/" method="post">
  <label for="team_name">Enter name: </label>
  <input
    id="team_name"
    type="text"
    name="name_field"
    value="Default name for team."
  />
  <input type="submit" value="OK" />
</form>
```

- action: 폼이 제출(submit)될 때 처리가 필요한 데이타를 전달받는 곳의 자원/URL 주소. 설정이 안되면 (혹은 빈 문자열로 설정되면), 폼은 현재 페이지 URL로 다시 제출된다.
- method: 데이터를 보내는데 사용되는 HTTP 메소드: post 이거나 get 이다.
  - POST 메소드는 사이트간 요청 위조 공격에 좀 더 저항성이 좋게 만들 수 있기 때문에, 관련 데이터에 의해 서버 데이터베이스가 변경될 경우에는 항상 사용 되어야 한다.
  - GET 메소드는 사용자 데이터를 변경하지 않는 폼(예를 들면 , 탐색 폼)에서만 사용되어야 한다. URL을 북마크하길 원하거나 공유하기를 원하는 경우에 추천한다.

## Django 폼이 주요하게 다루는 것

1. 사용자가 처음으로 폼을 요청할 때 기본 폼을 보여준다.
   - 폼은 비어있는 필드가 있을 수 있다 (예를 들면, 새로운 책을 등록할 경우) 아니면 초기값으로 채워진 필드가 있을 수도 있다. ( 예를 들면, 기존의 책을 수정하거나, 흔히 사용하는 초기값이 있을경우)
   - 이 시점의 폼은 (초기값이 있긴해도) 유저가 입력한 값에 연관되지 않았기에 unbound 상태라고 불린다.
2. 제출 요청으로 부터 데이타를 수집하고 그것을 폼에 결합한다.
   - 데이타를 폼에 결합(binding) 한다는 것은 사용자 입력 데이타와 유효성을 위반한 경우의 에러메시지가 폼을 재표시할 필요가 있을 때 준비되었다는 의미이다.
3. 데이타를 다듬어서 유효성을 검증한다.
   - 데이타를 다듬는다는 것은 사용자 입력을 정화(sanitisation) 하고 (예를 들면, 잠재적으로 악의적인 콘덴츠를 서버로 보낼수도 있는 유효하지 않은 문자를 제거하는 것) python에서 사용하는 타입의 데이타로 변환하는 것이다.
   - 유효성검증은 입력된 값이 해당 필드에 적절한 값인지 검사한다. (예를 들면, 데이타가 허용된 범위에 있는 값인지, 너무 짧거나 길지 않은지 등등)
4. 입력된 어떤 데이타가 유효하지 않다면, 폼을 다시 표시하는데 이번에는 초기값이 아니라 유저가 입력한 데이타와 문제가 있는 필드의 에러 메시지와 함께 표시한다.
5. 입력된 모든 데이타가 유효하다면, 요청된 동작을 수행한다. (예를 들면, 데이타를 저장하거나, 이메일을 보내거나, 검색결과를 반환하거나, 파일을 업로딩하는 작업 등등)
6. 일단 모든 작업이 완료되었다면, 사용자를 새로운 페이지로 보낸다.

## ModelForm

데이터베이스 기반 애플리케이션을 구축하는 경우, Django 모델에 밀접하게 매핑되는 형태가 있을 수 있습니다. 예를 들어, BlogComment 모델이 사용자가 댓글을 전송할 수있는 양식을 작성하고 싶다고합니다. 이 경우 모델에서 필드를 이미 정의하고 있기 때문에 양식 필드 유형을 정의하는 것은 중복입니다.

따라서 Django는 Django 모델에서 Form 클래스를 만들 수 helper 클래스가 준비되어 있습니다.

ex)

```django
>>> from django.forms import ModelForm
>>> from myapp.models import Article

# Create the form class.
>>> class ArticleForm(ModelForm):
...     class Meta:
...         model = Article
...         fields = ['pub_date', 'headline', 'content', 'reporter']

# Creating a form to add an article.
>>> form = ArticleForm()

# Creating a form to change an existing article.
>>> article = Article.objects.get(pk=1)
>>> form = ArticleForm(instance=article)
```

#### 필드 타입

| Model field               | Form field                                                                                              |
| ------------------------- | ------------------------------------------------------------------------------------------------------- |
| AutoField                 | Not represented in the form                                                                             |
| BigAutoField              | Not represented in the form                                                                             |
| BigIntegerField           | IntegerField with min_value set to -9223372036854775808 and max_value set to 9223372036854775807.       |
| BinaryField               | CharField, if editable is set to True on the model field, otherwise not represented in the form.        |
| BooleanField              | BooleanField, or NullBooleanField if null=True.                                                         |
| CharField                 | CharField with max_length set to the model field’s max_length and empty_value set to None if null=True. |
| DateField                 | DateField                                                                                               |
| DateTimeField             | DateTimeField                                                                                           |
| DecimalField              | DecimalField                                                                                            |
| DurationField             | DurationField                                                                                           |
| EmailField                | EmailField                                                                                              |
| FileField                 | FileField                                                                                               |
| FilePathField             | FilePathField                                                                                           |
| FloatField                | FloatField                                                                                              |
| ForeignKey                | ModelChoiceField (see below)                                                                            |
| ImageField                | ImageField                                                                                              |
| IntegerField              | IntegerField                                                                                            |
| IPAddressField            | IPAddressField                                                                                          |
| GenericIPAddressField     | GenericIPAddressField                                                                                   |
| JSONField                 | JSONField                                                                                               |
| ManyToManyField           | ModelMultipleChoiceField (see below)                                                                    |
| NullBooleanField          | NullBooleanField                                                                                        |
| PositiveBigIntegerField   | IntegerField                                                                                            |
| PositiveIntegerField      | IntegerField                                                                                            |
| PositiveSmallIntegerField | IntegerField                                                                                            |
| SlugField                 | SlugField                                                                                               |
| SmallAutoField            | Not represented in the form                                                                             |
| SmallIntegerField         | IntegerField                                                                                            |
| TextField                 | CharField with widget=forms.Textarea                                                                    |
| TimeField                 | TimeField                                                                                               |
| URLField                  | URLField                                                                                                |
| UUIDField                 | UUIDField                                                                                               |
