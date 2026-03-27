#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ "$(uname)" == "Darwin" ]]; then
    echo "🛑 Squid 중지 (brew)..."
    brew services stop squid
else
    echo "🛑 Squid 중지 (docker)..."
    cd "$PROJECT_DIR"
    docker compose down
fi

echo "✅ 중지 완료"
