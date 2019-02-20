import BaseballBot from '../../baseballbot';
import GenericTable from '../../fustrate/generic_table';
import Subreddit from '../../baseballbot/subreddit';

const blankRow = `
  <tr>
    <td class="name"></td>
    <td class="team"></td>
    <td class="account"></td>
    <td class="sidebar text-center"></td>
    <td class="game_threads text-center"></td>
    <td class="pregames text-center"></td>
    <td class="postgames text-center"></td>
  </tr>`;

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
      row.querySelector('.sidebar').innerHTML = BaseballBot.icon('check');
    }

    if (subreddit.options.game_threads && subreddit.options.game_threads.enabled) {
      const postAt = subreddit.options.game_threads.post_at;

      row.querySelector('.game_threads').setAttribute('title', Subreddit.postAtFormat(postAt));
      row.querySelector('.game_threads').innerHTML = BaseballBot.icon('check');
    }

    if (subreddit.options.pregame && subreddit.options.pregame.enabled) {
      const postAt = subreddit.options.pregame.post_at;

      row.querySelector('.pregames').setAttribute('title', Subreddit.postAtFormat(postAt));
      row.querySelector('.pregames').innerHTML = BaseballBot.icon('check');
    }

    if (subreddit.options.postgame && subreddit.options.postgame.enabled) {
      row.querySelector('.postgames').innerHTML = BaseballBot.icon('check');
    }

    return row;
  }

  static get blankRow() {
    return blankRow;
  }
}

BaseballBot.start(new SubredditsTable(document.body));
