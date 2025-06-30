import { apiSubredditPath, apiSubredditsPath } from '@/utilities/routes';

interface SubredditGameThreadOptions {
  enabled: boolean;
  flairId?: string;
  postAt: string;
  sticky?: boolean;
  stickyComment?: string;
  title:
    | string
    | {
        default: string;
        postseason?: string;
      };
}

interface SubredditPregameOptions {
  enabled: boolean;
  postAt: string;
  sticky?: boolean;
  stickyComment?: string;
}

interface SubredditPostgameOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title:
    | string
    | {
        default: string;
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
  account: {
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
  return fetch(apiSubredditPath(nameOrId)).then((res) => res.json());
}
