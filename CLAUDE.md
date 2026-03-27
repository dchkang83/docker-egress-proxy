# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Squid-based egress proxy that allows Docker containers to access external APIs using the host machine's IP address. Solves the problem where containerized apps get blocked by IP whitelists because they egress with the container/VM IP instead of the host IP.

## Key Architecture Decision

On **macOS**, Squid runs directly on the host via Homebrew (not in Docker). This is because Docker Desktop on macOS runs inside a Linux VM — even with `network_mode: host`, traffic exits from the VM's IP, not the Mac's IP. The `docker-compose.yml` is **Linux-only**.

## Commands

```bash
make help    # Show available commands
make start   # Start proxy (auto-detects OS: brew on macOS, docker compose on Linux)
make stop    # Stop proxy
make test    # Verify proxy works (connectivity, IP check, container-through-proxy test)
make logs    # Tail Squid access logs
```

## Configuration

- `squid.conf` — Shared Squid config used by both macOS (copied to brew prefix) and Linux (mounted into container). Listens on port 3128. Allows traffic from Docker bridge/compose/desktop subnets and localhost only.
- `.env.example` — Proxy env vars (`HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`) for use in other projects' docker-compose files.

## Language

Documentation and comments are in Korean.
