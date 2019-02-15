import $ from 'jquery';

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

    this.table = $(root).find('table.subreddits');
  }

  reloadTable() {
    BaseballBot.getCurrentPageJson().done((response) => {
      this.reloadRows(response.data.map(row => this.createRow(new Subreddit(row))));
    });
  }

  static updateRow(row, subreddit) {
    $('.name', row).html(BaseballBot.linkTo(subreddit.name, subreddit));
    $('.team', row).text(subreddit.abbreviation);
    $('.account', row).text(subreddit.account.name);

    if (subreddit.options.sidebar && subreddit.options.sidebar.enabled) {
      $('.sidebar', row).html(BaseballBot.icon('check'));
    }

    if (subreddit.options.game_threads && subreddit.options.game_threads.enabled) {
      const postAt = subreddit.options.game_threads.post_at;

      $('.game_threads', row)
        .html(BaseballBot.icon('check'))
        .attr('title', Subreddit.postAtFormat(postAt));
    }

    if (subreddit.options.pregame && subreddit.options.pregame.enabled) {
      const postAt = subreddit.options.pregame.post_at;

      $('.pregames', row)
        .html(BaseballBot.icon('check'))
        .attr('title', Subreddit.postAtFormat(postAt));
    }

    if (subreddit.options.postgame && subreddit.options.postgame.enabled) {
      $('.postgames', row).html(BaseballBot.icon('check'));
    }

    return row;
  }

  static get blankRow() {
    return blankRow;
  }
}

BaseballBot.start(new SubredditsTable(document.body));
