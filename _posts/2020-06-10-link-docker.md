---
layout: post
title: " Docker Container란?"
author: Gidong
categories: [Docker]
tags: [Developer, Docker Container]
image: assets/images/link-docker/docker-corver.png
# rating: 4.5
sitemap:
  changefreq: daily
  priority: 1.0
---

> [Container](https://cloud.google.com/containers/?hl=ko)란 어플리케이션이 동작하기 위해서 필요한 요소(실행 파일, 어플리케이션 엔진 등)을 패키지화하고 격리하는 기술

## Container를 왜 사용하는걸까?

- 일관성 있는 환경
  - 개발자는 컨테이너를 이용해, 다른 애플리케이션과 분리된 예측 가능한 환경을 생성할 수 있다. 컨테이너는 애플리케이션에 필요한 소프트웨어 종속 항목(프로그래밍 언어 런타임 및 기타 소프트웨어 라이브러리의 특정 버전 등)도 포함할 수 있다. 개발자의 관점에서 이 모든 요소는 애플리케이션이 배포되는 최종 위치에 관계없이 항상 일관성이 있기 때문에, 그 결과 자연히 생산성이 향상될 수밖에 없다. 개발자와 IT 운영팀이 버그를 잡고 환경 차이를 진단하던 시간을 줄이고 사용자에게 신규 기능을 제공하는 데 집중할 수 있기 때문이다. 또한 개발자가 개발 및 테스트 환경에서 세운 가정이 프로덕션 환경에서 그대로 실현될 것이기 때문에 버그 수 자체도 감소한다.
- 폭넓은 구동 환경
  - 컨테이너는 Linux, Windows, Mac 운영체제, 가상 머신, 베어메탈, 개발자의 컴퓨터, 데이터 센터, 온프레미스 환경, 퍼블릭 클라우드 등 사실상 어느 환경에서나 구동되므로 개발 및 배포가 크게 쉬워진다. 컨테이너용 [Docker 이미지 형식](https://cloud.google.com/container-registry/docs/image-formats?hl=ko)은 워낙 널리 사용되기 때문에 **이식성**도 매우 뛰어난다. 소프트웨어 구동 환경이 무엇이든 컨테이너를 사용할 수 있다.
- 격리
  - 컨테이너는 CPU, 메모리, 저장소, 네트워크 리소스를 운영체제 수준에서 가상화하여 개발자에게 기타 애플리케이션으로부터 논리적으로 격리된 운영체제 샌드박스 환경을 제공한다.
  - 따라서 간소화된 배포 및 릴리스 프로세스를 통해 신속하고 자주 배포할 수 있고, 이는 리소스 활용성이 증가함을 의미한다.

## Container의 작동 원리

컨테이너는 cgroup과 namespace와 같은 [리눅스 커널](https://www.kernel.org/doc/Documentation/) 기반의 기술을 이용해서 프로세스를 완벽하게 격리하여 분리된 환경을 만들고 실행한다.

**cGroup**은 각 프로세스 혹은 컨테이너가 소비할 수 있는 호스트OS의 리소스를 공유하고 제한할 수 있게 한다. 이것은 호스트의 하드웨어 리소스의 서비스 거부 공격(denial of sevice attacks)을 방지하므로 리소스 활용과 보안 모두에서 중요하다. Container는 미리 정의된 제약 조건하에서 CPU와 메모리를 공유할 수 있다.

**namespace**는 운영체제 내에서 프로세스가 가지는 다른 프로세스, 네트워킹, 파일시스템, 사용자 ID 구성 요소 등의 '가시성'을 제한하여 프로세스 상호작용을 따로 구분하는 방식이다. namespace를 통해 컨테이너 프로세스는 동일한 namespace에 있는 것들만 볼 수 있도록 제한된다. 다른 컨테이너에서 만들어진 프로세스나 호스트 프로세스는 컨테이너 프로세스에서 직접 접근할 수 없다.

### [cGroup](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/ch01)?

> Control Group의 약자로, 시스템의 CPU 시간, 시스템 메모리, 네트워크 대역폭과 같은 자원을 제한하고 격리할 수 있는 커널 기능

**cgroups**(control groups의 약자)는 [프로세스](https://ko.wikipedia.org/wiki/%ED%94%84%EB%A1%9C%EC%84%B8%EC%8A%A4)들의 [자원의 사용](https://ko.wikipedia.org/w/index.php?title=%EC%8B%9C%EC%8A%A4%ED%85%9C_%EC%9E%90%EC%9B%90&action=edit&redlink=1)(CPU, 메모리, 디스크 입출력, 네트워크 등)을 제한하고 격리시키는 [리눅스 커널](https://ko.wikipedia.org/wiki/%EB%A6%AC%EB%88%85%EC%8A%A4_%EC%BB%A4%EB%84%90) 기능이다.

[구글](https://ko.wikipedia.org/wiki/%EA%B5%AC%EA%B8%80)의 엔지니어들이 2006년에 이 기능에 대한 작업에 착수하였고 당시 이름은 "프로세스 컨테이너"(process container)였다.[[1]](https://ko.wikipedia.org/wiki/Cgroups#cite_note-1) 2007년 말에 리눅스 커널 문맥에서 "컨테이너"라는 용어의 의미가 여러 개이므로 혼란을 방지하기 위해 이름이 "컨트롤 그룹"(control groups)으로 변경되었으며, 컨트롤 그룹 기능은 2008년 1월에 출시된 커널 버전 2.6.24에 [리눅스 커널 메인라인](https://ko.wikipedia.org/wiki/%EB%A6%AC%EB%88%85%EC%8A%A4_%EC%BB%A4%EB%84%90)으로 병합되었다.[[2]](https://ko.wikipedia.org/wiki/Cgroups#cite_note-lwn-notes-2) 그 뒤로 개발자들은 수많은 새로운 기능과 컨트롤러들을 추가해오고 있는데, 이를테면 [kernfs](https://ko.wikipedia.org/wiki/Kernfs) 지원,[[3]](https://ko.wikipedia.org/wiki/Cgroups#cite_note-3) [방화벽](https://ko.wikipedia.org/wiki/%EB%B0%A9%ED%99%94%EB%B2%BD),[[4]](https://ko.wikipedia.org/wiki/Cgroups#cite_note-4) 통합된 계층구조를 포함한다.[[5]](https://ko.wikipedia.org/wiki/Cgroups#cite_note-5)

cGroup으로 컨테이너 안의 프로세스에 대해 자원을 제한함으로써 특정 컨테이너가 호스트 OS의 자원을 모두 점유하여 사용하는 일을 막는다.

- cGroup의 서브시스템
  - [blkio](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/ch-subsystems_and_tunable_parameters#sec-blkio) - 물리 드라이브 (예: 디스크, 솔리드 스테이트, USB 등)와 같은 블록 장치(Block Device)에 대한 입력/출력 액세스에 제한을 설정한다.
  - [cpu](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-cpu) - CPU에 cgroup 작업 액세스를 제공하기 위해 스케줄러를 사용한다.
  - [cpuacct](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-cpuacct) - cgroup의 작업에 사용된 CPU 자원에 대한 보고서를 자동으로 생성한다.
  - [cpuset](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-cpuset) - 개별 CPU (멀티코어 시스템에서) 및 메모리 노드를 cgroup의 작업에 할당한다.
  - [devices](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-devices) - cgroup의 작업 단위로 장치에 대한 액세스를 허용하거나 거부한다.
  - [freezer](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-freezer) - cgroup의 작업을 일시 중지하거나 다시 시작한다.
  - [memory](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-memory) - cgroup의 작업에서 사용되는 메모리에 대한 제한을 설정하고 이러한 작업에서 사용되는 메모리 자원에 대한 보고서를 자동으로 생성한다.
  - [net_cls](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/6/html/resource_management_guide/sec-net_cls) - Linux 트래픽 컨트롤러 (tc)가 특정 cgroup 작업에서 발생하는 패킷을 식별하게 하는 클래식 식별자 (classid)를 사용하여 네트워크 패킷에 태그를 지정한다.
  - [net_prio](https://www.kernel.org/doc/Documentation/cgroup-v1/net_prio.txt) - cgroup의 작업에서 생성되는 네트워크 트래픽의 우선순위를 지정한다.

### [Namespace](https://en.wikipedia.org/wiki/Linux_namespaces)?

> 하나의 시스템에서 프로세스를 격리(Isolation)시킬 수 있는 가상화 기술이다.

Namespace는 커널 인스턴스를 만들지 않고 기존의 리소스들을 필요한 만큼의 Namespace로 분리하여 묶어 관리하는 방법으로 사용한다. 커널이 부팅된 후 관리 자원은 각각의 초기 Default Namespace에서 관리한다. 그 후 사용자의 필요에 따라 Namespace를 추가하여 자원들을 별도로 분리하여 관리할 수 있다.

Namespace는 기존에 잘 알려진 가상화 기술인 Hypervisor 와는 구조적으로 다르다.

Hypervisor는 Hardware resource 를 가상화 한다. Hypervisor 위에 올라가는 Guest OS 에는 가상화 된 형태의 H/W 를 제공하게 되며, 따라서 각각의 Guest OS는 완전한 다른 환경으로 분리된다.

하지만 Namespace의 경우에는 Hardware resource 레벨의 가상화가 아니다. 동일한 OS와 동일한 kernel 에서 작동하게 되며, 단지 각각의 고립된 사용 환경만 제공되는 것이다.

- Namespace의 종류
  - UTS Namespace : hostname을 변경하고 분할
  - IPC Namespace : 프로세스간 통신 격리
  - PID Namespace : Process ID를 분할 관리
  - NET Namespace : Network Interface, iptables 등 network 리소스와 관련된 정보를 분할
  - User Namespace : user와 group ID를 분할 격리
  - Mount Namespace :

### Container의 동작 구조

![/assets/images/link-docker/image1.png](/assets/images/link-docker/image1.png)

# Docker Networking

Linux에서 도커는 iptables 규칙을 조작하여 네트워크 격리를 제공한다.

이것은 구현 세부 사항이며 도커가 iptables 정책에 삽입하는 규칙을 수정해서는 안된다.

아래는 도커 네트워크의 종류이다.

- [Bridge 네트워크](https://docs.docker.com/v18.09/network/bridge/)
- [Host 네트워크](https://docs.docker.com/v18.09/network/host/)
- [Overlay 네트워크](https://docs.docker.com/v18.09/network/overlay/)
- [macvlan 네트워크](https://docs.docker.com/v18.09/network/macvlan/)

기본적으로 도커의 네트워크는 bridge 네트워크를 사용한다.

도커의 네트워크를 조회하는 명령어 :

`sudo docker network ls`

도커의 네트워크 중 하나를 상세 조회하는 명령어 :

예시) bridge network

`sudo docker network inspect bridge`

각 컨테이너는 생성될 때 도커 데몬으로부터 네트워크에 대한 정보를 전달받는다.

도커 데몬이 컨테이너에게 DHCP 서버의 역할을 하는 것이다.

아래와 같이 `docker network inspect` 명령어를 통해 네트워크의 정보를 조회해보면 컨테이너의 MAC 주소와 IPv4 주소 및 서브넷 마스크 정보까지 알 수 있다.

```bash
$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "926107b934decf7b5129ce4d68f73b29e3cce19713690084bf1947be6d683422",
        "Created": "2019-11-04T02:40:37.907885457Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "5c5214370dfb3e08ec13dc25540704bfcaf0d10472a999da35e149b7e9d366b4": {
                "Name": "focused_liskov",
                "EndpointID": "3bafab184adbdd2dd320722352e0686881c5ba12a54c39f0bbae09e129a9d57c",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

---

# Docker Storage

기본적으로 컨테이너 내부에 생성된 모든 파일은 쓰기 가능한 컨테이너 계층에 저장된다.

이것은 다음을 의미한다.

- 해당 컨테이너가 더이상 존재하지 않으면 데이터가 지속되지 않으며 다른 프로세스에 필요한 경우 컨테이너에서 데이터를 가져오는 것이 어려울 수 있다.
- 컨테이너의 쓰기 가능한 계층은 컨테이너가 실행 중인 호스트 시스템에 단단히 연결된다. 데이터를 다른 곳으로 쉽게 이동할 수 없다.
- 컨테이너의 쓰기 가능한 레이어에 쓰려면 파일 시스템을 관리하기 위한 스토리지 드라이버가 필요하다. 스토리지 드라이버는 Linux 커널을 사용하여 통합 파일 시스템을 제공한다. 이 추가적인 추상화는 호스트 파일 시스템에 직접 쓰는 데이터 볼륨을 사용하는 것과 비교하여 성능을 저하시킨다.

도커에는 컨테이너가 호스트 시스템에 파일을 저장하는 두 가지 옵션이 있으므로 컨테이너가 중지된 후에도 파일을 유지시킬 수 있다. (Volume 및 Bind Mount)

Linux에서 도커를 실행중인 경우 tmpfs 마운트를 사용할 수도 있다.

![/assets/images/link-docker/Untitled.png](/assets/images/link-docker/Untitled.png)

**[볼륨(Volume)](https://docs.docker.com/v18.09/storage/volumes/)**은 도커가 관리하는 호스트 파일 시스템의 일부(Linux의 경우 /var/lib/docker/volumes/)에 저장된다.

도커가 아닌 프로세스는 파일 시스템의 이 부분을 수정하면 안된다.

볼륨은 도커에서 데이터를 유지하는 가장 좋은 방법이다.

**[바인드 마운트(Bind Mount)](https://docs.docker.com/v18.09/storage/bind-mounts/)**는 호스트 시스템의 어느 곳에나 저장될 수 있다.

볼륨과는 다르게 호스트 시스템의 어느 곳에나 파일이 존재할 수 있기 때문에 도커 이외의 프로세스도 파일을 수정할 수 있다.

**[tmpfs 마운트](https://docs.docker.com/v18.09/storage/tmpfs/)**는 호스트 시스템의 메모리에만 저장되며 호스트 시스템의 파일 시스템에는 기록되지 않는다.

이 외에 [컨테이너 내에 데이터를 저장하는 방법](https://docs.docker.com/v18.09/storage/storagedriver/)도 있다.

---

# 참고

[Docker 18.09 Document](https://docs.docker.com/v18.09/engine/docker-overview/)

[초보를 위한 도커 안내서 - 도커란 무엇인가?](https://subicura.com/2017/01/19/docker-guide-for-beginners-1.html)

[전가상화 반가상화](https://blog.naver.com/alice_k106/220218878967)
