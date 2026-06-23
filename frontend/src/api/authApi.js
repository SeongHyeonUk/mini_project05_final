import { apiFetch } from './apiClient';
import { API_BASE_URL } from './config';

const API_URL = `${API_BASE_URL}/auth`;

export const signup = (data) =>
  apiFetch(`${API_URL}/signup`, { method: 'POST', body: data, errorMsg: '회원가입에 실패했습니다.', parseBodyFirst: true });

export const login = (data) =>
  apiFetch(`${API_URL}/login`, { method: 'POST', body: data, errorMsg: '로그인에 실패했습니다.', parseBodyFirst: true });
