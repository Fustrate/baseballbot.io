import type { PaginatedData } from '@fustrate/rails/components/pagination';
import { DateTime } from 'luxon';
import type { Subreddit } from '@/api/subreddits';
import type { GameThreadStatus } from '@/utilities/constants';
import { apiGameThreadPath, apiGameThreadsPath, gameThreadsApiSubredditPath } from '@/utilities/routes';

export interface GameThreadJSON {
  id: number;
  status: GameThreadStatus;
  title: string;
  postId: string | null;
  gamePk: number;
  preGamePostId: string | null;
  postGamePostId: string | null;
  startsAt: string;
  postAt: string;
  createdAt: string;
  updatedAt: string;
  subreddit: Subreddit;
}

export interface GameThread extends Omit<GameThreadJSON, 'startsAt' | 'postAt' | 'createdAt' | 'updatedAt'> {
  postAt: DateTime;
  startsAt: DateTime;
  createdAt: DateTime;
  updatedAt: DateTime;
}

function buildGameThread(data: GameThreadJSON): GameThread {
  return {
    ...data,
    startsAt: DateTime.fromISO(data.startsAt),
    postAt: DateTime.fromISO(data.postAt),
    createdAt: DateTime.fromISO(data.createdAt),
    updatedAt: DateTime.fromISO(data.updatedAt),
  };
}

export async function fetchGameThreads({ date }: { date: DateTime }): Promise<PaginatedData<GameThread>> {
  return fetch(apiGameThreadsPath({ date: date.toISODate() }))
    .then((res) => res.json())
    .then((data) => {
      return {
        pagination: data.pagination,
        data: data.data.map((item: GameThreadJSON) => buildGameThread(item)),
      };
    });
}

export async function fetchGameThread(id: number): Promise<GameThread> {
  return fetch(apiGameThreadPath(id)).then((res) => res.json());
}

export async function fetchSubredditGameThreads(subreddit: string | number): Promise<PaginatedData<GameThread>> {
  return fetch(gameThreadsApiSubredditPath(subreddit)).then((res) => res.json());
}

export async function createGameThread(data: {
  subredditId: number;
  gamePk: number;
  title: string;
  postAt: DateTime;
}): Promise<GameThread> {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? '';

  const response = await fetch(apiGameThreadsPath(), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify({
      game_thread: {
        subreddit_id: data.subredditId,
        game_pk: data.gamePk,
        title: data.title,
        post_at: data.postAt.toISO(),
      },
    }),
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: 'Failed to create game thread' }));

    throw new Error(error.error || 'Failed to create game thread');
  }

  const json = await response.json();
  return buildGameThread(json);
}
