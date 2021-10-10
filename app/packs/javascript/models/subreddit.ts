import { Record } from '@fustrate/rails';

import { subredditPath, subredditsPath } from 'js/routes';
import Template from './template';

export default class Subreddit extends Record {
  public static override classname = 'Subreddit';
  public static createPath = subredditsPath;

  public abbreviation: string;
  public account: { id: number; name: string };
  public name: string;
  public options: { [s: string]: any };
  public templates: Template[];

  public static postAtFormat(postAt?: string): string {
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
