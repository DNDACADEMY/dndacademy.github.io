---
layout: post
title: "마크다운 - Expander control(접기/펼치기) 만들기"
author: Gidong
image: "assets/images/markdown-expander-control/markdown-expander-control-main.png"
categories: [Markdown]
tags: [Expander, 확장]
sitemap:
  changefreq: daily
  priority: 1.0
---

마크다운에서 접기/펼치기 가능한 컨트롤 문법을 알아보겠습니다.  
마크다운 자체엔 기능이 없는 듯 하여 html 의 details를 이용합니다.

> **마크다운**이라쓰고 html이라 읽는다

### 코드

> **INFO**  
> div markdown=”1” 은 jekyll에서 html사이에 markdown을 인식 하기 위한 코드입니다.

```html
<details>
  <summary>접기/펼치기 버튼</summary>
  <div markdown="1">
    내용
  </div>
</details>
```

<details>
  <summary>접기/펼치기 버튼</summary>
  <div markdown="1">
    내용
  </div>
</details>
