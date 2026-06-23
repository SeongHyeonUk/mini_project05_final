#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/chaekdam"
PID_FILE="${APP_DIR}/chaekdam.pid"
LOG_DIR="/var/log/chaekdam"
LOG_FILE="${LOG_DIR}/application.log"

mkdir -p "${APP_DIR}" "${LOG_DIR}"

if [[ -f "${PID_FILE}" ]]; then
  OLD_PID="$(cat "${PID_FILE}")"
  if kill -0 "${OLD_PID}" 2>/dev/null; then
    kill "${OLD_PID}"
    for _ in {1..30}; do
      if ! kill -0 "${OLD_PID}" 2>/dev/null; then
        break
      fi
      sleep 1
    done
  fi
  rm -f "${PID_FILE}"
fi

JAR_FILE="$(find "${APP_DIR}" -maxdepth 1 -type f -name '*.jar' ! -name '*-plain.jar' -print -quit)"
if [[ -z "${JAR_FILE}" ]]; then
  echo "Spring Boot JAR not found in ${APP_DIR}" >&2
  exit 1
fi

cd "${APP_DIR}"
nohup java -jar "${JAR_FILE}" >"${LOG_FILE}" 2>&1 &
NEW_PID=$!
echo "${NEW_PID}" >"${PID_FILE}"

sleep 5
if ! kill -0 "${NEW_PID}" 2>/dev/null; then
  echo "Application failed to start. Recent log output:" >&2
  tail -n 100 "${LOG_FILE}" >&2 || true
  exit 1
fi

echo "Chaekdam started with PID ${NEW_PID}"
