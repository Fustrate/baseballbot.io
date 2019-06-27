import { Record, PathParameters } from '@fustrate/rails/dist/js/Record';
import { JsonData } from '@fustrate/rails/dist/js/BasicObject';
import { subredditPath, subredditsPath } from '../routes';

import Template from './template';

export default class Subreddit extends Record {
  public static classname = 'Subreddit';

  public id: number;
  public name: string;
  public abbreviation: string;
  public options: { [s: string]: any };
  public templates: Template[];
  public account: { id: number, name: string };

  public static createPath(parameters: PathParameters = {}) {
    return subredditsPath(parameters);
  }

  path(parameters: PathParameters = {}) {
    return subredditPath(this.id, parameters);
  }

  public extractFromData(data?: JsonData): JsonData {
    if (!data) {
      return {};
    }

    this.id = data.id;
    this.name = data.name;
    this.abbreviation = data.abbreviation;
    this.options = data.options;
    this.account = data.account;

    if (data.templates) {
      this.templates = Template.buildList<Template>(data.templates);
    }

    return data;
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
