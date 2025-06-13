import { elementFromString } from '@fustrate/rails/html';

import type Game from './game';
import GameModal from './game-modal';

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

function setBaseRunner(element: HTMLDivElement, runner: any): void {
  if (runner) {
    element.classList.add('runner');
    element.title = runner.fullName;
  } else {
    element.classList.remove('runner');
    element.title = '';
  }
}

class GameCard {
  public game: Game;
  public card: HTMLDivElement;

  public modal?: GameModal;

  public constructor(game: Game) {
    this.game = game;
    this.card = elementFromString(template);

    this.card.querySelector('.home-team')?.classList?.add(this.game.teams.home.team.fileCode);
    this.card.querySelector('.away-team')?.classList?.add(this.game.teams.away.team.fileCode);

    this.card.querySelector('.home-team .name')!.textContent = this.game.teams.home.team.abbreviation;
    this.card.querySelector('.away-team .name')!.textContent = this.game.teams.away.team.abbreviation;

    this.card.addEventListener('click', this.openGameModal.bind(this));

    this.refresh();
  }

  public update(data: any): void {
    this.game.updateData(data);

    this.refresh();
  }

  protected async openGameModal(): Promise<void> {
    if (!this.modal) {
      this.modal = new GameModal(this.game);
    }

    await this.modal.open();
  }

  protected refreshRunners(): void {
    if (this.game.isInProgress) {
      this.card.querySelector<HTMLDivElement>('.runners')!.style.display = '';
    } else {
      this.card.querySelector<HTMLDivElement>('.runners')!.style.display = 'none';

      return;
    }

    setBaseRunner(this.card.querySelector<HTMLDivElement>('.first')!, this.game.linescore.offense.first);
    setBaseRunner(this.card.querySelector<HTMLDivElement>('.second')!, this.game.linescore.offense.second);
    setBaseRunner(this.card.querySelector<HTMLDivElement>('.third')!, this.game.linescore.offense.third);
  }

  protected refreshOuts(): void {
    if (this.game.isInProgress) {
      this.card.querySelector<HTMLDivElement>('.outs')!.style.display = '';
    } else {
      this.card.querySelector<HTMLDivElement>('.outs')!.style.display = 'none';
    }

    if (!this.game.isInProgress) {
      return;
    }

    const elements: string[] = [];

    const outSpan = '<span class="out"></span>';

    for (let i = this.game.linescore.outs; i < 3; i += 1) {
      elements.push(outSpan);
    }

    this.card.querySelector('.outs')!.innerHTML = elements.join('');
  }

  protected gameStatus(): string {
    const gameTime = this.game.gameDate.toFormat('h:mm');

    if (['Preview', 'Scheduled', 'Pre-Game'].includes(this.game.status.detailedState)) {
      return gameTime;
    }

    if (this.game.isPregame) {
      return `${gameTime} - ${this.game.status.detailedState}`;
    }

    if (!this.game.isInProgress) {
      return String(this.game.status.detailedState);
    }

    return `${this.game.linescore.inningState} ${this.game.linescore.currentInning}`;
  }

  protected refresh(): void {
    this.refreshOuts();
    this.refreshRunners();

    if (!this.game.isPregame && this.game.linescore) {
      this.card.querySelector('.home-team .runs')!.textContent = this.game.linescore.teams.home.runs;
      this.card.querySelector('.away-team .runs')!.textContent = this.game.linescore.teams.away.runs;
    }

    this.card.querySelector('.status')!.textContent = this.gameStatus();
  }
}

export default GameCard;
