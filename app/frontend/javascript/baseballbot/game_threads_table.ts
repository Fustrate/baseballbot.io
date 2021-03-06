import moment from 'moment';
import GenericTable from '@fustrate/rails/dist/js/GenericTable';
import { getCurrentPageJson } from '@fustrate/rails/dist/js/ajax';
import {
  icon,
  label,
  linkTo,
  toHumanDate,
} from '@fustrate/rails/dist/js/utilities';

import GameThread from 'models/game_thread';

import { subredditPath } from 'js/routes';

const redditIcon = icon('reddit', 'brands');

function statusLabel(gameThread: GameThread) {
  if (moment().isAfter(gameThread.postAt) && gameThread.status === 'Future') {
    return label('Error', 'fw game-thread');
  }

  if (moment().isAfter(gameThread.startsAt) && gameThread.status === 'Posted') {
    return label('Live', 'fw game-thread');
  }

  return label(gameThread.status, 'fw game-thread');
}

function populateGameThreadTitle(cell: HTMLTableCellElement, gameThread: GameThread) {
  if (!gameThread.postId) {
    cell.textContent = gameThread.title;

    return;
  }

  cell.innerHTML = linkTo(
    `${redditIcon} ${gameThread.title}`,
    `http://redd.it/${gameThread.postId}`,
  );
}

class GameThreadsTable extends GenericTable {
  protected static blankRow = `
    <tr>
      <td class="game-pk"></td>
      <td class="title"></td>
      <td class="subreddit"></td>
      <td class="post-at no-wrap"></td>
      <td class="starts-at no-wrap"></td>
      <td class="status"></td>
    </tr>`;

  public constructor() {
    super(document.body.querySelector('table.game-threads'));
  }

  public async reloadTable(): Promise<void> {
    const response = await getCurrentPageJson();

    const { data } = response.data;

    this.reloadRows(data.map((row) => this.createRow(GameThread.build(row))));

    this.updatePagination(response);
  }

  public updateRow(row: HTMLTableRowElement, gameThread: GameThread): void {
    row.querySelector('.subreddit').innerHTML = linkTo(
      gameThread.subreddit.name,
      subredditPath(gameThread.subreddit),
    );

    if (gameThread.title) {
      populateGameThreadTitle(row.querySelector('.title'), gameThread);
    }

    row.querySelector('.game-pk').innerHTML = linkTo(
      `${gameThread.gamePk}`,
      `https://www.mlb.com/gameday/${gameThread.gamePk}`,
    );

    row.querySelector('.post-at').textContent = toHumanDate(gameThread.postAt, true);
    row.querySelector('.starts-at').textContent = toHumanDate(gameThread.startsAt, true);

    row.querySelector('.status').innerHTML = statusLabel(gameThread);
  }
}

export default GameThreadsTable;
