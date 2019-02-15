import Record from '../fustrate/record'
import Routes from './routes'

class GameThread extends Record {
  path({ format } = {}) {
    return Routes.game_thread_path(this.id, { format: format });
  }
}

GameThread.create_path = Routes.game_threads_path

export default GameThread
