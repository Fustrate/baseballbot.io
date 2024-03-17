export type GameThreadStatus = 'Future' | 'Pregame' | 'Posted' | 'Over' | 'Removed' | 'Postponed' | 'Foreign';
export type GameThreadType = 'no_hitter' | 'game_thread';

export const gameThreadStatuses: GameThreadStatus[] = ['Future', 'Pregame', 'Posted', 'Over', 'Removed', 'Postponed', 'Foreign'] as const;
export const gameThreadTypes: GameThreadType[] = ['no_hitter', 'game_thread'] as const;
