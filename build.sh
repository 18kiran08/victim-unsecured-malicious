#!/usr/bin/env bash
# Baseline build script — main branch's harmless version.
# The attacker fork replaces this file with an exfiltration payload.
set -euo pipefail

echo "==> Building example project"
echo "Hello from build.sh on $(uname -a)"
echo "==> Done"
