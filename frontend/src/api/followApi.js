import { apiFetch } from './apiClient';
import { API_BASE_URL } from './config';

const BASE = `${API_BASE_URL}/follow`;

export const toggleFollow = (followerId, followingId) =>
  apiFetch(`${BASE}/toggle?followerId=${followerId}&followingId=${followingId}`, { method: 'POST', errorMsg: '팔로우 처리에 실패했습니다.' });

export const getFollowingUsers = (followerId) =>
  apiFetch(`${BASE}/following/${followerId}`, { errorMsg: '팔로잉 목록 조회에 실패했습니다.' });
