import GameCard from './game_card';

class Gameday {
  constructor() {
    this.loading = $('.loading');

    this.date = moment();

    this._reloadGameInfo(this.date, this.createGameCards);

    window.setInterval(() => {
      return this._reloadGameInfo(this.date, this.updateGameCards);
    }, 15000);
  }

  createGameCards(gameNodes) {
    var nodes = [];

    var spacer = document.createElement('div');
    spacer.className = 'card-spacer';

    for (let element of gameNodes) {
      nodes.push((new GameCard(this._elementAttributes(element))).render());
    }

    for (var n = i = 0; i < 5; n = ++i) {
      nodes.push(spacer.cloneNode());
    }

    $('.game-cards').empty().append(nodes);
  }

  updateGameCards(gameNodes) {
    for (let element of gameNodes) {
      let attributes = this._elementAttributes(element);

      $(`#${attributes.gameday_link}`).data('game-card').update(attributes);
    }
  }

  _elementAttributes(element) {
    var attributes = {};

    for (let attribute of element.attributes) {
      if (attribute.specified) {
        attributes[attribute.name] = attribute.value;
      }
    }

    return attributes;
  }

  _reloadGameInfo(date, onLoad = () => {}) {
    this.loading.show();

    var date_folder = date.format('[year_]YYYY[/month_]MM[/day_]DD');

    $.get(`${this.constructor.gdx}/${date_folder}/miniscoreboard.xml`)
      .done(response => {
        onLoad($(response).find('games game'));

        this.loading.hide();
      });
  }
}

Gameday.gdx = 'http://gdx.mlb.com/components/game/mlb';
