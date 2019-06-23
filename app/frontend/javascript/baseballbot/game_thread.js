import moment from 'moment';
import { Record } from '@fustrate/rails';

import { gameThreadPath, gameThreadsPath } from '../routes';

class GameThread extends Record {
  path({ format } = {}) {
    return gameThreadPath(this.id, { format });
  }

  extractFromData(data) {
    super.extractFromData(data);

    this.postAt = moment(this.postAt);
    this.startsAt = moment(this.startsAt);
  }
}

GameThread.createPath = gameThreadsPath;
GameThread.classname = 'GameThread';

export default GameThread;
