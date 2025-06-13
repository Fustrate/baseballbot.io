import type { PaginatedData } from '@fustrate/rails/components/pagination';
import GenericTable, { settings } from '@fustrate/rails/generic-table';
import { getCurrentPageJSON } from '@fustrate/rails/json';
import { icon, label, linkTo, toHumanDate } from '@fustrate/rails/utilities';
import { DateTime } from 'luxon';

import GameThread, { type JSONData } from 'models/game-thread';

import { subredditPath } from 'utilities/routes';

interface PaginatedResponse<T> extends PaginatedData {
  data: T[];
}

const redditIcon = icon('reddit', 'brands');

function statusLabel(gameThread: GameThread) {
  if (gameThread.postAt < DateTime.now() && gameThread.status === 'Future') {
    return label('Error', 'fw', 'game-thread', 'error');
  }

  if (gameThread.startsAt < DateTime.now() && gameThread.status === 'Posted') {
    return label('Live', 'fw', 'game-thread', 'live');
  }

  return label(gameThread.status, 'fw', 'game-thread', gameThread.status.toLowerCase());
}

function populateGameThreadTitle(cell: HTMLTableCellElement, gameThread: GameThread) {
  if (!gameThread.postId) {
    cell.textContent = gameThread.title ?? '';

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

@settings({
  blankRow,
  noRecordsMessage: 'No game threads found.',
  selector: 'table.game-threads',
})
class GameThreadsTable extends GenericTable<GameThread> {
  public override async reloadTable(): Promise<void> {
    const response = await getCurrentPageJSON<PaginatedResponse<JSONData>>();

    const { data } = response.data;

    this.reloadRows(data.map((row) => this.createRow(GameThread.build(row) as GameThread)));

    this.updatePagination(response.data);
  }

  public override updateRow(row: HTMLTableRowElement, gameThread: GameThread): void {
    row
      .querySelector('.subreddit')
      ?.setHTMLUnsafe(linkTo(gameThread.subreddit.name, subredditPath(gameThread.subreddit.id as number)));

    if (gameThread.title) {
      populateGameThreadTitle(row.querySelector('.title') as HTMLTableCellElement, gameThread);
    }

    row
      .querySelector('.game-pk')
      ?.setHTMLUnsafe(linkTo(`${gameThread.gamePk}`, `https://www.mlb.com/gameday/${gameThread.gamePk}`));

    row.querySelector('.post-at')?.replaceChildren(toHumanDate(gameThread.postAt, true));
    row.querySelector('.starts-at')?.replaceChildren(toHumanDate(gameThread.startsAt, true));

    row.querySelector('.status')?.setHTMLUnsafe(statusLabel(gameThread));
  }
}

export default GameThreadsTable;
