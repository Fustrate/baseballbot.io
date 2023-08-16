import GenericPage from '@fustrate/rails/generic_page';

import BaseballBot from 'js/baseballbot';
import GameCard from 'js/scoreboard/game_card';
import Game from 'js/scoreboard/game';

import loadSchedule, { type ScheduleGame } from 'js/statsapi/schedule';

const secondsBetweenReloads = 30;

class Scoreboard extends GenericPage {
  public date: Date;
  public gameCards: GameCard[];

  public override fields: {
    loadingIndicator: HTMLDivElement;
    cardsContainer: HTMLDivElement;
  };

  public override async initialize(): Promise<void> {
    super.initialize();

    this.date = new Date();

    this.createGameCards();

    window.setInterval(this.updateGameCards.bind(this), secondsBetweenReloads * 1000);
  }

  protected async createGameCards(): Promise<void> {
    const gamesData = await this.reloadGameInfo();

    const spacer = document.createElement('div');
    spacer.className = 'card-spacer';

    this.gameCards = gamesData.map((gameData) => {
      const gameCard = new GameCard(new Game(gameData));

      this.fields.cardsContainer.appendChild(gameCard.card);

      return gameCard;
    });

    for (let i = 0; i < 5; i += 1) {
      this.fields.cardsContainer.appendChild(spacer.cloneNode());
    }
  }

  protected async updateGameCards(): Promise<void> {
    const games = await this.reloadGameInfo();

    const dataByPk: Record<number, ScheduleGame> = {};

    games.forEach((gameData) => {
      dataByPk[gameData.gamePk] = gameData;
    });

    this.gameCards.forEach((gameCard) => {
      gameCard.update(dataByPk[gameCard.game.gamePk]);
    });
  }

  protected async reloadGameInfo(): Promise<ScheduleGame[]> {
    this.fields.loadingIndicator.style.display = '';

    const schedule = await loadSchedule(this.date);

    this.fields.loadingIndicator.style.display = 'none';

    return schedule.dates[0]?.games ?? [];
  }
}

BaseballBot.start(Scoreboard);
