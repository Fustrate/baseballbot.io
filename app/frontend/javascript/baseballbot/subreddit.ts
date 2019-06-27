import { Record, PathParameters } from '@fustrate/rails/dist/js/Record';
import { subredditPath, subredditsPath } from '../routes';

import Template from './template';

export default class Subreddit extends Record {
  public static classname = 'Subreddit';

  public id: number;
  public options: { [s: string]: any };
  public templates: Template[];

  public static createPath(parameters: PathParameters = {}) {
    return subredditsPath(parameters);
  }

  path(parameters: PathParameters = {}) {
    return subredditPath(this.id, parameters);
  }

  public static postAtFormat(postAt?: string) {
    if (!postAt) {
      return '3 Hours Pregame';
    }

    if (/^-?\d{1,2}$/.test(postAt)) {
      return `${Math.abs(parseInt(postAt, 10))} Hours Pregame`;
    }

    if (/(1[012]|\d)(:\d\d|) ?(am|pm)/i.test(postAt)) {
      return `at ${postAt}`;
    }

    // Bad format, default back to 3 hours pregame
    return '3 Hours Pregame';
  }
}
