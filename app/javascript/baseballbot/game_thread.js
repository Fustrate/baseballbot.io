import moment from 'moment';
import { Record } from '@fustrate/rails';

import Routes from './routes.js.erb';

class GameThread extends Record {
  static get createPath() { return Routes.game_threads_path; }

  static get class() { return 'GameThread'; }

  path({ format } = {}) {
    return Routes.game_thread_path(this.id, { format });
  }

  extractFromData(data) {
    super.extractFromData(data);

    this.postAt = moment(this.postAt);
    this.startsAt = moment(this.startsAt);
  }
}

export default GameThread;
