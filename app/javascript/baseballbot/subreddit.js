import Record from '../fustrate/record';
import Routes from './routes'; // eslint-disable-line import/no-unresolved

class Subreddit extends Record {
  static get createPath() { return Routes.subreddits_path; }

  static get class() { return 'Subreddit'; }

  path({ format } = {}) {
    return Routes.subreddit_path(this.id, { format });
  }
}

export default Subreddit;
