import BaseballBot from '../../baseballbot';
import GenericPage from '../../fustrate/generic_page';
import Subreddit from '../../baseballbot/subreddit';
import Template from '../../baseballbot/template';

class ShowSubreddit extends GenericPage {
  initialize() {
    this.subreddit = new Subreddit(this.root.dataset.subreddit);

    this.subreddit.reload().done(() => {
      this.refresh();
    });
  }

  refresh() {
    this.refreshSettings();
    this.refreshTemplates();
  }

  refreshSettings() {
    const listItems = [];

    if (this.subreddit.options.sidebar && this.subreddit.options.sidebar.enabled) {
      listItems.push('<li>Hourly Sidebar Updates</li>');
    }

    if (this.subreddit.options.game_threads && this.subreddit.options.game_threads.enabled) {
      const postAt = this.subreddit.options.game_threads.post_at;

      listItems.push(`<li>Game Threads ${this.constructor.postAtFormat(postAt)}</li>`);
    }

    if (this.subreddit.options.pregame && this.subreddit.options.pregame.enabled) {
      const postAt = this.subreddit.options.pregame.post_at;

      listItems.push(`<li>Pregame Threads ${this.constructor.postAtFormat(postAt)}</li>`);
    }

    if (this.subreddit.options.postgame && this.subreddit.options.postgame.enabled) {
      listItems.push('<li>Postgame Threads</li>');
    }

    this.fields.options.empty().append(listItems);
  }

  refreshTemplates() {
    const listItems = this.subreddit.templates
      .map(template => new Template(template))
      .map(template => `<li>${BaseballBot.linkTo(template.type.titleize(), template.path())}</li>`);

    this.fields.templates.empty().append(listItems);
  }

  static postAtFormat(postAt) {
    if (!postAt) {
      return '3 Hours Pregame';
    }

    if (/^-?\d{1,2}$/.test(postAt)) {
      return `${Math.abs(parseInt(postAt, 10))} Hours Pregame`;
    }

    if (/(1[012]|\d)(:\d\d|) ?(am|pm)/i.test(postAt)) {
      return `at ${postAt}`;
    }

    // Bad format, default back to 3 hours pregame
    return '3 Hours Pregame';
  }
}

BaseballBot.start(new ShowSubreddit(document.body));
