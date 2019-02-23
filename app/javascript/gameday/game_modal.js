import Modal from '../fustrate/components/modal';

const template = `
  <section>
    Game Info
  </section>
  <section>
    <div class="linescore"></div>
  </section>
  <section>
    Box Score
  </section>`;

class GameModal extends Modal {
  static get size() { return 'small'; }

  constructor(game) {
    super({ content: template });

    this.game = game;
  }

  open() {
    this.setTitle(`⚾ ${this.game.teams.away.team.name} @ ${this.game.teams.home.team.name}`);

    this.modal.find('.linescore').html(this.linescore());

    super.open();
  }

  linescore() {
    let headers = ['<th></th>'];
    let away = [`<th>${this.game.teams.away.team.teamName}</th>`];
    let home = [`<th>${this.game.teams.home.team.teamName}</th>`];

    for (let i = 1; i <= this.game.linescore.currentInning; i += 1) {
      headers.push(`<th>${i}</th>`);

      const inning = this.game.linescore.innings[i - 1];

      away.push(`<td>${inning.away.runs !== undefined ? inning.away.runs : ''}</td>`);
      home.push(`<td>${inning.home.runs !== undefined ? inning.home.runs : ''}</td>`);
    }

    if (this.game.status.abstractGameState === 'Final' && home[home.length - 1] === '<td></td>') {
      home[home.length - 1] = '<td class="did-not-play"></td>';
    }

    headers = headers.concat('<th>R</th>', '<th>H</th>', '<th>E</th>', '<th>LOB</th>');
    away = away.concat(
      this.constructor.linescoreTotals(this.game.linescore.teams.away).map(text => `<th>${text}</th>`)
    );
    home = home.concat(
      this.constructor.linescoreTotals(this.game.linescore.teams.home).map(text => `<th>${text}</th>`)
    );

    return `
      <table class="linescore">
        <thead><tr>${headers.join('')}</tr></thead>
        <tbody>
          <tr>${away.join('')}</tr>
          <tr>${home.join('')}</tr>
        </tbody>
      </table>`;
  }

  static linescoreTotals(team) {
    return [team.runs, team.hits, team.errors, team.leftOnBase];
  }
}

export default GameModal;
