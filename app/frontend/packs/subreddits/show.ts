import GenericPage from '@fustrate/rails/dist/js/GenericPage';
import { startCase } from 'lodash/string';
import { linkTo } from '@fustrate/rails/dist/js/utilities';

import BaseballBot from 'js/baseballbot';
import Subreddit from 'models/subreddit';
import Template from 'models/template';

class ShowSubreddit extends GenericPage {
  public subreddit: Subreddit;

  public async initialize(): Promise<void> {
    super.initialize();

    this.subreddit = Subreddit.build({ id: document.body.dataset.subreddit });

    await this.subreddit.reload();

    this.refresh();
  }

  public refresh(): void {
    this.refreshSettings();
    this.refreshTemplates();
  }

  protected refreshSettings(): void {
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

  protected refreshTemplates(): void {
    const listItems = Template.buildList(this.subreddit.templates)
      .map(template => `<li>${linkTo(startCase(template.type), template.path())}</li>`);

    this.fields.templates.innerHTML = listItems.join('');
  }
}

BaseballBot.start(ShowSubreddit);
