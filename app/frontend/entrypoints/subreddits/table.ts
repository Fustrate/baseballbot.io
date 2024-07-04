import { start } from '@fustrate/rails';
import GenericTable, { settings } from '@fustrate/rails/generic-table';
import { getCurrentPageJSON } from '@fustrate/rails/json';
import { icon, linkTo } from '@fustrate/rails/utilities';

import Subreddit, { JSONData as SubredditData } from 'models/subreddit';
import { postAtFormat } from 'js/utilities';

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

const checkMark = icon('check');

@settings({
  blankRow,
  noRecordsMessage: 'No subreddits found.',
  selector: 'table.subreddits',
})
class SubredditsTable extends GenericTable<Subreddit> {
  public override async reloadTable(): Promise<void> {
    const response = await getCurrentPageJSON();

    this.reloadRows(response.data.data.map((row: SubredditData) => this.createRow(Subreddit.build(row))));
  }

  public override updateRow(row: HTMLTableRowElement, subreddit: Subreddit): void {
    row.querySelector('.name').innerHTML = linkTo(subreddit.name, subreddit);
    row.querySelector('.team').textContent = subreddit.abbreviation;
    row.querySelector('.account').textContent = subreddit.account.name;

    if (subreddit.options.sidebar?.enabled) {
      row.querySelector('.sidebar').innerHTML = checkMark;
    }

    if (subreddit.options.gameThreads?.enabled) {
      const { postAt } = subreddit.options.gameThreads;

      row.querySelector('.game-threads').textContent = postAtFormat(postAt);
    }

    if (subreddit.options.pregame?.enabled) {
      const { postAt } = subreddit.options.pregame;

      row.querySelector('.pregames').textContent = postAtFormat(postAt);
    }

    if (subreddit.options.postgame?.enabled) {
      row.querySelector('.postgames').innerHTML = checkMark;
    }
  }
}

start(new SubredditsTable());
