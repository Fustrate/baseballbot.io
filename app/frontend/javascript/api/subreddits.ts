import { apiSubredditPath, apiSubredditsPath } from '@/utilities/routes';

interface SubredditGameThreadOptions {
  enabled: boolean;
  flairId?: {
    default?: string;
  };
  postAt: string;
  sticky?: boolean;
  stickyComment?: string;
  title: {
    default: string;
    postseason?: string;
  };
}

interface SubredditPregameOptions {
  enabled: boolean;
  postAt: string;
  sticky?: boolean;
  stickyComment?: string;
  flairId?: {
    default?: string;
  };
}

interface SubredditPostgameOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title: {
    default: string;
    won?: string;
    lost?: string;
  };
  flairId?: {
    default?: string;
    won?: string;
    lost?: string;
  };
}

interface SubredditOffDayOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title: string;
  postAt: string;
  lastRunAt: string;
  flairId?: {
    default?: string;
  };
}

interface SubredditSidebarOptions {
  enabled: boolean;
}

interface SubredditOptions {
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
