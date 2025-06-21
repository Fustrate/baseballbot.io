import { start } from '@fustrate/rails';
import GenericPage from '@fustrate/rails/generic-page';

import Game from '@/scoreboard/game';
import GameCard from '@/scoreboard/game-card';

import loadSchedule, { type ScheduleGame } from '@/statsapi/schedule';

const secondsBetweenReloads = 30;

class Scoreboard extends GenericPage {
  public date: Date;
  public gameCards: GameCard[];

  public override fields: {
    loadingIndicator: HTMLDivElement;
    cardsContainer: HTMLDivElement;
  };

  public override async initialize(): Promise<void> {
    await super.initialize();

    this.date = new Date();

    await this.createGameCards();

    window.setInterval(this.updateGameCards.bind(this), secondsBetweenReloads * 1000);
  }

  protected async createGameCards(): Promise<void> {
    const gamesData = await this.reloadGameInfo();

    const spacer = document.createElement('div');
    spacer.className = 'card-spacer';

    this.gameCards = gamesData.map((gameData) => {
      const gameCard = new GameCard(new Game(gameData));

      this.fields.cardsContainer.append(gameCard.card);

      return gameCard;
    });

    for (let i = 0; i < 5; i += 1) {
      this.fields.cardsContainer.append(spacer.cloneNode());
    }
  }

  protected async updateGameCards(): Promise<void> {
    const games = await this.reloadGameInfo();

    const dataByPk: Record<number, ScheduleGame> = {};

    for (const gameData of games) {
      dataByPk[gameData.gamePk] = gameData;
    }

    for (const gameCard of this.gameCards) {
      gameCard.update(dataByPk[gameCard.game.gamePk]);
    }
  }

  protected async reloadGameInfo(): Promise<ScheduleGame[]> {
    this.fields.loadingIndicator.style.display = '';

    const schedule = await loadSchedule(this.date);

    this.fields.loadingIndicator.style.display = 'none';

    return schedule.dates[0]?.games ?? [];
  }
}

start(new Scoreboard());
