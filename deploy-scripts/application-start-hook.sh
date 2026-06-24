#!/usr/bin/env bash
set -euo pipefail

# 앱은 systemd 유닛(chaekdam.service)이 단일 프로세스로 관리한다.
#   - ExecStart: java -jar /opt/chaekdam/bookapp-0.0.1-SNAPSHOT.jar
#   - EnvironmentFile: /opt/chaekdam/db.env  (DB 접속정보 + CORS_ALLOWED_ORIGINS)
#   - Restart=always
# 따라서 배포 훅은 직접 java를 띄우지 않고 systemd 재시작만 호출한다.
# (과거에 nohup java 로 직접 띄우다가 systemd 프로세스와 8080 포트 충돌이 발생했음)

SERVICE="chaekdam"

# 유닛 파일이 변경되었을 수 있으니 reload 후 재시작.
systemctl daemon-reload
systemctl restart "${SERVICE}"

# 기동 헬스 체크: 최대 60초 동안 8080 응답을 기다린다.
# 루트(/)가 404여도 "응답이 온다"는 것은 서버가 떴다는 뜻이므로 -f 는 쓰지 않는다.
for _ in {1..30}; do
  if curl -sS -o /dev/null "http://localhost:8080/" 2>/dev/null; then
    echo "${SERVICE} is up on port 8080."
    exit 0
  fi
  sleep 2
done

echo "${SERVICE} failed to become healthy within 60s. Recent logs:" >&2
journalctl -u "${SERVICE}" -n 50 --no-pager >&2 || true
exit 1
