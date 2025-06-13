import type { GameStatus } from './definitions';

const scheduleHydration = 'game(content(summary)),linescore(runners),flags,team';
const apiEndpoint = `https://statsapi.mlb.com/api/v1/schedule/?sportId=1,51&hydrate=${scheduleHydration}`;

interface ScheduleTeam {
  team: {
    teamName: string;
  };
}

export interface ScheduleGame {
  gamePk: number;
  link: string;
  gameType: 'F';
  season: string;
  gameDate: string;
  officialDate: string;
  status: GameStatus;
  teams: {
    away: ScheduleTeam;
    home: ScheduleTeam;
  };
  linescore: any;
  venue: any;
  content: any;
  gameNumber: number;
  publicFacing: boolean;
  doubleHeader: 'Y' | 'N';
  gamedayType: 'P';
  tiebreaker: 'Y' | 'N';
  calendarEventID: string;
  seasonDisplay: string;
  dayNight: 'day' | 'night';
  description: string;
  scheduledInnings: number;
  reverseHomeAwayStatus: boolean;
  gamesInSeries: number;
  seriesGameNumber: number;
  seriesDescription: string;
  flags: {
    noHitter: boolean;
    perfectGame: boolean;
    awayTeamNoHitter: boolean;
    awayTeamPerfectGame: boolean;
    homeTeamNoHitter: boolean;
    homeTeamPerfectGame: boolean;
  };
  recordSource: 'S';
  ifNecessary: 'Y' | 'N';
  ifNecessaryDescription: string;
}

interface ScheduleEvent {
  link: string;
}

interface ScheduleDate {
  date: string;
  totalItems: number;
  totalEvents: number;
  totalGames: number;
  totalGamesInProgress: number;
  games: ScheduleGame[];
  events: ScheduleEvent[];
}

export interface Schedule {
  totalItems: number;
  totalEvents: number;
  totalGames: number;
  totalGamesInProgress: number;
  dates: ScheduleDate[];
}

export default async function loadSchedule(date: Date): Promise<Schedule> {
  const dateStr = date.toISOString().slice(0, 10);

  const response = await window.fetch(`${apiEndpoint}&date=${dateStr}`);

  return response.json() as Promise<Schedule>;
}
