import moment from 'moment';

import { JsonData } from '@fustrate/rails';

const pregameStatuses = ['Preview', 'Pre-Game', 'Warmup', 'Delayed Start', 'Scheduled'];
const inProgressStatuses = ['In Progress', 'Manager Challenge'];

interface TeamsData {
  away: { [s: string]: any };
  home: { [s: string]: any };
}

class Game {
  public data: JsonData;
  public teams: TeamsData;
  public linescore: JsonData;
  public status: JsonData;
  public gamePk: number;
  public gameDate: moment.Moment;

  public constructor(data: JsonData) {
    this.data = data;

    this.teams = data.teams;
    this.gamePk = data.gamePk;
    this.gameDate = moment(data.gameDate);

    this.updateData(data);
  }

  public get isPregame(): boolean {
    return pregameStatuses.includes(this.data.status.detailedState);
  }

  public get isInProgress(): boolean {
    return inProgressStatuses.includes(this.data.status.detailedState);
  }

  public updateData(data: any): void {
    this.data = data;

    this.linescore = data.linescore;
    this.status = data.status;
  }
}

export default Game;
