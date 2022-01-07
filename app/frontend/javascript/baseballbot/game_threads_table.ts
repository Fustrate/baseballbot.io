import { DateTime } from 'luxon';
import { GenericTable, PaginationData } from '@fustrate/rails';
import { getCurrentPageJson } from '@fustrate/rails/ajax';
import {
  icon,
  label,
  linkTo,
  toHumanDate,
} from '@fustrate/rails/utilities';

import GameThread, { JSONData } from 'models/game_thread';

import { subredditPath } from 'js/routes';

interface PaginatedResponse<T> extends PaginationData {
  data: T[];
}

const redditIcon = icon('reddit', 'brands');

function statusLabel(gameThread: GameThread) {
  if (gameThread.postAt < DateTime.now() && gameThread.status === 'Future') {
    return label('Error', 'fw game-thread');
  }

  if (gameThread.startsAt < DateTime.now() && gameThread.status === 'Posted') {
    return label('Live', 'fw game-thread');
  }

  return label(gameThread.status, 'fw game-thread');
}

function populateGameThreadTitle(cell: HTMLTableCellElement, gameThread: GameThread) {
  if (!gameThread.postId) {
    cell.textContent = gameThread.title;

    return;
  }

  cell.innerHTML = linkTo(`${redditIcon} ${gameThread.title}`, `http://redd.it/${gameThread.postId}`);
}

const blankRow = `
  <tr>
    <td class="game-pk"></td>
    <td class="title"></td>
    <td class="subreddit"></td>
    <td class="post-at no-wrap"></td>
    <td class="starts-at no-wrap"></td>
    <td class="status"></td>
  </tr>`;

class GameThreadsTable extends GenericTable<GameThread> {
  public constructor() {
    super('table.game-threads', {
      blankRow,
      noRecordsMessage: 'No game threads found.',
    });
  }

  public override async reloadTable(): Promise<void> {
    const response = await getCurrentPageJson<PaginatedResponse<JSONData>>();

    const { data } = response.data;

    this.reloadRows(data.map((row) => this.createRow(GameThread.build(row))));

    this.updatePagination(response.data);
  }

  public override updateRow(row: HTMLTableRowElement, gameThread: GameThread): void {
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
