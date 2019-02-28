import { GenericTable } from '@fustrate/rails';
import BaseballBot from '../../javascript/baseballbot';
import Subreddit from '../../javascript/baseballbot/subreddit';

const blankRow = `
  <tr>
    <td class="name"></td>
    <td class="team"></td>
    <td class="account"></td>
    <td class="sidebar text-center"></td>
    <td class="game-threads text-center"></td>
    <td class="pregames text-center"></td>
    <td class="postgames text-center"></td>
  </tr>`;

const checkMark = BaseballBot.icon('check');

class SubredditsTable extends GenericTable {
  constructor(root) {
    super(root);

    this.table = root.querySelector('table.subreddits');
  }

  reloadTable() {
    BaseballBot.getCurrentPageJson().done((response) => {
      this.reloadRows(response.data.map(row => this.createRow(new Subreddit(row))));
    });
  }

  static updateRow(row, subreddit) {
    row.querySelector('.name').innerHTML = BaseballBot.linkTo(subreddit.name, subreddit);
    row.querySelector('.team').textContent = subreddit.abbreviation;
    row.querySelector('.account').textContent = subreddit.account.name;

    if (subreddit.options.sidebar && subreddit.options.sidebar.enabled) {
      row.querySelector('.sidebar').innerHTML = checkMark;
    }

    if (subreddit.options.gameThreads && subreddit.options.gameThreads.enabled) {
      const { postAt } = subreddit.options.gameThreads;

      row.querySelector('.game-threads').textContent = Subreddit.postAtFormat(postAt);
    }

    if (subreddit.options.pregame && subreddit.options.pregame.enabled) {
      const { postAt } = subreddit.options.pregame;

      row.querySelector('.pregames').textContent = Subreddit.postAtFormat(postAt);
    }

    if (subreddit.options.postgame && subreddit.options.postgame.enabled) {
      row.querySelector('.postgames').innerHTML = checkMark;
    }

    return row;
  }

  static get blankRow() {
    return blankRow;
  }
}

BaseballBot.start(new SubredditsTable(document.body));
