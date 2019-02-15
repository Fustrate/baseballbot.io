import Record from '../fustrate/record';
import Routes from './routes'; // eslint-disable-line import/no-unresolved

class GameThread extends Record {
  static get createPath() { return Routes.game_threads_path; }

  static get class() { return 'GameThread'; }

  path({ format } = {}) {
    return Routes.game_thread_path(this.id, { format });
  }
}

export default GameThread;
