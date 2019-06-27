import moment from 'moment';

import { JsonData } from '@fustrate/rails';

const pregameStatuses = ['Preview', 'Pre-Game', 'Warmup', 'Delayed Start', 'Scheduled'];
const inProgressStatuses = ['In Progress', 'Manager Challenge'];

class Game {
  public data: JsonData;
  public teams: JsonData;
  public linescore: JsonData;
  public status: JsonData;
  public gamePk: number;
  public gameDate: moment.Moment;

  constructor(data: JsonData) {
    this.data = data;

    this.teams = data.teams;
    this.gamePk = data.gamePk;
    this.gameDate = moment(data.gameDate);

    this.updateData(data);
  }

  get isPregame() {
    return pregameStatuses.includes(this.data.status.detailedState);
  }

  get isInProgress() {
    return inProgressStatuses.includes(this.data.status.detailedState);
  }

  updateData(data) {
    this.data = data;

    this.linescore = data.linescore;
    this.status = data.status;
  }
}

export default Game;
