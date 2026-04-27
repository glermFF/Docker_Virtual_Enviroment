#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${MODE:-normal}}"
TARGET_URL="${TARGET_URL:-http://vps-target/login.php}"
AUDIT_URL="${AUDIT_URL:-http://kibana:5601/api/status}"
DURATION="${DURATION:-180}"
RPS="${RPS:-5}"
BURST_SIZE="${BURST_SIZE:-10}"
OUTPUT_DIR="${OUTPUT_DIR:-/traffic-host/logs}"
LOG_FILE="${OUTPUT_DIR}/traffic-$(date -u +%Y%m%dT%H%M%SZ).jsonl"
SUMMARY_FILE="${OUTPUT_DIR}/summary-$(date -u +%Y%m%dT%H%M%SZ).txt"

mkdir -p "${OUTPUT_DIR}"
: > "${LOG_FILE}"
: > "${SUMMARY_FILE}"

TOTAL_REQUESTS=0
FAILED_REQUESTS=0
DNS_QUERIES=0
START_EPOCH=$(date +%s)
END_EPOCH=$((START_EPOCH + DURATION))

log_event() {
  local event_name="$1"
  local url="$2"
  local status_code="$3"
  local latency_ms="$4"
  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '{"timestamp":"%s","mode":"%s","event":"%s","url":"%s","status":%s,"latency_ms":%s}\n' \
    "$timestamp" "$MODE" "$event_name" "$url" "$status_code" "$latency_ms" >> "$LOG_FILE"
}

probe_http() {
  local url="$1"
  local event_name="$2"
  local response
  local status_code
  local elapsed_seconds
  local latency_ms

  response="$(curl -sS -o /dev/null -w '%{http_code} %{time_total}' "$url" || echo '000 0')"
  status_code="${response%% *}"
  elapsed_seconds="${response#* }"
  latency_ms="$(awk -v seconds="$elapsed_seconds" 'BEGIN { printf "%.0f", seconds * 1000 }')"

  TOTAL_REQUESTS=$((TOTAL_REQUESTS + 1))
  if [ "$status_code" != "200" ] && [ "$status_code" != "302" ] && [ "$status_code" != "401" ]; then
    FAILED_REQUESTS=$((FAILED_REQUESTS + 1))
  fi

  log_event "$event_name" "$url" "$status_code" "$latency_ms"
}

probe_dns() {
  local host_name="$1"
  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if nslookup "$host_name" >/dev/null 2>&1; then
    DNS_QUERIES=$((DNS_QUERIES + 1))
    printf '{"timestamp":"%s","mode":"%s","event":"dns-lookup","host":"%s","status":"ok"}\n' \
      "$timestamp" "$MODE" "$host_name" >> "$LOG_FILE"
  else
    FAILED_REQUESTS=$((FAILED_REQUESTS + 1))
    printf '{"timestamp":"%s","mode":"%s","event":"dns-lookup","host":"%s","status":"fail"}\n' \
      "$timestamp" "$MODE" "$host_name" >> "$LOG_FILE"
  fi
}

run_normal() {
  while [ "$(date +%s)" -lt "$END_EPOCH" ]; do
    local cycle
    cycle=1
    while [ "$cycle" -le "$RPS" ]; do
      probe_http "$TARGET_URL" "normal-target"
      probe_http "$AUDIT_URL" "normal-audit"
      probe_dns "vps-target"
      cycle=$((cycle + 1))
    done
    sleep 1
  done
}

run_anomaly() {
  while [ "$(date +%s)" -lt "$END_EPOCH" ]; do
    local burst
    burst=1
    while [ "$burst" -le "$BURST_SIZE" ]; do
      probe_http "${TARGET_URL}?probe=${burst}&ts=$(date +%s)" "anomaly-burst"
      burst=$((burst + 1))
    done
    probe_http "$AUDIT_URL" "anomaly-audit"
    probe_dns "kibana"
    sleep 1
  done
}

run_ddos() {
  while [ "$(date +%s)" -lt "$END_EPOCH" ]; do
    local burst
    burst=1
    while [ "$burst" -le "$((BURST_SIZE * 2))" ]; do
      probe_http "${TARGET_URL}?flood=${burst}&ts=$(date +%s)" "ddos-burst"
      burst=$((burst + 1))
    done
    sleep 1
  done
}

case "$MODE" in
  normal)
    run_normal
    ;;
  anomaly)
    run_anomaly
    ;;
  ddos)
    run_ddos
    ;;
  *)
    printf 'Unknown mode: %s\nAllowed modes: normal, anomaly, ddos\n' "$MODE" >&2
    exit 1
    ;;
esac

cat <<EOF >> "$SUMMARY_FILE"
mode=$MODE
target=$TARGET_URL
audit=$AUDIT_URL
duration=$DURATION
rps=$RPS
burst_size=$BURST_SIZE
total_requests=$TOTAL_REQUESTS
failed_requests=$FAILED_REQUESTS
dns_queries=$DNS_QUERIES
log_file=$LOG_FILE
EOF

printf '[traffic-host] mode=%s total_requests=%s failed_requests=%s dns_queries=%s\n' \
  "$MODE" "$TOTAL_REQUESTS" "$FAILED_REQUESTS" "$DNS_QUERIES"
