import Record from '../fustrate/record'
import Routes from './routes'

class Subreddit extends Record {
  static get create_path() { return Routes.subreddits_path }
  static get class() { return 'Subreddit' }

  path({ format } = {}) {
    return Routes.subreddit_path(this.id, { format: format });
  }
}

export default Subreddit
