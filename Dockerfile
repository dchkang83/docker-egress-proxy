FROM ubuntu/squid:latest

# 헬스체크
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD squidclient -h 127.0.0.1 -p 3128 mgr:info | grep -q "Squid Object Cache" || exit 1

EXPOSE 3128
