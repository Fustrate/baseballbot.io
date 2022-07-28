import { Record } from '@fustrate/rails';

import { subredditPath, subredditsPath } from 'js/routes';
import Template, { type JSONData as TemplateData } from './template';

export interface SubredditOptions {
  gameThreads?: {
    enabled: boolean;
    flairId?: {
      default?: string;
      lost?: string;
      won?: string;
    };
    postAt: string;
    sticky?: boolean;
    stickyComment?: string;
    title: {
      default: string;
      postseason?: string;
      wildcard?: string;
    };
  };
  offDay?: {
    enabled: boolean;
    flairId?: string;
    lastRunAt: string;
    postAt: string;
    sticky?: boolean;
    stickyComment?: string;
    title: string;
  };
  postgame?: {
    enabled: boolean;
    flairId?: {
      default?: string;
      lost?: string;
      won?: string;
    };
    sticky?: boolean;
    stickyComment?: string;
    title: {
      default?: string;
      lost?: string;
      postseason?: string;
      won?: string;
    };
  };
  pregame?: {
    title: {
      default: string;
      postseason?: string;
    };
    enabled: boolean;
    flairId?: string;
    postAt: string;
    sticky?: boolean;
    stickyComment?: string;
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

  #templates: Template[] = [];

  public override path(options?: { [s: string]: any }): string {
    return subredditPath(this.id, options);
  }

  public get templates(): Template[] { return this.#templates; }
  public set templates(value: Template[] | TemplateData[]) {
    this.#templates = Template.buildList(value, { eventable: this });
  }
}
