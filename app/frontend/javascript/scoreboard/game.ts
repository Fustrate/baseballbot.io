import { DateTime } from 'luxon';

const pregameStatuses = new Set(['Preview', 'Pre-Game', 'Warmup', 'Delayed Start', 'Scheduled']);
const inProgressStatuses = new Set(['In Progress', 'Manager Challenge']);

interface TeamsData {
  away: Record<string, any>;
  home: Record<string, any>;
}

class Game {
  public data: Record<string, any>;
  public teams: TeamsData;
  public linescore: Record<string, any>;
  public status: Record<string, any>;
  public gamePk: number;
  public gameDate: DateTime;

  public constructor(data: Record<string, any>) {
    this.data = data;

    this.teams = data.teams;
    this.gamePk = data.gamePk;
    this.gameDate = DateTime.fromISO(data.gameDate);

    this.updateData(data);
  }

  public get isPregame(): boolean {
    return pregameStatuses.has(this.data.status.detailedState);
  }

  public get isInProgress(): boolean {
    return inProgressStatuses.has(this.data.status.detailedState);
  }

  public updateData(data: any): void {
    this.data = data;

    this.linescore = data.linescore;
    this.status = data.status;
  }
}

export default Game;
