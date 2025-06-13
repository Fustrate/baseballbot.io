import { start } from '@fustrate/rails';
import GenericTable, { settings } from '@fustrate/rails/generic-table';
import { getCurrentPageJSON } from '@fustrate/rails/json';
import { icon, linkTo } from '@fustrate/rails/utilities';

import { postAtFormat } from 'js/utilities';
import Subreddit, { type JSONData as SubredditData } from 'models/subreddit';

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

    this.reloadRows(response.data.data.map((row: SubredditData) => this.createRow(Subreddit.build(row) as Subreddit)));
  }

  public override updateRow(row: HTMLTableRowElement, subreddit: Subreddit): void {
    row.querySelector('.name')?.setHTMLUnsafe(linkTo(subreddit.name, subreddit));
    row.querySelector('.team')?.replaceChildren(subreddit.abbreviation);
    row.querySelector('.account')?.replaceChildren(subreddit.account.name);

    if (subreddit.options.sidebar?.enabled) {
      row.querySelector('.sidebar')?.setHTMLUnsafe(checkMark);
    }

    if (subreddit.options.gameThreads?.enabled) {
      const { postAt } = subreddit.options.gameThreads;

      row.querySelector('.game-threads')?.replaceChildren(postAtFormat(postAt));
    }

    if (subreddit.options.pregame?.enabled) {
      const { postAt } = subreddit.options.pregame;

      row.querySelector('.pregames')?.replaceChildren(postAtFormat(postAt));
    }

    if (subreddit.options.postgame?.enabled) {
      row.querySelector('.postgames')?.setHTMLUnsafe(checkMark);
    }
  }
}

start(new SubredditsTable());
