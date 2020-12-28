---
layout: post
title: "[Django REST Framework] Serializers"
author: Gidong
categories: [Django]
tags: [python, drf, djang-rest-framework, Serializers]
image: assets/images/drf-serializers/main.png
sitemap:
  changefreq: daily
  priority: 1.0
---

## Serializer란??

> **serializes**: 쿼리셋, 모델 인스턴스 등의 복잡한 데이터를 JSON, XML 등의 컨텐트 타입으로 쉽게 변환 가능한 python datatype으로 변환시켜줌

dserializer: 받은 데이터를 validating 한 후에 parsed data를 complex type으로 다시 변환

### Declaring Serializers

간단한 object를 만드는 것을 예로 들어보자.

```python
from datetime import datetime

class Comment:
    def __init__(self, email, content, created=None):
        self.email = email
        self.content = content
        self.created = created or datetime.now()

comment = Comment(email='leila@example.com', content='foo bar')
```

Comment 개체에 해당하는 데이터를 serialize 및 deserialize에 사용할 수있는 serializer를 선언합니다.

serializer의 선언은 form의 선언과 매우 비슷합니다.

```python
from rest_framework import serializers

class CommentSerializer(serializers.Serializer):
    email = serializers.EmailField()
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()
```

### Serializing objects

CommentSerializer을 사용하여 comment 또는 list of comments를 serialize 할 수있게되었습니다.  
또, Serializer 클래스의 사용은 Form 클래스의 사용과 비슷합니다.

```python
serializer = CommentSerializer(comment)
serializer.data
# {'email': 'leila@example.com', 'content': 'foo bar', 'created': '2016-01-27T15:17:10.375877'}
```

이 시점에서 모델 인스턴스를 Python native 데이터 형식으로 변환했습니다.  
serialization 프로세스를 완료하기 위해 데이터를 json으로 렌더링합니다.

```python
from rest_framework.renderers import JSONRenderer

json = JSONRenderer().render(serializer.data)
json
# b'{"email":"leila@example.com","content":"foo bar","created":"2016-01-27T15:17:10.375877"}'
```

### Deserializing objects

Deserialization도 비슷합니다.

```python
import io
from rest_framework.parsers import JSONParser

stream = io.BytesIO(json)
data = JSONParser().parse(stream)
```

validated data를 저장

```python
serializer = CommentSerializer(data=data)
serializer.is_valid()
# True
serializer.validated_data
# {'content': 'foo bar', 'email': 'leila@example.com', 'created': datetime.datetime(2012, 08, 22, 16, 20, 09, 822243)}
```

### Saving instances

If we want to be able to return complete object instances based on the validated data we need to implement one or both of the .create() and .update() methods. For example:

검증 된 데이터를 기반으로 object instances를 반환 할 수 있도록하려면 `.create()` 메소드와 `.update()` 메소드 중 하나 또는 모두를 구현해야합니다. 예를 들면 :

```python
class CommentSerializer(serializers.Serializer):
    email = serializers.EmailField()
    content = serializers.CharField(max_length=200)
    created = serializers.DateTimeField()

    def create(self, validated_data):
        return Comment(**validated_data)

    def update(self, instance, validated_data):
        instance.email = validated_data.get('email', instance.email)
        instance.content = validated_data.get('content', instance.content)
        instance.created = validated_data.get('created', instance.created)
        return instance
```

object instances가 Django 모델에 해당하는 경우에는 이러한 메소드가 객체를 데이터베이스에 저장할 때 확인해야합니다.  
예를 들어 Comment이 Django 모델의 경우, 메소드는 다음과 같습니다.

```python
    def create(self, validated_data):
        return Comment.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.email = validated_data.get('email', instance.email)
        instance.content = validated_data.get('content', instance.content)
        instance.created = validated_data.get('created', instance.created)
        instance.save()
        return instance
```

이제 데이터를 deserializing 할 때 `.save()`를 호출 해, object instance를 반환 할 수 있습니다.

```python
comment = serializer.save()
```

`.save()`를 호출하면 serializer 클래스를 인스턴스화 할 때 기존의 인스턴스가 전달되었는지 여부에 따라 새로운 인스턴스가 생성되거나 기존의 인스턴스가 업데이트됩니다.

```python
# .save() will create a new instance.
serializer = CommentSerializer(data=data)

# .save() will update the existing `comment` instance.
serializer = CommentSerializer(comment, data=data)
```

`.create()` 메소드와 `.update()` 메서드는 모두 옵션입니다.  
serializer 클래스의 use-case에 따라 하나 또는 모두를 구현할 수 있습니다.

### Passing additional attributes to .save()

인스턴스를 저장하는 시점에서 view code가 추가 데이터를 삽입 할 수 있도록 하려는 경우가 있습니다.  
이 추가 데이터는 사용자의 현재 시간 또는 요청 데이터의 일부가 아닌 기타 정보가 포함될 수 있습니다.

`.save()`를 호출 할 때 추가적으로 keyword arguments를 포함하여 작업을 수행 할 수 있습니다. 예를 들면 :

```python
serializer.save(owner=request.user)
```

`.create()` 또는 `.update()`가 호출되면 추가 keyword arguments가 validated_data 인수에 포함됩니다.

### Overriding .save() directly.

경우에 따라서는 `.save()`를 직접 overriding가능합니다.

```python
class ContactForm(serializers.Serializer):
    email = serializers.EmailField()
    message = serializers.CharField()

    def save(self):
        email = self.validated_data['email']
        message = self.validated_data['message']
        send_email(from=email, message=message)
```
