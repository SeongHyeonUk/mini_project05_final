// API 서버 base URL.
// 빌드 시 환경변수 VITE_API_BASE_URL 로 주입(AWS 배포용), 없으면 로컬 개발 기본값.
// 예) VITE_API_BASE_URL=http://13.124.xx.xx:8080  또는  https://api.chaekdam.com
export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';
