import moment from 'moment';

import BaseballBot from '.';
import GenericTable from '../fustrate/generic_table';
import GameThread from './game_thread';

import Routes from './routes'; // eslint-disable-line import/no-unresolved

const blankRow = `
  <tr>
    <td class="game_pk"></td>
    <td class="title"></td>
    <td class="subreddit"></td>
    <td class="post_at no-wrap"></td>
    <td class="starts_at no-wrap"></td>
    <td class="status"></td>
  </tr>`;

class GameThreadsTable extends GenericTable {
  constructor(root, reloadUrl) {
    super(root);

    this.table = root.querySelector('table.game-threads');

    this.reloadUrl = reloadUrl;
  }

  reloadTable() {
    fetch(this.reloadUrl)
      .then(response => response.json())
      .then((response) => {
        this.reloadRows(response.data.map(row => this.createRow(new GameThread(row))));

        this.updatePagination(response);
      });
  }

  static updateRow(row, gameThread) {
    row.querySelector('.subreddit').innerHTML = BaseballBot.linkTo(
      gameThread.subreddit.name,
      Routes.subreddit_path(gameThread.subreddit),
    );

    row.querySelector('.title').innerHTML = BaseballBot.linkTo(
      gameThread.title,
      `http://redd.it/${gameThread.postId}`,
    );

    row.querySelector('.game_pk').innerHTML = BaseballBot.linkTo(
      gameThread.gamePk,
      `https://www.mlb.com/gameday/${gameThread.gamePk}`,
    );

    row.querySelector('.post_at').textContent = gameThread.postAt.toHumanDate(true);
    row.querySelector('.starts_at').textContent = gameThread.startsAt.toHumanDate(true);

    row.querySelector('.status').innerHTML = this.statusLabel(gameThread);

    return row;
  }

  static get blankRow() {
    return blankRow;
  }

  static statusLabel(gameThread) {
    if (moment().isAfter(gameThread.postAt) && gameThread.status === 'Future') {
      return BaseballBot.label('Error', 'fw game_thread');
    }

    if (moment().isAfter(gameThread.startsAt) && gameThread.status === 'Posted') {
      return BaseballBot.label('Live', 'fw game_thread');
    }

    return BaseballBot.label(gameThread.status, 'fw game_thread');
  }
}

export default GameThreadsTable;