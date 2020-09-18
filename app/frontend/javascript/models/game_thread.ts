import moment from 'moment';
import { Record } from '@fustrate/rails/dist/js/Record';

import { gameThreadPath, gameThreadsPath } from 'js/routes';
import Subreddit from './subreddit';

export default class GameThread extends Record {
  public static classname = 'GameThread';
  public static createPath = gameThreadsPath;

  public id: number;
  public gamePk: number;
  public postAt: moment.Moment;
  public postId: string;
  public startsAt: moment.Moment;
  public status: string;
  public subreddit: Subreddit;
  public title: string;

  path(options?: { [s: string]: any }): string {
    return gameThreadPath(this.id, options);
  }

  extractFromData(data: { [s: string]: any }): { [s: string]: any } {
    super.extractFromData(data);

    this.id = data.id;
    this.gamePk = data.gamePk;
    this.postAt = moment(data.postAt);
    this.postId = data.postId;
    this.startsAt = moment(data.startsAt);
    this.status = data.status;
    this.subreddit = new Subreddit(data.subreddit);
    this.title = data.title;

    return data;
  }
}
