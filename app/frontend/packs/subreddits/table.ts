import GenericTable from '@fustrate/rails/dist/js/GenericTable';
import { getCurrentPageJson } from '@fustrate/rails/dist/js/ajax';
import { icon, linkTo } from '@fustrate/rails/dist/js/utilities';

import BaseballBot from 'js/baseballbot';
import Subreddit from 'models/subreddit';

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

class SubredditsTable extends GenericTable {
  public constructor() {
    super(document.body.querySelector('table.subreddits'));
  }

  public async reloadTable(): Promise<void> {
    const response = await getCurrentPageJson();

    this.reloadRows(response.data.data.map((row) => this.createRow(Subreddit.build(row))));
  }

  public updateRow(row: HTMLTableRowElement, subreddit: Subreddit): void {
    row.querySelector('.name').innerHTML = linkTo(subreddit.name, subreddit);
    row.querySelector('.team').textContent = subreddit.abbreviation;
    row.querySelector('.account').textContent = subreddit.account.name;

    if (subreddit.options.sidebar?.enabled) {
      row.querySelector('.sidebar').innerHTML = checkMark;
    }

    if (subreddit.options.gameThreads?.enabled) {
      const { postAt } = subreddit.options.gameThreads;

      row.querySelector('.game-threads').textContent = Subreddit.postAtFormat(postAt);
    }

    if (subreddit.options.pregame?.enabled) {
      const { postAt } = subreddit.options.pregame;

      row.querySelector('.pregames').textContent = Subreddit.postAtFormat(postAt);
    }

    if (subreddit.options.postgame?.enabled) {
      row.querySelector('.postgames').innerHTML = checkMark;
    }
  }

  protected static get blankRow(): string {
    return blankRow;
  }
}

BaseballBot.start(SubredditsTable);
