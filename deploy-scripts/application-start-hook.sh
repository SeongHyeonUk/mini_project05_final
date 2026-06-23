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

# DB(RDS 등) 접속 정보 주입.
# 비밀번호를 git에 올리지 않도록 EC2에만 두는 env 파일을 읽는다.
#   sudo mkdir -p /etc/chaekdam
#   sudo tee /etc/chaekdam/db.env >/dev/null <<'EOF'
#   DB_HOST=chaekdam.xxxx.ap-northeast-2.rds.amazonaws.com
#   DB_PORT=3306
#   DB_NAME=bookapp
#   DB_USERNAME=admin
#   DB_PASSWORD=********
#   CORS_ALLOWED_ORIGINS=http://<프론트-도메인-또는-IP>
#   EOF
#   sudo chmod 600 /etc/chaekdam/db.env
# 파일이 없으면 application.yaml 기본값(localhost)으로 동작한다.
ENV_FILE="/etc/chaekdam/db.env"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
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
