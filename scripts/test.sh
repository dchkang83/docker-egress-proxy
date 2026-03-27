#!/bin/bash
# 프록시 동작 테스트

PROXY="http://localhost:3128"

echo "=== Egress Proxy 테스트 ==="
echo ""

# 1. 프록시 접근 가능 여부
echo "1. 프록시 연결 테스트..."
if curl -s --proxy "$PROXY" -o /dev/null -w "%{http_code}" http://httpbin.org/ip | grep -q "200"; then
    echo "   ✅ 프록시 연결 성공"
else
    echo "   ❌ 프록시 연결 실패 (squid가 실행 중인지 확인)"
    exit 1
fi

# 2. 프록시를 통한 외부 IP 확인
echo ""
echo "2. 외부 IP 확인..."
echo "   프록시 경유:"
curl -s --proxy "$PROXY" http://httpbin.org/ip | python3 -m json.tool 2>/dev/null || curl -s --proxy "$PROXY" http://httpbin.org/ip
echo ""
echo "   직접 접근:"
curl -s http://httpbin.org/ip | python3 -m json.tool 2>/dev/null || curl -s http://httpbin.org/ip

# 3. Docker 컨테이너에서 테스트
echo ""
echo "3. Docker 컨테이너 내부 테스트..."
docker run --rm alpine/curl \
    -s --proxy "http://host.docker.internal:3128" \
    http://httpbin.org/ip 2>/dev/null && echo "   ✅ 컨테이너 → 프록시 → 외부 성공" || echo "   ❌ 컨테이너 테스트 실패"

echo ""
echo "=== 테스트 완료 ==="
