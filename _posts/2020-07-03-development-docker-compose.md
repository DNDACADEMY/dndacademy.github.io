---
layout: post
title: "Dockerfile 알아보기"
author: Gidong
categories: [Docker]
tags: [Docker Compose, Dockerfile]
image: assets/images/development-docker-compose/docker-compose-main-cover.jpg
sitemap:
  changefreq: daily
  priority: 1.0
---

Docker-Compose를 사용하면 컨테이너 실행에 필요한 옵션을 `docker-compose.yml`이라는 파일에 적어둘 수 있고, 컨테이너 간 실행 순서나 의존성도 관리할 수 있습니다.

```yaml
version: "3"

services:
  # django container
  django:
    container_name: backend # 컨테이너명
    build:
      context: ./backend # docekr build 명령을 수행할 경로
      dockerfile: Dockerfile # 실행할 Dockerfile의 경로
    ports: # 외부와 내부를 연결할 Port
      - "8000:8000"
    # environment:
    command: ["python3", "manage.py", "runserver", "0:8000"] # Dockerfile의 CMD보다 우선적으로 실행되는 명령
    volumes: # 컨테이너에서 호스트 폴더의 폴더와 마운트
      - ./backend:/backend
  # web container
  web:
    container_name: frontend # 컨테이너명
    depends_on: # web 이미지에 대한 컨테이너는 redis, db, django가 생성되고, 시작되기 전에는 빌드되지 않음.
      - django
    build:
      context: ./frontend # docekr build 명령을 수행할 경로
      dockerfile: Dockerfile # 실행할 Dockerfile의 경로
    ports: # 외부와 내부를 연결할 Port
      - "3000:3000"
    # environment:
    command: ["yarn", "start"] # Dockerfile의 CMD보다 우선적으로 실행되는 명령
    volumes: # 컨테이너에서 호스트 폴더의 폴더와 마운트
      - ./frontend:/frontend
```

---

## Dockerfile

### Django Dockerfile

```yaml
FROM python:3.8-slim-buster AS builder

RUN apt-get update && \
apt-get install -y gcc default-libmysqlclient-dev libjpeg-dev

WORKDIR /djangoproject

COPY requirements/ /djangoproject/requirements/
COPY requirements.txt /djangoproject
RUN pip install -r requirements.txt

COPY . /djangoproject

ENV PYTHONUNBUFFERED=1

EXPOSE 80

CMD gunicorn \
--access-logfile - \
backend.wsgi:application \
--bind 0.0.0.0:80 \
--max-requests 1000 \
--max-requests-jitter 50
```

### React Dockerfile

```yaml
FROM node:13 as builder

WORKDIR /reactproject
COPY . /reactproject
RUN yarn
RUN yarn build

FROM nginx:1.17-alpine

RUN rm -rf /etc/nginx/nginx.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY --from=builder /reactproject/build /usr/share/nginx/html

EXPOSE 80

ENV REACT_APP_API_HOST=$REACT_APP_API_HOST

CMD ["nginx", "-g", "daemon off;"]
```
