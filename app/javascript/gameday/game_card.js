class GameCard {
  constructor(game) {
    // 0: Bases empty
    // 1: Runner on 1st
    // 2: Runner on 2nd
    // 3: Runner on 3rd
    // 4: Runners on 1st and 2nd
    // 5: Runners on 1st and 3rd
    // 6: Runners on 2nd and 3rd
    // 7: Bases loaded
    this.runners = this.runners.bind(this);
    this.outs = this.outs.bind(this);
    this.inProgress = this.inProgress.bind(this);
    this.pregame = this.pregame.bind(this);
    this.gameStatus = this.gameStatus.bind(this);
    this.refreshInfo = this.refreshInfo.bind(this);
    this.render = this.render.bind(this);
    this.game = game;

    this.card = this.constructor.gameCardTemplate.clone().attr({
      id: this.game.gameday_link
    }).data({
      gameCard: this
    });

    $('.home-team', this.card).addClass(this.game.home_file_code);
    $('.away-team', this.card).addClass(this.game.away_file_code);
    $('.home-team .name', this.card).text(this.game.home_name_abbrev);
    $('.away-team .name', this.card).text(this.game.away_name_abbrev);
  }

  runners() {
    var index;

    $('.runners', this.card).toggle(this.inProgress());

    if (!this.inProgress()) {
      return;
    }

    index = parseInt(this.game.runner_on_base_status, 10);

    $('.first', this.card).toggleClass('runner', (index === 1 || index === 4 || index === 5 || index === 7));
    $('.second', this.card).toggleClass('runner', (index === 2 || index === 4 || index === 6 || index === 7));
    $('.third', this.card).toggleClass('runner', (index === 3 || index === 5 || index === 6 || index === 7));
  }

  outs() {
    var elements, n, outs;

    $('.outs', this.card).toggle(this.inProgress());

    if (!this.inProgress()) {
      return;
    }

    outs = parseInt(this.game.outs, 10);

    elements = (function() {
      var i, ref, results;
      if (outs < 3) {
        results = [];
        for (n = i = 0, ref = outs; (0 <= ref ? i < ref : i > ref); n = 0 <= ref ? ++i : --i) {
          results.push($('<span class="out"></span>'));
        }
        return results;
      } else {
        return [];
      }
    })();

    $('.outs', this.card).empty().append(elements);
  }

  inProgress() {
    var ref = this.game.status;

    return ref === 'In Progress' || ref === 'Manager Challenge';
  }

  pregame() {
    var ref = this.game.status;

    return ref === 'Pre-Game' || ref === 'Warmup' || ref === 'Delayed Start' || ref === 'Scheduled';
  }

  gameStatus() {
    var side, sides;

    if (this.game.status === 'Preview') {
      return this.game.time;
    }

    if (this.pregame()) {
      return `${this.game.time} - ${this.game.status}`;
    }

    if (!this.inProgress()) {
      return this.game.status;
    }

    sides = this.game.outs === '3' ? ['Mid', 'End'] : ['Top', 'Bot'];
    side = this.game.top_inning === 'Y' ? sides[0] : sides[1];

    return `${side} ${this.game.inning}`;
  }

  refreshInfo() {
    this.outs();
    this.runners();

    $('.home-team .runs', this.card).text(this.game.home_team_runs);
    $('.away-team .runs', this.card).text(this.game.away_team_runs);

    $('.status', this.card).text(this.gameStatus(this.game));
  }

  render() {
    this.refreshInfo();

    return this.card;
  }

  update(game) {
    this.game = game;

    this.refreshInfo();
  }
}

GameCard.gameCardTemplate = `
  <div class="game-card">
    <div class="away-team">
      <div class="runs"></div>
      <div class="name"></div>
    </div>
    <div class="home-team">
      <div class="name"></div>
      <div class="runs"></div>
    </div>
    <div class="game-info">
      <span class="status"></span>
      <span class="outs"></span>
      <div class="runners">
        <div class="first"></div>
        <div class="second"></div>
        <div class="third"></div>
      </div>
    </div>
  </div>`

export default GameCard;
