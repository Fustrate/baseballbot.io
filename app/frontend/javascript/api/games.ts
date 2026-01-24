import type { Schedule, ScheduleGame } from '@/statsapi/schedule';
import loadSchedule from '@/statsapi/schedule';

export type { Schedule, ScheduleGame };

export async function fetchGames(date: Date): Promise<ScheduleGame[]> {
  const schedule = await loadSchedule(date);
  return schedule.dates[0]?.games || [];
}
