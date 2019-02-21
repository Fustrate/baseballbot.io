const pregameStatuses = ['Pre-Game', 'Warmup', 'Delayed Start', 'Scheduled'];
const inProgressStatuses = ['In Progress', 'Manager Challenge'];

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

    this.card = this.constructor.elementFromString(template);

    this.card.querySelector('.home-team').classList.add(this.game.teams.home.team.fileCode);
    this.card.querySelector('.away-team').classList.add(this.game.teams.away.team.fileCode);

    this.card.querySelector('.home-team .name').textContent = this.game.teams.home.team.abbreviation;
    this.card.querySelector('.away-team .name').textContent = this.game.teams.away.team.abbreviation;

    this.refresh();
  }

  refreshRunners() {
    if (this.inProgress()) {
      this.card.querySelector('.runners').style.display = '';
    } else {
      this.card.querySelector('.runners').style.display = 'none';
    }

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

    this.card.querySelector('.first').classList.toggle('runner', [1, 4, 5, 7].includes(index));
    this.card.querySelector('.second').classList.toggle('runner', [2, 4, 6, 7].includes(index));
    this.card.querySelector('.third').classList.toggle('runner', [3, 5, 6, 7].includes(index));
  }

  refreshOuts() {
    if (this.inProgress()) {
      this.card.querySelector('.outs').style.display = '';
    } else {
      this.card.querySelector('.outs').style.display = 'none';
    }

    if (!this.inProgress()) {
      return;
    }

    const outs = parseInt(this.game.outs, 10);
    const elements = [];

    const outSpan = document.createElement('span');
    outSpan.classList.add('out');

    for (let i = 3; i > outs; i -= 1) {
      elements.push(outSpan.cloneNode());
    }

    this.card.querySelector('.outs').innerHTML = elements;
  }

  inProgress() {
    return inProgressStatuses.includes(this.game.status);
  }

  pregame() {
    return pregameStatuses.includes(this.game.status);
  }

  gameStatus() {
    if (this.game.status.detailedState === 'Preview') {
      return this.game.time;
    }

    if (this.pregame()) {
      return `${this.game.time} - ${this.game.status.detailedState}`;
    }

    if (!this.inProgress()) {
      return this.game.status.detailedState;
    }

    const sides = this.game.outs === '3' ? ['Mid', 'End'] : ['Top', 'Bot'];
    const side = this.game.top_inning === 'Y' ? sides[0] : sides[1];

    return `${side} ${this.game.inning}`;
  }

  refresh() {
    this.refreshOuts();
    this.refreshRunners();

    this.card.querySelector('.home-team .runs').textContent = this.game.home_team_runs;
    this.card.querySelector('.away-team .runs').textContent = this.game.away_team_runs;

    this.card.querySelector('.status').textContent = this.gameStatus();
  }

  update(game) {
    this.game = game;

    this.refresh();
  }

  static elementFromString(string) {
    const templateElement = document.createElement('template');

    templateElement.innerHTML = string.trim();

    return templateElement.content.firstChild;
  }
}

export default GameCard;
