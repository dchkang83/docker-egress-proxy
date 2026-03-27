.PHONY: help setup start stop test logs

help: ## 사용 가능한 명령어 목록
	@echo "Docker Egress Proxy — Docker 컨테이너가 호스트 IP로 외부 API에 접근하도록 하는 Squid 프록시"
	@echo ""
	@echo "사용법:"
	@echo "  make start → 프록시 시작 후 다른 프로젝트 docker-compose에 아래 환경변수 추가:"
	@echo ""
	@echo '    environment:'
	@echo '      HTTP_PROXY:  "http://host.docker.internal:3128"'
	@echo '      HTTPS_PROXY: "http://host.docker.internal:3128"'
	@echo '      NO_PROXY:    "localhost,127.0.0.1,host.docker.internal"'
	@echo ""
	@echo "명령어:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## 초기 환경 설정 (squid 설치 확인)
	@echo "환경 확인 중..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		if command -v squid >/dev/null 2>&1; then \
			echo "  ✅ squid 설치됨: $$(squid -v 2>&1 | head -1)"; \
		else \
			echo "  ❌ squid 미설치 — 설치합니다..."; \
			brew install squid; \
		fi; \
		if command -v docker >/dev/null 2>&1; then \
			echo "  ✅ docker 설치됨: $$(docker --version)"; \
		else \
			echo "  ⚠️  docker 미설치 (테스트 시 필요)"; \
		fi; \
	else \
		if command -v docker >/dev/null 2>&1; then \
			echo "  ✅ docker 설치됨: $$(docker --version)"; \
		else \
			echo "  ❌ docker 미설치 — docker를 먼저 설치하세요"; \
			exit 1; \
		fi; \
		if docker compose version >/dev/null 2>&1; then \
			echo "  ✅ docker compose 설치됨: $$(docker compose version --short)"; \
		else \
			echo "  ❌ docker compose 미설치"; \
			exit 1; \
		fi; \
	fi
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "  📄 .env 파일 생성됨 (.env.example → .env)"; \
	else \
		echo "  ✅ .env 파일 존재"; \
	fi
	@if [ "$$(uname)" = "Darwin" ]; then \
		if [ ! -d /var/run/squid ]; then \
			echo "  📁 /var/run/squid 디렉토리 생성 (sudo 필요)..."; \
			sudo mkdir -p /var/run/squid && sudo chown $$(whoami) /var/run/squid; \
			echo "  ✅ /var/run/squid 생성 완료"; \
		else \
			echo "  ✅ /var/run/squid 디렉토리 존재"; \
		fi; \
	fi
	@echo ""
	@echo "✅ 설정 완료 — make start 로 프록시를 시작하세요"

start: ## 프록시 시작 (macOS: brew, Linux: docker compose)
	@./scripts/start.sh

stop: ## 프록시 중지
	@./scripts/stop.sh

test: ## 프록시 동작 테스트
	@./scripts/test.sh

logs: ## Squid 로그 확인
	@if [ "$$(uname)" = "Darwin" ]; then \
		tail -f $$(brew --prefix)/var/log/squid/access.log 2>/dev/null || echo "로그 파일이 없습니다. 프록시를 먼저 시작하세요."; \
	else \
		docker compose logs -f squid; \
	fi
