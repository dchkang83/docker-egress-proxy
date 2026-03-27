# Docker Egress Proxy

Docker 컨테이너가 호스트 IP로 외부 API에 접근할 수 있도록 하는 Squid 프록시.

## 문제

```
[Docker Container] → 컨테이너 IP로 나감 → 사내 API 화이트리스트 거부 ❌
[Host Machine]     → 호스트 IP로 나감   → 사내 API 화이트리스트 허용 ✅
```

## 해결

```
[Docker Container] → Squid(호스트) → 호스트 IP로 나감 → 사내 API 허용 ✅
```

## 사용법

### 1. 초기 설정

```bash
make setup
```

- macOS: squid(brew) 설치 여부 확인, 없으면 자동 설치
- Linux: docker, docker compose 설치 여부 확인
- `.env` 파일이 없으면 `.env.example`에서 자동 생성

### 2. 명령어

```bash
make help    # 사용 가능한 명령어 목록
make setup   # 초기 환경 설정
make start   # 프록시 시작 (OS 자동 감지)
make stop    # 프록시 중지
make test    # 동작 테스트
make logs    # Squid 로그 확인
```

### 3. 다른 프로젝트의 docker-compose에 적용

```yaml
services:
  your-app:
    environment:
      HTTP_PROXY: "http://host.docker.internal:3128"
      HTTPS_PROXY: "http://host.docker.internal:3128"
      NO_PROXY: "localhost,127.0.0.1,host.docker.internal"
```

또는 `.env` 파일 사용:

```bash
cp .env.example /path/to/your-project/.env
```

## 왜 macOS에서 Docker가 아닌 brew로?

macOS Docker는 Linux VM 위에서 동작합니다. `network_mode: host`를 써도 VM의 네트워크를 공유하는 것이지 실제 macOS 호스트의 네트워크가 아닙니다. 따라서 Squid를 Docker 안에 띄우면 여전히 호스트 IP가 아닌 다른 IP로 나갑니다.

**해결**: macOS에서는 Squid를 호스트에 직접 실행 → 호스트 IP로 요청이 나감.

## 파일 구조

```
docker-egress-proxy/
├── Makefile             # make 명령어 (start, stop, test, logs, help)
├── docker-compose.yml   # Linux 서버용
├── Dockerfile
├── squid.conf           # Squid 설정 (공용)
├── .env.example         # 다른 프로젝트에 복사해서 사용
└── scripts/
    ├── start.sh         # 시작 (OS 자동 감지)
    ├── stop.sh          # 중지
    └── test.sh          # 동작 테스트
```
