// These definitions were hand-written on 2020-11-21 and are not guaranteed to be up to date.
import { type Venue } from './venue';

// Still need catchers interference
type RunnerEventTypes = 'field_out' | 'single' | 'double' | 'triple' | 'home_run' | 'walk' | 'passed_ball' |
'wild_pitch' | 'intent_walk' | `stolen_base_${'2b' | '3b' | 'home'}` | 'hit_by_pitch' | 'field_error' |
`grounded_into_${'double' | 'triple'}_play`;

type RunnerMovementReasons = 'r_adv_force' | 'r_adv_play' | 'r_force_out' | 'r_doubled_off' |
`r_${'stolen_base' | 'caught_stealing'}_${'2b' | '3b' | 'home'}`;

type FielderCredits = `f_${'putout' | 'fielded_ball' | 'assist' | 'deflection' | 'assist_of' | 'fielding_error'}`;

// Still need catchers interference
type PlayEventTypes = 'field_out' | 'walk' | 'single' | 'double' | 'triple' | 'sac_fly' |
'strikeout' | 'grounded_into_double_play' | 'hit_by_pitch' | 'force_out' | 'triple_play' |
'intent_walk' | 'field_error';

// I assume these types are going to grow rather large.
type GameEvent = 'field_out' | 'game_finished' | 'strikeout';
type LogicalEvent = 'midInning' | 'countChange' | 'newLeftHandedHit' | 'gameStateChangeToGameOver' |
`count${0 | 1 | 2 | 3}${0 | 1 | 2 | 3}` | `count4${0 | 1 | 2}`;

export interface GameStatus {
  abstractGameState: 'Final';
  codedGameState: 'C' | 'F';
  detailedState: string;
  statusCode: 'CG' | 'F';
  abstractGameCode: 'F';
}

// The absolute base of all linkable records
interface LinkableRecord {
  id: number;
  link: string;
}

interface Count {
  balls: 0 | 1 | 2 | 3 | 4;
  strikes: 0 | 1 | 2 | 3;
  outs: 0 | 1 | 2 | 3;
}

interface Pitch {
  // This is not an exhaustive list
  code: 'SI' | 'FF' | 'FC' | 'FS' | 'SL' | 'CH' | 'CU';
  description: string;
}

interface BatSide {
  code: 'L' | 'R' | 'S';
  description: string;
}

interface PitchHand {
  code: 'L' | 'R' | 'S';
  description: string;
}

// The bare bones of a team without hydration
interface BasicTeam extends LinkableRecord {
  name: string;
}

interface Person extends LinkableRecord {
  fullName: string;
}

// Missing: Foul Bunt?
interface Call {
  // B: Ball, S: Swinging Strike, C: Called Strike, X: In Play Out, F: Foul, D: In Play No Out
  // E: In Play Runs, M: Missed Bunt, *B: Ball in Dirt
  code: 'B' | 'X' | 'S' | 'C' | 'F' | 'D' | 'E' | 'M' | '*B';
  description: string;
}

interface Pitcher { code: '1'; name: 'Pitcher'; type: 'Pitcher'; abbreviation: 'P' }
interface Catcher { code: '2'; name: 'Catcher'; type: 'Catcher'; abbreviation: 'C' }
interface FirstBase { code: '3'; name: 'First Base'; type: 'Infielder'; abbreviation: '1B' }
interface SecondBase { code: '4'; name: 'Second Base'; type: 'Infielder'; abbreviation: '2B' }
interface ThirdBase { code: '5'; name: 'Third Base'; type: 'Infielder'; abbreviation: '3B' }
interface Shortstop { code: '6'; name: 'Shortstop'; type: 'Infielder'; abbreviation: 'SS' }
interface LeftFielder { code: '7'; name: 'Outfielder'; type: 'Outfielder'; abbreviation: 'LF' }
interface CenterFielder { code: '8'; name: 'Outfielder'; type: 'Outfielder'; abbreviation: 'CF' }
interface RightFielder { code: '9'; name: 'Outfielder'; type: 'Outfielder'; abbreviation: 'RF' }
interface DesignatedHitter { code: '10'; name: 'Designated Hitter'; type: 'Hitter'; abbreviation: 'DH' }

type Outfielder = LeftFielder | CenterFielder | RightFielder;
type Infielder = FirstBase | SecondBase | ThirdBase | Shortstop;

type Position = Outfielder | Infielder | Pitcher | Catcher | DesignatedHitter;

// A player's primary position can also just be "Outfield"
type PrimaryPosition = Position | { code: 'O'; name: 'Outfield'; type: 'Outfielder'; abbreviation: 'OF' };

interface FullPlayer extends Person {
  firstName: string;
  lastName: string;
  primaryNumber: string;
  birthDate: string;
  currentAge: number;
  birthCity: string;
  birthStateProvince: string;
  birthCountry: string;
  height: string;
  weight: number;
  active: boolean;
  primaryPosition: PrimaryPosition;
  useName: string;
  middleName: string;
  boxscoreName: string;
  // Have there been non-binary personnel tracked by MLB? I don't even know what letters they'd use.
  gender: 'M' | 'F';
  isPlayer: boolean;
  isVerified: boolean;
  draftYear: number;
  mlbDebutDate: string;
  batSide: BatSide;
  pitchHand: PitchHand;
  nameFirstLast: string;
  nameSlug: string;
  firstLastName: string;
  lastFirstName: string;
  lastInitName: string;
  initLastName: string;
  fullfMLName: string;
  fullLFMName: string;
  strikeZoneTop: number;
  strikeZoneBottom: number;
}

interface HomeAndAway<T> {
  away: T;
  home: T;
}

interface MetaData {
  wait: number;
  timeStamp: string;
  gameEvents: GameEvent[];
  logicalEvents: LogicalEvent[];
}

interface BattingStats {
  gamesPlayed?: number;
  flyOuts: number;
  groundOuts: number;
  runs: number;
  doubles: number;
  triples: number;
  homeRuns: number;
  strikeOuts: number;
  baseOnBalls: number;
  intentionalWalks: number;
  hits: number;
  hitByPitch: number;
  avg?: string;
  atBats: number;
  obp?: string;
  slg?: string;
  ops?: string;
  caughtStealing: number;
  stolenBases: number;
  stolenBasePercentage: string;
  groundIntoDoublePlay: number;
  groundIntoTriplePlay: number;
  plateAppearances: number;
  totalBases: number;
  rbi: number;
  leftOnBase: number;
  sacBunts: number;
  sacFlies: number;
  catchersInterference: number;
  pickoffs: number;
  atBatsPerHomeRun: string;
}

interface PitchingStats {
  groundOuts: number;
  airOuts: number;
  runs: number;
  doubles: number;
  triples: number;
  homeRuns: number;
  strikeOuts: number;
  baseOnBalls: number;
  intentionalWalks: number;
  hits: number;
  hitByPitch: number;
  atBats: number;
  obp: string;
  caughtStealing: number;
  stolenBases: number;
  stolenBasePercentage: string;
  era: string;
  inningsPitched: string;
  saveOpportunities: number;
  earnedRuns: number;
  whip: string;
  outs: number;
  completeGames: number;
  shutouts: number;
  hitBatsmen: number;
  balks: number;
  wildPitches: number;
  pickoffs: number;
  groundOutsToAirouts: string;
  rbi: number;
  runsScoredPer9: string;
  homeRunsPer9: string;
  inheritedRunners: number;
  inheritedRunnersScored: number;
  catchersInterference: number;
  sacBunts: number;
  sacFlies: number;
}

interface FieldingStats {
  assists: number;
  putOuts: number;
  errors: number;
  chances: number;
  fielding: string;
  caughtStealing: number;
  passedBall: number;
  gamesStarted: number;
  stolenBases: number;
  stolenBasePercentage: string;
  pickoffs: number;
}

interface Stats {
  batting: BattingStats;
  // For non-pitchers, this is completely empty.
  pitching: Partial<PitchingStats>;
  fielding: FieldingStats;
}

interface GamePlayer {
  person: Person;
  jerseyNumber: string;
  position: Position;
  stats: Stats;
  status: {
    code: 'A' | string;
    description: 'Active' | string;
  };
  parentTeamId: number;
  seasonStats: Stats;
  gameStatus: {
    isCurrentBatter: boolean;
    isCurrentPitcher: boolean;
    isOnBench: boolean;
    isSubstitute: boolean;
  };
  allPositions?: Position[];
}

interface PitchData {
  startSpeed: number;
  endSpeed: number;
  strikeZoneTop: number;
  strikeZoneBottom: number;
  coordinates: Record<string, number>;
  breaks: {
    breakAngle: number;
    breakLength: number;
    breakY: number;
    spinRate: number;
    spinDirection: number;
  };
  zone: number;
  typeConfidence: number;
  plateTime: number;
  extension: number;
}

interface HitData {
  launchSpeed: number;
  launchAngle: number;
  totalDistance: number;
  trajectory: 'line_drive' | 'ground_ball' | 'popup' | 'fly_ball';
  hardness: 'soft' | 'medium' | 'hard';
  location: string;
  coordinates: {
    coordX: number;
    coordY: number;
  };
}

interface PlayEvent {
  details: {
    call?: Call;
    description: string;
    code?: 'X' | '1';
    ballColor?: string;
    trailColor?: string;
    isInPlay?: boolean;
    isStrike?: boolean;
    isBall?: boolean;
    type?: Pitch;
    event: string;
    eventType: 'game_advisory' | 'pitching_substitution' | 'defensive_substitution';
    awayScore: number;
    homeScore: number;
    isScoringPlay: boolean;
    hasReview: boolean;
    fromCatcher?: boolean;
  };
  count: Count;
  pitchData?: PitchData;
  hitData?: HitData;
  index: number;
  playId?: string;
  pitchNumber?: number;
  startTime: string;
  endTime: string;
  isSubstitution?: boolean;
  isPitch: boolean;
  type: 'action' | 'pitch' | 'pickoff';
  player?: LinkableRecord;
  position?: Position;
}

interface PlayRunnerMovement {
  // The batter doesn't have an origin or start, and you only end at a base if you're safe.
  originBase: '1B' | '2B' | '3B' | null;
  start: '1B' | '2B' | '3B' | 'HP' | null;
  end: '1B' | '2B' | '3B' | 'score' | null;
  // Yes, an out at home is logged as 4B - see the final play of 631085
  outBase: '1B' | '2B' | '3B' | '4B' | null;
  isOut: boolean;
  // If a 4th out is necessary to prevent a run scoring, does that get logged properly?
  outNumber: 1 | 2 | 3;
}

interface PlayRunnerDetails {
  event: string;
  eventType: RunnerEventTypes;
  movementReason: RunnerMovementReasons;
  runner: Person;
  responsiblePitcher?: LinkableRecord;
  isScoringEvent: boolean;
  rbi: boolean;
  earned: boolean;
  teamUnearned: boolean;
  playIndex: number;
}

interface PlayRunnerCredit {
  player: LinkableRecord;
  position: Position;
  credit: FielderCredits;
}

interface PlayRunner {
  movement: PlayRunnerMovement;
  details: PlayRunnerDetails;
  credits: PlayRunnerCredit[];
}

interface Play {
  result: {
    type: 'atBat';
    event: string;
    eventType: PlayEventTypes;
    description: string;
    rbi: number;
    awayScore: number;
    homeScore: number;
  };
  about: {
    atBatIndex: number;
    halfInning: 'top' | 'bottom';
    isTopInning: boolean;
    inning: number;
    startTime: string;
    endTime: string;
    isComplete: boolean;
    isScoringPlay: boolean;
    hasReview: boolean;
    hasOut: boolean;
    captivatingIndex: number;
  };
  count: Count;
  matchup: {
    batter: Person;
    batSide: BatSide;
    pitcher: Person;
    pitchHand: PitchHand;
    postOnFirst?: Person;
    postOnSecond?: Person;
    postOnThird?: Person;
    batterHotColdZones: [];
    pitcherHotColdZones: [];
    splits: {
      batter: 'vs_RHP' | 'vs_LHP';
      pitcher: 'vs_LHB' | 'vs_RHB';
      menOnBase: 'Empty' | 'Men_On' | 'RISP' | 'Loaded';
    };
  };
  pitchIndex: number[];
  actionIndex: number[];
  runnerIndex: number[];
  runners: PlayRunner[];
  playEvents: PlayEvent[];
}

export interface Team {
  team: BasicTeam;
  teamStats: Stats;
  players: Record<string, GamePlayer>;
  batters: number[];
  pitchers: number[];
  bench: number[];
  bullpen: number[];
  battingOrder: number[];
  info: {
    title: string;
    fieldList: {
      label: string;
      value: string;
    }[];
  }[];
  note: any[];
}

export interface FullTeam extends BasicTeam {
  season: number;
  venue: Venue;
  teamCode: string;
  fileCode: string;
  abbreviation: string;
  teamName: string;
  locationName: string;
  firstYearOfPlay: string;
  league: LinkableRecord & {
    name: string;
  };
  division: LinkableRecord & {
    name: string;
  };
  sport: LinkableRecord & {
    name: string;
  };
  shortName: string;
  record: {
    gamesPlayed: number;
    wildCardGamesBack: string;
    leagueGamesBack: string;
    springLeagueGamesBack: string;
    sportGamesBack: string;
    divisionGamesBack: string;
    conferenceGamesBack: string;
    leagueRecord: {
      wins: number;
      losses: number;
      pct: string;
    };
    records: any;
    divisionLeader: boolean;
    wins: number;
    losses: number;
    winningPercentage: string;
  };
  springLeague: LinkableRecord & {
    name: string;
    abbreviation: string;
  };
  allStarStatus: 'Y' | 'N';
  active: boolean;
}

export interface Leaders {
  hitDistance: any;
  hitSpeed: any;
  pitchSpeed: any;
}

interface RHE {
  runs: number;
  hits: number;
  errors: number;
  leftOnBase: number;
}

interface LineScoreInning {
  num: number;
  ordinalNum: string;
  home: RHE;
  away: RHE;
}

export interface LineScore extends Count {
  currentInning?: number;
  currentInningOrdinal?: string;
  inningState?: 'Bottom' | 'Top' | 'Middle' | 'End';
  inningHalf?: 'Bottom' | 'Top';
  isTopInning?: boolean;
  scheduledInnings: number;
  innings: LineScoreInning[];
  teams: HomeAndAway<RHE>;
  defense: {
    pitcher?: Person;
    catcher?: Person;
    first?: Person;
    second?: Person;
    third?: Person;
    shortstop?: Person;
    left?: Person;
    center?: Person;
    right?: Person;
    batter?: Person;
    onDeck?: Person;
    inHole?: Person;
    battingOrder?: number;
    team: BasicTeam;
  };
  offense: {
    batter?: Person;
    onDeck?: Person;
    inHole?: Person;
    pitcher?: Person;
    battingOrder?: number;
    team: BasicTeam;
  };
}

export interface BoxScore {
  teams: HomeAndAway<Team>;
  officials: {
    official: Person;
    officialType: string;
  }[];
  info: { label: string; value?: string }[];
  pitchingNotes: any[];
}

export interface GameData {
  game: {
    pk: number;
    type: 'S' | 'R';
    doubleHeader: 'Y' | 'N';
    id: string;
    gamedayType: 'N' | 'P';
    tiebreaker: 'N';
    gameNumber: 1 | 2;
    calendarEventID: string;
    season: string;
    seasonDisplay: string;
  };
  datetime: {
    dateTime: string;
    originalDate: string;
    dayNight: 'day' | 'night';
  };
  status: GameStatus;
  teams: HomeAndAway<FullTeam>;
  players: Record<string, FullPlayer>;
  venue: Venue;
  weather: {
    condition: string;
    temp: string;
    wind: string;
  };
  gameInfo: {
    attendance: number;
    gameDurationMinutes: number;
  };
  review: HomeAndAway<{ used: number; remaining: number }> & {
    hasChallenges: boolean;
  };
  flags: {
    noHitter: boolean;
    perfectGame: boolean;
    awayTeamNoHitter: boolean;
    awayTeamPerfectGame: boolean;
    homeTeamNoHitter: boolean;
    homeTeamPerfectGame: boolean;
  };
  alerts: any[];
  probablePitchers: HomeAndAway<Person>;
  officialScorer?: Person;
  primaryDatacaster: Person;
}

interface HitsByInning {
  team: BasicTeam;
  inning: number;
  pitcher: Person;
  batter: Person;
  coordinates: {
    x: number;
    y: number;
  };
  type: 'O' | 'H';
  description: string;
}

interface InningPlays {
  startIndex: number;
  endIndex: number;
  top: number[];
  bottom: number[];
  hits: HomeAndAway<HitsByInning[]>;
}

export interface LiveData {
  plays: {
    allPlays: Play[];
    currentPlay?: Play;
    scoringPlays: number[];
    playsByInning: InningPlays[];
  };
  linescore: LineScore;
  boxscore: BoxScore;
  decisions?: {
    winner: Person;
    loser: Person;
    save?: Person;
  };
  leaders: Leaders;
}

export interface LiveFeed {
  gamePk: number;
  link: string;
  metaData: MetaData;
  gameData: GameData;
  liveData: LiveData;
}
