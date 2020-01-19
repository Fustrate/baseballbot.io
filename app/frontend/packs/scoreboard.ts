import moment from 'moment';
import Page from '@fustrate/rails/dist/js/Page';

import GameCard from '../javascript/scoreboard/game_card';
import Game from '../javascript/scoreboard/game';

import '../stylesheets/scoreboard.scss';
import BaseballBot from '../javascript/baseballbot';

const secondsBetweenReloads = 30;
const apiEndpoint = 'https://statsapi.mlb.com/api/v1/schedule/?sportId=1&hydrate=game(content(summary)),linescore(runners),flags,team';

class Scoreboard extends Page {
  public date: moment.Moment;
  public loading: HTMLDivElement;
  public container: HTMLDivElement;
  public gameCards: GameCard[];

  initialize() {
    this.date = moment();

    this.loading = document.querySelector('.loading');
    this.container = document.querySelector('.game-cards');

    this.reloadGameInfo((data: any[]) => {
      this.createGameCards(data.map((gameData: any) => new Game(gameData)));
    });

    window.setInterval(() => {
      this.reloadGameInfo((data: any[]) => {
        this.updateGameCards(data);
      });
    }, secondsBetweenReloads * 1000);
  }

  createGameCards(games: Game[]) {
    const spacer = document.createElement('div');
    spacer.className = 'card-spacer';

    this.gameCards = games.map((game) => {
      const gameCard = new GameCard(game);

      this.container.appendChild(gameCard.card);

      return gameCard;
    });

    for (let i = 0; i < 5; i += 1) {
      this.container.appendChild(spacer.cloneNode());
    }
  }

  updateGameCards(games: any[]) {
    const dataByPk = {};

    games.forEach((gameData) => {
      dataByPk[gameData.gamePk] = gameData;
    });

    this.gameCards.forEach((gameCard) => {
      gameCard.update(dataByPk[gameCard.game.gamePk]);
    });
  }

  reloadGameInfo(onLoad = (games: any[]) => {}) {
    this.loading.style.display = '';

    window.fetch(`${apiEndpoint}&date=${this.date.format('MM/DD/YYYY')}`)
      .then(response => response.json())
      .then((json) => {
        onLoad(json.dates[0]?.games ?? []);

        this.loading.style.display = 'none';
      });
  }
}

BaseballBot.start(new Scoreboard());
