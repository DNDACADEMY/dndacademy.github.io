---
layout: post
title: "Slack(슬랙)에 GitHub 정보를 연계하는 방법"
author: Gidong
categories: [Github]
tags: [Slack, Project Management]
image: assets/images/githhub-slack/integration-slack.png
sitemap:
  changefreq: daily
  priority: 1.0
---

## GitHub App 추가

Slack의 ![/assets/images/githhub-slack/20190307_1.png](/assets/images/githhub-slack/20190307_1.png) 슬랙을 선택면 APP검색창이 표시됩니다.
Github를 검색하여 [인스톨]을 선택합니다.
![/assets/images/githhub-slack/20190307_2.png](/assets/images/githhub-slack/20190307_2.png)

인스톨 하면 Slack Apps부분에 GitHub가 추가됩니다.
![/assets/images/githhub-slack/20190307_3.png](/assets/images/githhub-slack/20190307_3.png)

## GitHub repository 통지 등록

GitHub 선택 후, 입력 창에 추가 하고자 하는 github repository를 /github subscribe owner/repository 형식으로 입력합니다.
![/assets/images/githhub-slack/20190307_4.png](/assets/images/githhub-slack/20190307_4.png)

## GitHub 인증

Github계정 정보를 연결하는 버튼이 표시되므로 connect GitHub account를 선택합니다. ![/assets/images/githhub-slack/20190307_5.png](/assets/images/githhub-slack/20190307_5.png)

브라우져가 열리고 GitHub에 로그인하면 Slack에 다음과 같이 통지가 옵니다. ![/assets/images/githhub-slack/20190307_6.png](/assets/images/githhub-slack/20190307_6.png)

계속해서 어느 repository를 연계할 것인지 체크합니다.
![/assets/images/githhub-slack/20190307_7.png](/assets/images/githhub-slack/20190307_7.png)

완료되면 Slack에 Subscribed to...이라고 통지가 오는 것으로 설정이 완료됩니다.
![/assets/images/githhub-slack/20190307_8.png](/assets/images/githhub-slack/20190307_8.png)

## repository 통지 삭제

등록한 repository를 삭제할 경우에는 unsubscribe 커멘드를 이용합니다.  
`/github unsubscribe owner/repository`

## 통지내용

디폴트로 통지되는 항목.

- issues - Opened or closed issues
- pulls - New or merged pull requests
- statuses - Statuses on pull requests
- commits - New commits on the default branch (usually master)
- deployments - Updated status on deployments
- public - A repository switching from private to public
- releases - Published releases

추가 가능한 통지 항목

- reviews - Pull request reviews
- comments - New comments on issues and pull requests
- branches - Created or deleted branches
- commits:all - All commits pushed to any branch

issues,comments,pulls,statuses,comments,reviews 추가할 경우에는 다음과 같이 입력합니다.  
`/github subscribe DNDACADEMY issues,comments,pulls,statuses,comments,reviews`

삭제할 경우에는  
`/github unsubscribe DNDACADEMY issues,comments,pulls,statuses,comments,reviews`

참고 : https://github.com/integrations/Slack#configuration
