import type { PaginatedData } from '@fustrate/rails/components/pagination';
import { DateTime } from 'luxon';
import type { GameThreadStatus } from '@/utilities/constants';
import { apiGameThreadPath, apiGameThreadsPath, gameThreadsApiSubredditPath } from '@/utilities/routes';

interface GameThreadJSON {
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
  subreddit: {
    id: number;
    name: string;
    teamId: number | null;
  };
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
  console.log({ date });

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
