import { start } from '@fustrate/rails';
import GenericPage from '@fustrate/rails/generic-page';
import { setChildren } from '@fustrate/rails/html';
import { DateTime } from 'luxon';

import Subreddit from '@/models/subreddit';
import loadSchedule, { type ScheduleGame } from '@/statsapi/schedule';
import { subredditsPath } from '@/utilities/routes';

function optionForGame(game: ScheduleGame): HTMLOptionElement {
  const away = game.teams.away.team.teamName;
  const home = game.teams.home.team.teamName;
  const startTimeET = DateTime.fromISO(game.gameDate).setZone('America/New_York').toFormat('h:mm a');

  const option = document.createElement('option');

  option.value = String(game.gamePk);
  option.textContent = `${away} @ ${home} - ${game.status.detailedState} - ${startTimeET}`;

  return option;
}

// TODO: Use the postseason title if the selected game is a postseason game.
function defaultGameThreadTitle(subreddit: Subreddit): string {
  return subreddit.options?.gameThreads?.title?.default ?? '';
}

class NewGameThreadForm extends GenericPage {
  public override fields: {
    date: HTMLInputElement;
    gamePk: HTMLSelectElement;
    postAt: HTMLInputElement;
    subredditId: HTMLSelectElement;
    title: HTMLInputElement;
  };

  protected subreddits: Record<number, Subreddit> = {};

  public override async initialize(): Promise<void> {
    await super.initialize();

    await this.loadSubreddits();

    await this.changedDate();
  }

  protected override addEventListeners(): void {
    this.fields.date.addEventListener('change', this.changedDate.bind(this));
    this.fields.subredditId.addEventListener('change', this.changedSubreddit.bind(this));
  }

  protected async changedDate(): Promise<void> {
    const dateValue = this.fields.date.value;

    if (!dateValue) {
      this.updateAvailableGames([]);

      return;
    }

    const luxonDate = DateTime.fromISO(dateValue);

    const schedule = await loadSchedule(luxonDate.toJSDate());

    this.updateAvailableGames(schedule.dates[0]?.games ?? []);
  }

  protected changedSubreddit(): void {
    const subredditId = Number(this.fields.subredditId.value);

    const subreddit = this.subreddits[subredditId];

    if (subreddit) {
      this.fields.title.value = defaultGameThreadTitle(subreddit);
    }
  }

  protected updateAvailableGames(scheduleGames: ScheduleGame[]) {
    const games = scheduleGames.filter((game) => game.status.abstractGameState !== 'Final');

    if (games.length === 0) {
      this.fields.gamePk.textContent = '';

      this.fields.gamePk.setAttribute('disabled', 'disabled');
    } else {
      setChildren(this.fields.gamePk, [document.createElement('option'), ...games.map((game) => optionForGame(game))]);

      this.fields.gamePk.removeAttribute('disabled');
    }
  }

  protected async loadSubreddits(): Promise<void> {
    if (Object.keys(this.subreddits).length > 0) {
      return;
    }

    const response = await window.fetch(subredditsPath({ format: 'json' }));

    const data = await response.json();

    this.subreddits = {};

    for (const subredditData of data.data) {
      this.subreddits[subredditData.id] = Subreddit.build(subredditData) as Subreddit;
    }
  }
}

start(new NewGameThreadForm());
