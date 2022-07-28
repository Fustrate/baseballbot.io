import { Record } from '@fustrate/rails';

import { subredditPath, subredditsPath } from 'js/routes';
import Template from './template';

export interface SubredditOptions {
  gameThreads?: {
    enabled: boolean;
    flairId?: {
      default: string;
    };
    postAt: string;
    sticky?: boolean;
    title: {
      default: string;
      postseason?: string;
      wildcard?: string;
    };
  };
  offDay?: {
    enabled: boolean;
    lastRunAt: string;
    postAt: string;
    sticky?: boolean;
    title: string;
  };
  postgame?: {
    enabled: boolean;
    flairId?: {
      won?: string;
      lost?: string;
    };
    sticky?: boolean;
    title: {
      default: string;
      postseason?: string;
    };
  };
  pregame?: {
    title: {
      default: string;
      postseason?: string;
    };
    enabled: boolean;
    postAt: string;
  };
  sidebar?: {
    enabled: boolean;
  };
  stickySlot?: 1 | 2;
  timezone: string;
}

export interface JSONData {
  id: number;
  name: string;
  abbreviation: string;
  account?: {
    id: number;
    name: string;
  };
  options: SubredditOptions;
}

export default class Subreddit extends Record {
  public static override classname = 'Subreddit';
  public static createPath = subredditsPath;

  public abbreviation: string;
  public account: { id: number; name: string };
  public name: string;
  public options: SubredditOptions;
  public templates: Template[];

  public override path(options?: { [s: string]: any }): string {
    return subredditPath(this.id, options);
  }

  public override extractFromData(data: { [s: string]: any }): { [s: string]: any } {
    super.extractFromData(data);

    this.id = data.id;
    this.abbreviation = data.abbreviation;
    this.account = data.account;
    this.name = data.name;
    this.options = data.options;

    if (data.templates) {
      this.templates = Template.buildList(data.templates);
    }

    return data;
  }
}
