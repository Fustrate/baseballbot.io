import { DateTime } from 'luxon';
import BaseRecord from '@fustrate/rails/record';

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

export default class GameThread extends BaseRecord {
  public static override classname = 'GameThread';
  public static createPath = gameThreadsPath;

  public gamePk: number;
  public postAt: DateTime;
  public postId: string;
  public startsAt: DateTime;
  public status: string;
  public subreddit: Subreddit;
  public title: string;

  public override path(options?: Record<string, any>): string {
    return gameThreadPath(this.id, options);
  }

  public override extractFromData(data: Record<string, any>): Record<string, any> {
    super.extractFromData(data);

    this.id = data.id;
    this.gamePk = data.gamePk;
    this.postAt = DateTime.fromISO(data.postAt);
    this.postId = data.postId;
    this.startsAt = DateTime.fromISO(data.startsAt);
    this.status = data.status;
    this.subreddit = Subreddit.build(data.subreddit);
    this.title = data.title;

    return data;
  }
}
