// game_thread.rb:11
export type GameThreadType = 'no_hitter' | 'game_thread';
export const gameThreadTypes: GameThreadType[] = ['no_hitter', 'game_thread'] as const;

// game_thread.rb:12
export type GameThreadStatus = 'Future' | 'Pregame' | 'Posted' | 'Over' | 'Removed' | 'Postponed' | 'External';
export const gameThreadStatuses: GameThreadStatus[] = [
  'Future',
  'Pregame',
  'Posted',
  'Over',
  'Removed',
  'Postponed',
  'External',
] as const;
