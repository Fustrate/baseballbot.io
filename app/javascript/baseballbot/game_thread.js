import Record from '../fustrate/record'
import Routes from './routes'

class GameThread extends Record {
  static get create_path() { return Routes.game_threads_path }
  static get class() { return 'GameThread' }

  path({ format } = {}) {
    return Routes.game_thread_path(this.id, { format: format });
  }
}

export default GameThread
