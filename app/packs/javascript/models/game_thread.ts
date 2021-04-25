import moment, { Moment } from 'moment';
import { Record } from '@fustrate/rails';

import { gameThreadPath, gameThreadsPath } from 'js/routes';
import Subreddit from './subreddit';

export interface JSONData {
  id: number;
  postAt: string;
  startsAt: string;
  status: string;
  title?: string;
  postId?: string;
  gamePk: number;
  preGamePostId?: number;
  postGamePostId?: number;
  createdAt: string;
  updatedAt: string;
  subreddit: {
    id: number;
    name: string;
    teamId: number;
  };
}

export default class GameThread extends Record {
  public static classname = 'GameThread';
  public static createPath = gameThreadsPath;

  public id: number;
  public gamePk: number;
  public postAt: Moment;
  public postId: string;
  public startsAt: Moment;
  public status: string;
  public subreddit: Subreddit;
  public title: string;

  public path(options?: { [s: string]: any }): string {
    return gameThreadPath(this.id, options);
  }

  public extractFromData(data: { [s: string]: any }): { [s: string]: any } {
    super.extractFromData(data);

    this.id = data.id;
    this.gamePk = data.gamePk;
    this.postAt = moment(data.postAt);
    this.postId = data.postId;
    this.startsAt = moment(data.startsAt);
    this.status = data.status;
    this.subreddit = Subreddit.build(data.subreddit);
    this.title = data.title;

    return data;
  }
}
