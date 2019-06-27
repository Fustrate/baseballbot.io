import moment from 'moment';
import GenericTable from '@fustrate/rails/dist/js/GenericTable';
import { icon, label, linkTo } from '@fustrate/rails/dist/js/utilities';
import { get } from '@fustrate/rails/dist/js/ajax';

import GameThread from './game_thread';

import { subredditPath } from '../routes';

const redditIcon = icon('reddit', 'brands');

class GameThreadsTable extends GenericTable {
  protected reloadUrl: string;

  protected static blankRow = `
    <tr>
      <td class="game-pk"></td>
      <td class="title"></td>
      <td class="subreddit"></td>
      <td class="post-at no-wrap"></td>
      <td class="starts-at no-wrap"></td>
      <td class="status"></td>
    </tr>`;

  constructor(reloadUrl) {
    super(document.body.querySelector('table.game-threads'));

    this.reloadUrl = reloadUrl;
  }

  reloadTable() {
    get(this.reloadUrl).then((response) => {
      const { data } = response.data;

      this.reloadRows(data.map(row => this.createRow(new GameThread(row))));

      this.updatePagination(response);
    });
  }

  updateRow(row, gameThread) {
    row.querySelector('.subreddit').innerHTML = linkTo(
      gameThread.subreddit.name,
      subredditPath(gameThread.subreddit),
    );

    if (gameThread.title) {
      (this.constructor as typeof GameThreadsTable).populateGameThreadTitle(row.querySelector('.title'), gameThread);
    }

    row.querySelector('.game-pk').innerHTML = linkTo(
      gameThread.gamePk,
      `https://www.mlb.com/gameday/${gameThread.gamePk}`,
    );

    row.querySelector('.post-at').textContent = gameThread.postAt.toHumanDate(true);
    row.querySelector('.starts-at').textContent = gameThread.startsAt.toHumanDate(true);

    row.querySelector('.status').innerHTML = (this.constructor as typeof GameThreadsTable).statusLabel(gameThread);

    return row;
  }

  static populateGameThreadTitle(cell, gameThread) {
    if (!gameThread.postId) {
      cell.textContent = gameThread.title;

      return;
    }

    cell.innerHTML = linkTo(
      `${redditIcon} ${gameThread.title}`,
      `http://redd.it/${gameThread.postId}`,
    );
  }

  static statusLabel(gameThread) {
    if (moment().isAfter(gameThread.postAt) && gameThread.status === 'Future') {
      return label('Error', 'fw game-thread');
    }

    if (moment().isAfter(gameThread.startsAt) && gameThread.status === 'Posted') {
      return label('Live', 'fw game-thread');
    }

    return label(gameThread.status, 'fw game-thread');
  }
}

export default GameThreadsTable;
