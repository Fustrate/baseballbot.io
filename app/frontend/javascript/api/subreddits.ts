import type { User } from '@/api/session';
import { apiSubredditPath, apiSubredditsPath } from '@/utilities/routes';

interface SubredditGameThreadOptions {
  enabled: boolean;
  flairId?: string;
  postAt?: string;
  sticky?: boolean;
  stickyComment?: string;
  title?: string;
  'title.postseason'?: string;
}

interface SubredditPregameOptions {
  enabled: boolean;
  postAt?: string;
  sticky?: boolean;
  stickyComment?: string;
  flairId?: string;
}

interface SubredditPostgameOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title?: string;
  'title.won'?: string;
  'title.lost'?: string;
  flairId?: string;
  'flairId.won'?: string;
  'flairId.lost'?: string;
}

interface SubredditOffDayOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title?: string;
  postAt?: string;
  lastRunAt?: string;
  flairId?: string;
}

interface SubredditSidebarOptions {
  enabled: boolean;
}

export interface SubredditOptions {
  timezone: `America/${'Chicago' | 'Denver' | 'Detroit' | 'Los_Angeles' | 'New_York' | 'Phoenix'}`;
  subreddits?: {
    downcase: boolean;
  };
  stickySlot?: 1 | 2;
  sidebar?: SubredditSidebarOptions;
  gameThreads?: SubredditGameThreadOptions;
  pregame?: SubredditPregameOptions;
  postgame?: SubredditPostgameOptions;
  offDay?: SubredditOffDayOptions;
}

export interface Subreddit {
  id: number;
  name: string;
  abbreviation: string;
  options: SubredditOptions;
  bot: {
    id: number;
    name: string;
  };
}

export async function fetchSubreddits(): Promise<Subreddit[]> {
  return fetch(apiSubredditsPath())
    .then((res) => res.json())
    .then((data) => data.data);
}

export async function fetchSubreddit(nameOrId: string | number): Promise<Subreddit> {
  const response = await fetch(apiSubredditPath(nameOrId));

  if (!response.ok) {
    throw new Error('Failed to load subreddit.');
  }

  return response.json();
}

export async function updateSubreddit(nameOrId: string | number, options: SubredditOptions): Promise<Subreddit> {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? '';

  const response = await fetch(apiSubredditPath(nameOrId), {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify({ subreddit: { options } }),
  });

  if (!response.ok) {
    throw new Error('Failed to update subreddit.');
  }

  return response.json();
}

export function isModerator(user: User | null | undefined, subreddit: Subreddit): boolean {
  return user != null && (user.type === 'admin' || user.subreddits.includes(subreddit.id));
}
