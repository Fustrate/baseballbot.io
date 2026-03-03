import type { Schedule, ScheduleGame } from '@/statsapi/schedule';
import loadSchedule from '@/statsapi/schedule';

export type { Schedule, ScheduleGame };

export async function fetchGames(date: Date, sportId = 1): Promise<ScheduleGame[]> {
  const schedule = await loadSchedule(date, sportId);
  return schedule.dates[0]?.games || [];
}
