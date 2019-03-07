import moment from 'moment';
import { GenericTable } from '@fustrate/rails';
import { icon, label, linkTo } from '@fustrate/rails/utilities';

import GameThread from './game_thread';

import { subredditPath } from '../routes';

const blankRow = `
  <tr>
    <td class="game_pk"></td>
    <td class="title"></td>
    <td class="subreddit"></td>
    <td class="post_at no-wrap"></td>
    <td class="starts_at no-wrap"></td>
    <td class="status"></td>
  </tr>`;

const redditIcon = icon('reddit', 'brands');

class GameThreadsTable extends GenericTable {
  constructor(root, reloadUrl) {
    super(root, root.querySelector('table.game-threads'));

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

  updateRow(row, gameThread) {
    row.querySelector('.subreddit').innerHTML = linkTo(
      gameThread.subreddit.name,
      subredditPath(gameThread.subreddit),
    );

    if (gameThread.title) {
      row.querySelector('.title').innerHTML = this.constructor.gameThreadLink(gameThread);
    }

    row.querySelector('.game_pk').innerHTML = linkTo(
      gameThread.gamePk,
      `https://www.mlb.com/gameday/${gameThread.gamePk}`,
    );

    row.querySelector('.post_at').textContent = gameThread.postAt.toHumanDate(true);
    row.querySelector('.starts_at').textContent = gameThread.startsAt.toHumanDate(true);

    row.querySelector('.status').innerHTML = this.constructor.statusLabel(gameThread);

    return row;
  }

  static gameThreadLink(gameThread) {
    return linkTo(
      `${redditIcon} ${gameThread.title}`,
      `http://redd.it/${gameThread.postId}`,
    );
  }

  static get blankRow() {
    return blankRow;
  }

  static statusLabel(gameThread) {
    if (moment().isAfter(gameThread.postAt) && gameThread.status === 'Future') {
      return label('Error', 'fw game_thread');
    }

    if (moment().isAfter(gameThread.startsAt) && gameThread.status === 'Posted') {
      return label('Live', 'fw game_thread');
    }

    return label(gameThread.status, 'fw game_thread');
  }
}

export default GameThreadsTable;
