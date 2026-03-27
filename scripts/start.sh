#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SQUID_CONF="$PROJECT_DIR/squid.conf"

# macOS: brew로 squid 직접 실행 (호스트 IP로 나가야 하므로)
if [[ "$(uname)" == "Darwin" ]]; then
    echo "🍎 macOS 감지 — brew squid 사용"

    if ! command -v squid &>/dev/null; then
        echo "📦 squid 설치 중..."
        brew install squid
    fi

    # 기존 squid 중지
    brew services stop squid 2>/dev/null || true

    # PID 디렉토리 확인/생성
    if [ ! -d /var/run/squid ]; then
        echo "📁 /var/run/squid 디렉토리 생성 (sudo 필요)..."
        sudo mkdir -p /var/run/squid && sudo chown "$(whoami)" /var/run/squid
    fi

    # 설정 파일 복사
    BREW_CONF="$(brew --prefix)/etc/squid.conf"
    cp "$SQUID_CONF" "$BREW_CONF"

    # 로그 디렉토리 확인/생성
    SQUID_LOG_DIR="$(brew --prefix)/var/log/squid"
    mkdir -p "$SQUID_LOG_DIR" 2>/dev/null || true

    # 캐시 디렉토리 초기화
    squid -z -f "$BREW_CONF" 2>/dev/null || true

    # 시작
    brew services start squid

    echo ""
    echo "✅ Squid 프록시 실행 중: http://localhost:3128"

else
    echo "🐧 Linux 감지 — docker compose 사용"
    cd "$PROJECT_DIR"
    docker compose up -d --build
    echo ""
    echo "✅ Squid 프록시 실행 중: http://localhost:3128"
fi

echo ""
echo "📋 다른 docker-compose에서 사용법:"
echo "   environment:"
echo '     HTTP_PROXY: "http://host.docker.internal:3128"'
echo '     HTTPS_PROXY: "http://host.docker.internal:3128"'
echo '     NO_PROXY: "localhost,127.0.0.1,host.docker.internal"'
