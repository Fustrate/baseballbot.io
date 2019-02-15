import $ from 'jquery';

const settings = {
  pregameStatuses: ['Pre-Game', 'Warmup', 'Delayed Start', 'Scheduled'],
  inProgressStatuses: ['In Progress', 'Manager Challenge'],
};

const template = `
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
  </div>`;

class GameCard {
  constructor(game) {
    this.game = game;

    this.card = $(template)
      .attr({ id: this.game.gameday_link })
      .data({ gameCard: this });

    $('.home-team', this.card).addClass(this.game.home_file_code);
    $('.away-team', this.card).addClass(this.game.away_file_code);
    $('.home-team .name', this.card).text(this.game.home_name_abbrev);
    $('.away-team .name', this.card).text(this.game.away_name_abbrev);
  }

  refreshRunners() {
    $('.runners', this.card).toggle(this.inProgress());

    if (!this.inProgress()) {
      return;
    }

    // 0: Bases empty
    // 1: Runner on 1st
    // 2: Runner on 2nd
    // 3: Runner on 3rd
    // 4: Runners on 1st and 2nd
    // 5: Runners on 1st and 3rd
    // 6: Runners on 2nd and 3rd
    // 7: Bases loaded
    const index = parseInt(this.game.runner_on_base_status, 10);

    $('.first', this.card).toggleClass('runner', [1, 4, 5, 7].includes(index));
    $('.second', this.card).toggleClass('runner', [2, 4, 6, 7].includes(index));
    $('.third', this.card).toggleClass('runner', [3, 5, 6, 7].includes(index));
  }

  refreshOuts() {
    $('.outs', this.card).toggle(this.inProgress());

    if (!this.inProgress()) {
      return;
    }

    const outs = parseInt(this.game.outs, 10);
    const elements = [];

    for (let i = 3; i > outs; i -= 1) {
      elements.push($('<span class="out"></span>'));
    }

    $('.outs', this.card).empty().append(elements);
  }

  inProgress() {
    return settings.inProgressStatuses.includes(this.game.status);
  }

  pregame() {
    return settings.pregameStatuses.includes(this.game.status);
  }

  gameStatus() {
    if (this.game.status === 'Preview') {
      return this.game.time;
    }

    if (this.pregame()) {
      return `${this.game.time} - ${this.game.status}`;
    }

    if (!this.inProgress()) {
      return this.game.status;
    }

    const sides = this.game.outs === '3' ? ['Mid', 'End'] : ['Top', 'Bot'];
    const side = this.game.top_inning === 'Y' ? sides[0] : sides[1];

    return `${side} ${this.game.inning}`;
  }

  refreshInfo() {
    this.refreshOuts();
    this.refreshRunners();

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

export default GameCard;
