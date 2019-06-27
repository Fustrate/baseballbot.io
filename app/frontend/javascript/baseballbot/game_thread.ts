import moment from 'moment';
import { Record, PathParameters } from '@fustrate/rails/dist/js/Record';
import { JsonData } from '@fustrate/rails/dist/js/BasicObject';

import { gameThreadPath, gameThreadsPath } from '../routes';

export default class GameThread extends Record {
  public static classname = 'GameThread';

  public id: number;
  public postAt: moment.Moment;
  public startsAt: moment.Moment;

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

    super.extractFromData(data);

    this.postAt = moment(this.postAt);
    this.startsAt = moment(this.startsAt);

    return data;
  }
}
