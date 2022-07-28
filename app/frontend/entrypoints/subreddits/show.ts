import GenericShow, { autorefresh } from 'components/generic_show';
import { linkTo, multilineEscapeHTML } from '@fustrate/rails/utilities';

import BaseballBot from 'js/baseballbot';
import Subreddit from 'models/subreddit';
import { postAtFormat } from 'js/utilities';

class ShowSubreddit extends GenericShow {
  public subreddit: Subreddit;

  public override fields: {
    gameThreadOptions: HTMLUListElement;
    generalOptions: HTMLUListElement;
    offDayOptions: HTMLUListElement;
    postgameOptions: HTMLUListElement;
    pregameOptions: HTMLUListElement;
    sidebarOptions: HTMLUListElement;
    templates: HTMLElement;
  };

  public override async initialize(): Promise<void> {
    super.initialize();

    this.subreddit = Subreddit.build({ id: document.body.dataset.subreddit });

    await this.subreddit.reload();

    this.refresh();
  }

  @autorefresh()
  protected refreshGeneralSettings(): void {
    const listItems = [
      `<dt>Time Zone</dt><dd>${this.subreddit.options.timezone}</dd>`,
    ];

    if (this.stickyAnyThreads) {
      listItems.push(`<dt>Sticky Slot</dt><dd>${this.subreddit.options.stickySlot || 1}</dd>`);
    }

    this.fields.generalOptions.innerHTML = listItems.join('');
  }

  @autorefresh()
  protected refreshGameThreadSettings(): void {
    const options = this.subreddit.options.gameThreads;

    const listItems = [
      `<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`,
    ];

    if (options?.enabled) {
      listItems.push(
        `<dt>Post At</dt><dd>${postAtFormat(options.postAt)}</dd>`,
        `<dt>Sticky</dt><dd>${options.sticky !== false ? 'Yes' : 'No'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${multilineEscapeHTML(options.stickyComment)}</dd>`);
      }

      const template = this.subreddit.templates.find((temp) => temp.type === 'game_thread');

      listItems.push(
        `<dt>Template</dt><dd>${template ? linkTo('Game Thread Template', template.path()) : 'Template Missing'}</dd>`,
      );

      const update = this.subreddit.templates.find((temp) => temp.type === 'game_thread_update');

      listItems.push(`
        <dt>Update Template</dt>
        <dd>${update ? linkTo('Game Thread Update Template', update.path()) : 'Template Missing'}</dd>`);
    }

    this.fields.gameThreadOptions.innerHTML = listItems.join('');
  }

  @autorefresh()
  protected refreshPregameSettings(): void {
    const options = this.subreddit.options.pregame;

    const listItems = [
      `<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`,
    ];

    if (options?.enabled) {
      listItems.push(
        `<dt>Post At</dt><dd>${postAtFormat(options.postAt)}</dd>`,
        `<dt>Sticky</dt><dd>${options.sticky !== false ? 'Yes' : 'No'}</dd>`,
      );

      const template = this.subreddit.templates.find((temp) => temp.type === 'pregame');

      listItems.push(
        `<dt>Template</dt><dd>${template ? linkTo('Pregame Template', template.path()) : 'Template Missing'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${multilineEscapeHTML(options.stickyComment)}</dd>`);
      }
    }

    this.fields.pregameOptions.innerHTML = listItems.join('');
  }

  @autorefresh()
  protected refreshPostgameSettings(): void {
    const options = this.subreddit.options.postgame;

    const listItems = [
      `<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`,
    ];

    if (options?.enabled) {
      const template = this.subreddit.templates.find((temp) => temp.type === 'postgame');

      listItems.push(
        `<dt>Sticky</dt><dd>${options.sticky !== false ? 'Yes' : 'No'}</dd>`,
        `<dt>Template</dt><dd>${template ? linkTo('Postgame Template', template.path()) : 'Template Missing'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${multilineEscapeHTML(options.stickyComment)}</dd>`);
      }
    }

    this.fields.postgameOptions.innerHTML = listItems.join('');
  }

  @autorefresh()
  protected refreshOffDaySettings(): void {
    const options = this.subreddit.options.offDay;

    const listItems = [
      `<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`,
    ];

    if (options?.enabled) {
      const template = this.subreddit.templates.find((temp) => temp.type === 'off_day');

      listItems.push(
        `<dt>Sticky</dt><dd>${options.sticky !== false ? 'Yes' : 'No'}</dd>`,
        `<dt>Template</dt><dd>${template ? linkTo('Off Day Template', template.path()) : 'Template Missing'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${multilineEscapeHTML(options.stickyComment)}</dd>`);
      }
    }

    this.fields.offDayOptions.innerHTML = listItems.join('');
  }

  @autorefresh()
  protected refreshSidebarSettings(): void {
    const options = this.subreddit.options.sidebar;

    const listItems = [
      `<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`,
    ];

    if (options?.enabled) {
      const template = this.subreddit.templates.find((temp) => temp.type === 'sidebar');

      listItems.push(
        `<dt>Template</dt><dd>${template ? linkTo('Sidebar Template', template.path()) : 'Template Missing'}</dd>`,
      );
    }

    this.fields.sidebarOptions.innerHTML = listItems.join('');
  }

  protected get stickyAnyThreads(): boolean {
    return (this.subreddit.options.gameThreads?.enabled && this.subreddit.options.gameThreads.sticky !== false)
      || (this.subreddit.options.pregame?.enabled && this.subreddit.options.pregame.sticky !== false)
      || (this.subreddit.options.postgame?.enabled && this.subreddit.options.postgame.sticky !== false)
      || (this.subreddit.options.offDay?.enabled && this.subreddit.options.offDay.sticky !== false);
  }
}

BaseballBot.start(ShowSubreddit);
