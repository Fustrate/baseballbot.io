import Record from '../fustrate/record';
import Routes from './routes'; // eslint-disable-line import/no-unresolved

class Subreddit extends Record {
  static get createPath() { return Routes.subreddits_path; }

  static get class() { return 'Subreddit'; }

  path({ format } = {}) {
    return Routes.subreddit_path(this.id, { format });
  }

  static postAtFormat(postAt) {
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

export default Subreddit;
