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
    var card, cards, element, i, n, nodes, spacer;

    cards = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = gameNodes.length; i < len; i++) {
        element = gameNodes[i];
        results.push(new GameCard(this._elementAttributes(element)));
      }
      return results;
    }).call(this);

    nodes = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = cards.length; i < len; i++) {
        card = cards[i];
        results.push(card.render());
      }
      return results;
    })();

    spacer = document.createElement('div');
    spacer.className = 'card-spacer';
    for (n = i = 0; i < 5; n = ++i) {
      nodes.push(spacer.cloneNode());
    }
    return $('.game-cards').empty().append(nodes);
  }

  updateGameCards(gameNodes) {
    var attributes, element, i, len, results;
    results = [];
    for (i = 0, len = gameNodes.length; i < len; i++) {
      element = gameNodes[i];
      attributes = this._elementAttributes(element);
      results.push($(`#${attributes.gameday_link}`).data('game-card').update(attributes));
    }
    return results;
  }

  _elementAttributes(element) {
    var attribute, i, len, obj, ref;
    obj = {};
    ref = element.attributes;
    for (i = 0, len = ref.length; i < len; i++) {
      attribute = ref[i];
      if (attribute.specified) {
        obj[attribute.name] = attribute.value;
      }
    }
    return obj;
  }

  _reloadGameInfo(date, onLoad = function() {}) {
    var date_folder;
    this.loading.show();
    date_folder = date.format('[year_]YYYY[/month_]MM[/day_]DD');
    return $.get(`${this.constructor.gdx}/${date_folder}/miniscoreboard.xml`).done((response) => {
      onLoad($(response).find('games game'));
      return this.loading.hide();
    });
  }

};

Gameday.gdx = 'http://gdx.mlb.com/components/game/mlb';
