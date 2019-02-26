import { GenericPage } from '@fustrate/rails';

import BaseballBot from '../../baseballbot';
import Subreddit from '../../baseballbot/subreddit';
import Template from '../../baseballbot/template';

class ShowSubreddit extends GenericPage {
  initialize() {
    this.subreddit = new Subreddit(this.root.dataset.subreddit);

    this.subreddit.reload().done(() => {
      this.refresh();
    });
  }

  refreshSettings() {
    const listItems = [];

    if (this.subreddit.options.sidebar && this.subreddit.options.sidebar.enabled) {
      listItems.push('<li>Hourly Sidebar Updates</li>');
    }

    if (this.subreddit.options.gameThreads && this.subreddit.options.gameThreads.enabled) {
      const { postAt } = this.subreddit.options.gameThreads;

      listItems.push(`<li>Game Threads ${Subreddit.postAtFormat(postAt)}</li>`);
    }

    if (this.subreddit.options.pregame && this.subreddit.options.pregame.enabled) {
      const { postAt } = this.subreddit.options.pregame;

      listItems.push(`<li>Pregame Threads ${Subreddit.postAtFormat(postAt)}</li>`);
    }

    if (this.subreddit.options.postgame && this.subreddit.options.postgame.enabled) {
      listItems.push('<li>Postgame Threads</li>');
    }

    this.fields.options.innerHTML = listItems.join('');
  }

  refreshTemplates() {
    const listItems = this.subreddit.templates
      .map(template => new Template(template))
      .map(template => `<li>${BaseballBot.linkTo(template.type.titleize(), template.path())}</li>`);

    this.fields.templates.innerHTML = listItems.join('');
  }
}

BaseballBot.start(new ShowSubreddit(document.body));
