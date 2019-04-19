import moment from 'moment';

import GameCard from './game_card';

const secondsBetweenReloads = 30;
const apiEndpoint = 'https://statsapi.mlb.com/api/v1/schedule/?sportId=1&hydrate=game(content(summary)),linescore(runners),flags,team';

class Scoreboard {
  static start() {
    Scoreboard.instance = new this();

    document.addEventListener('DOMContentLoaded', () => {
      Scoreboard.instance.initialize();
    });
  }

  initialize() {
    this.date = moment();

    this.loading = document.querySelector('.loading');
    this.container = document.querySelector('.game-cards');

    this.reloadGameInfo(this.createGameCards.bind(this));

    window.setInterval(() => {
      this.reloadGameInfo(this.updateGameCards.bind(this));
    }, secondsBetweenReloads * 1000);
  }

  createGameCards(games) {
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

  updateGameCards(games) {
    const dataByPk = {};

    games.forEach((gameData) => {
      dataByPk[gameData.gamePk] = gameData;
    });

    this.gameCards.forEach((gameCard) => {
      gameCard.update(dataByPk[gameCard.game.gamePk]);
    });
  }

  reloadGameInfo(onLoad = () => {}) {
    this.loading.style.display = '';

    window.fetch(`${apiEndpoint}&date=${this.date.format('MM/DD/YYYY')}`)
      .then(response => response.json())
      .then((json) => {
        onLoad(json.dates[0].games);

        this.loading.style.display = 'none';
      });
  }
}

export default Scoreboard;
