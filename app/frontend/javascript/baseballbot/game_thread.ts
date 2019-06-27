import moment from 'moment';
import { Record, PathParameters } from '@fustrate/rails/dist/js/Record';
import { JsonData } from '@fustrate/rails/dist/js/BasicObject';

import { gameThreadPath, gameThreadsPath } from '../routes';
import Subreddit from './subreddit';

export default class GameThread extends Record {
  public static classname = 'GameThread';

  public id: number;
  public gamePk: number;
  public postAt: moment.Moment;
  public postId: string;
  public startsAt: moment.Moment;
  public status: string;
  public subreddit: Subreddit;
  public title: string;

  public static createPath(parameters: PathParameters = {}) {
    return gameThreadsPath(parameters);
  }

  path(parameters: PathParameters = {}) {
    return gameThreadPath(this.id, parameters);
  }

  extractFromData(data?: JsonData): JsonData {
    if (!data) {
      return {};
    }

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
