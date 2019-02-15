import Record from '../fustrate/record'
import Routes from './routes'

class Subreddit extends Record {
  path({ format } = {}) {
    return Routes.subreddit_path(this.id, { format: format });
  }
}

Subreddit.create_path = Routes.subreddits_path

export default Subreddit
