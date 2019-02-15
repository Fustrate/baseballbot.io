import $ from 'jquery';
import moment from 'moment';

import GameCard from './game_card';

const gdx = 'http://gdx.mlb.com/components/game/mlb';

class Gameday {
  constructor() {
    this.loading = $('.loading');

    this.date = moment();

    this.reloadGameInfo(this.date, this.createGameCards);

    window.setInterval(() => {
      this.reloadGameInfo(this.date, this.updateGameCards);
    }, 15000);
  }

  createGameCards(gameNodes) {
    const nodes = [];

    const spacer = document.createElement('div');
    spacer.className = 'card-spacer';

    gameNodes.forEach((element) => {
      nodes.push((new GameCard(this.constructor.elementAttributes(element))).render());
    });

    for (let i = 0; i < 5; i += 1) {
      nodes.push(spacer.cloneNode());
    }

    $('.game-cards').empty().append(nodes);
  }

  updateGameCards(gameNodes) {
    gameNodes.forEach((element) => {
      const attributes = this.constructor.elementAttributes(element);

      $(`#${attributes.gameday_link}`).data('game-card').update(attributes);
    });
  }

  static elementAttributes(element) {
    const attributes = {};

    element.attributes.forEach((attribute) => {
      if (attribute.specified) {
        attributes[attribute.name] = attribute.value;
      }
    });

    return attributes;
  }

  reloadGameInfo(date, onLoad = () => {}) {
    this.loading.show();

    const dateFolder = date.format('[year_]YYYY[/month_]MM[/day_]DD');

    $.get(`${gdx}/${dateFolder}/miniscoreboard.xml`).done((response) => {
      onLoad($(response).find('games game'));

      this.loading.hide();
    });
  }
}

export default Gameday;
