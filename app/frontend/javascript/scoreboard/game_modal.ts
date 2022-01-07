import { Modal } from '@fustrate/rails';
import Game from './game';

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

function inningCell(inning: { [s: string]: { runs: number }}, side: 'home' | 'away') {
  if (!inning || inning[side].runs === undefined) {
    return '<td></td>';
  }

  return `<td>${inning[side].runs !== undefined ? inning[side].runs : ''}</td>`;
}

function linescoreTotals(team) {
  return [team.runs, team.hits, team.errors, team.leftOnBase];
}

export default class GameModal extends Modal {
  public game: Game;

  public constructor(game: Game) {
    super({
      size: 'small',
      content: template,
      title: `⚾ ${game.teams.away.team.name} @ ${game.teams.home.team.name}`,
      buttons: [],
    });

    this.game = game;
  }

  public override async open(): Promise<void> {
    this.modal.querySelector('.linescore').innerHTML = this.linescore();

    super.open();
  }

  public linescore(): string {
    if (this.game.isPregame) {
      return 'Line score begins at game time.';
    }

    let headers = ['<th></th>'];
    let away = [`<th>${this.game.teams.away.team.teamName}</th>`];
    let home = [`<th>${this.game.teams.home.team.teamName}</th>`];

    const inningsToShow = Math.max(
      this.game.linescore.scheduledInnings,
      this.game.linescore.currentInning,
    );

    for (let i = 1; i <= inningsToShow; i += 1) {
      headers.push(`<th>${i}</th>`);

      const inning = this.game.linescore.innings[i - 1];

      away.push(inningCell(inning, 'away'));
      home.push(inningCell(inning, 'home'));
    }

    if (this.game.status.abstractGameState === 'Final' && home[home.length - 1] === '<td></td>') {
      home[home.length - 1] = '<td class="did-not-play"></td>';
    }

    headers = headers.concat('<th>R</th>', '<th>H</th>', '<th>E</th>', '<th>LOB</th>');
    away = away.concat(linescoreTotals(this.game.linescore.teams.away).map((text) => `<th>${text}</th>`));
    home = home.concat(linescoreTotals(this.game.linescore.teams.home).map((text) => `<th>${text}</th>`));

    return `
      <table class="linescore">
        <thead><tr>${headers.join('')}</tr></thead>
        <tbody>
          <tr>${away.join('')}</tr>
          <tr>${home.join('')}</tr>
        </tbody>
      </table>`;
  }
}
