import { start } from '@fustrate/rails';
import { escapeMultilineHTML } from '@fustrate/rails/html';
import { linkTo } from '@fustrate/rails/utilities';

import GenericShow, { refresh } from 'components/generic-show';

import { postAtFormat } from 'js/utilities';
import Subreddit from 'models/subreddit';

function stickyPosts(config: { enabled: boolean; sticky?: boolean } | undefined): boolean {
  return config != null && config.enabled !== false && config.sticky !== false;
}

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
    await super.initialize();

    this.subreddit = Subreddit.build({ id: document.body.dataset.subreddit }) as Subreddit;

    await this.subreddit.reload();

    this.refresh();
  }

  @refresh
  protected refreshGeneralSettings(): void {
    const listItems = [`<dt>Time Zone</dt><dd>${this.subreddit.options.timezone}</dd>`];

    if (this.stickyAnyThreads) {
      listItems.push(`<dt>Sticky Slot</dt><dd>${this.subreddit.options.stickySlot ?? 1}</dd>`);
    }

    this.fields.generalOptions.innerHTML = listItems.join('');
  }

  @refresh
  protected refreshGameThreadSettings(): void {
    const options = this.subreddit.options.gameThreads;

    const listItems = [`<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`];

    if (options?.enabled) {
      listItems.push(
        `<dt>Post At</dt><dd>${postAtFormat(options.postAt)}</dd>`,
        `<dt>Sticky</dt><dd>${options.sticky === false ? 'No' : 'Yes'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${escapeMultilineHTML(options.stickyComment)}</dd>`);
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

  @refresh
  protected refreshPregameSettings(): void {
    const options = this.subreddit.options.pregame;

    const listItems = [`<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`];

    if (options?.enabled) {
      listItems.push(
        `<dt>Post At</dt><dd>${postAtFormat(options.postAt)}</dd>`,
        `<dt>Sticky</dt><dd>${options.sticky === false ? 'No' : 'Yes'}</dd>`,
      );

      const template = this.subreddit.templates.find((temp) => temp.type === 'pregame');

      listItems.push(
        `<dt>Template</dt><dd>${template ? linkTo('Pregame Template', template.path()) : 'Template Missing'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${escapeMultilineHTML(options.stickyComment)}</dd>`);
      }
    }

    this.fields.pregameOptions.innerHTML = listItems.join('');
  }

  @refresh
  protected refreshPostgameSettings(): void {
    const options = this.subreddit.options.postgame;

    const listItems = [`<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`];

    if (options?.enabled) {
      const template = this.subreddit.templates.find((temp) => temp.type === 'postgame');

      listItems.push(
        `<dt>Sticky</dt><dd>${options.sticky === false ? 'No' : 'Yes'}</dd>`,
        `<dt>Template</dt><dd>${template ? linkTo('Postgame Template', template.path()) : 'Template Missing'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${escapeMultilineHTML(options.stickyComment)}</dd>`);
      }
    }

    this.fields.postgameOptions.innerHTML = listItems.join('');
  }

  @refresh
  protected refreshOffDaySettings(): void {
    const options = this.subreddit.options.offDay;

    const listItems = [`<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`];

    if (options?.enabled) {
      const template = this.subreddit.templates.find((temp) => temp.type === 'off_day');

      listItems.push(
        `<dt>Sticky</dt><dd>${options.sticky === false ? 'No' : 'Yes'}</dd>`,
        `<dt>Template</dt><dd>${template ? linkTo('Off Day Template', template.path()) : 'Template Missing'}</dd>`,
      );

      if (options.stickyComment) {
        listItems.push(`<dt>Sticky Comment</dt><dd>${escapeMultilineHTML(options.stickyComment)}</dd>`);
      }
    }

    this.fields.offDayOptions.innerHTML = listItems.join('');
  }

  @refresh
  protected refreshSidebarSettings(): void {
    const options = this.subreddit.options.sidebar;

    const listItems = [`<dt>Enabled</dt><dd>${options?.enabled ? 'Yes' : 'No'}`];

    if (options?.enabled) {
      const template = this.subreddit.templates.find((temp) => temp.type === 'sidebar');

      listItems.push(
        `<dt>Template</dt><dd>${template ? linkTo('Sidebar Template', template.path()) : 'Template Missing'}</dd>`,
      );
    }

    this.fields.sidebarOptions.innerHTML = listItems.join('');
  }

  protected get stickyAnyThreads(): boolean {
    return (
      stickyPosts(this.subreddit.options.gameThreads) ||
      stickyPosts(this.subreddit.options.pregame) ||
      stickyPosts(this.subreddit.options.postgame) ||
      stickyPosts(this.subreddit.options.offDay)
    );
  }
}

start(new ShowSubreddit());
