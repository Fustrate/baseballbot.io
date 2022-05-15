import { GenericPage } from '@fustrate/rails';
import { DateTime } from 'luxon';

import loadSchedule, { type ScheduleGame } from 'js/statsapi/schedule';
import { setChildren } from 'js/utilities';

import BaseballBot from 'js/baseballbot';

function optionForGame(game: ScheduleGame): HTMLOptionElement {
  const away = game.teams.away.team.teamName;
  const home = game.teams.home.team.teamName;
  const startTimeET = DateTime.fromISO(game.gameDate).setZone('America/New_York').toFormat('h:mm a');

  const option = document.createElement('option');

  option.value = String(game.gamePk);
  option.textContent = `${away} @ ${home} - ${game.status.detailedState} - ${startTimeET}`;

  return option;
}

class NewGameThreadForm extends GenericPage {
  public override fields: {
    date: HTMLInputElement;
    gamePk: HTMLSelectElement;
    postAt: HTMLInputElement;
  };

  public override async initialize(): Promise<void> {
    super.initialize();

    this.changedDate();
  }

  protected override addEventListeners(): void {
    this.fields.date.addEventListener('change', this.changedDate.bind(this));
  }

  protected async changedDate(): Promise<void> {
    const dateValue = this.fields.date.value;

    if (!dateValue) {
      this.availableGames = [];

      return;
    }

    const luxonDate = DateTime.fromISO(dateValue);

    const schedule = await loadSchedule(luxonDate.toJSDate());

    this.availableGames = schedule.dates[0]?.games ?? [];
  }

  protected set availableGames(scheduleGames: ScheduleGame[]) {
    const games = scheduleGames.filter((game) => game.status.abstractGameState !== 'Final');

    if (games.length === 0) {
      this.fields.gamePk.textContent = '';

      this.fields.gamePk.setAttribute('disabled', 'disabled');
    } else {
      setChildren(this.fields.gamePk, [document.createElement('option'), ...games.map((game) => optionForGame(game))]);

      this.fields.gamePk.removeAttribute('disabled');
    }
  }
}

BaseballBot.start(NewGameThreadForm);
