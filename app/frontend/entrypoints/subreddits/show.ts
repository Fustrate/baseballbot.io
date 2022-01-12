import { GenericPage } from '@fustrate/rails';
import startCase from 'lodash/startCase';
import { linkTo } from '@fustrate/rails/utilities';

import BaseballBot from 'js/baseballbot';
import Subreddit from 'models/subreddit';
import Template from 'models/template';

interface MethodDecoratorTarget {
  kind: 'method';
  key: string | symbol;
  placement: 'prototype';
}

type DecoratorFunction = (target: MethodDecoratorTarget, key: string, descriptor: PropertyDescriptor) => void;

function decorateMethod(tag: string): DecoratorFunction {
  return (target: MethodDecoratorTarget, key: string, descriptor: PropertyDescriptor) => {
    descriptor.value[tag] = true;
  };
}

function autorefresh(): any {
  return decorateMethod('$autorefresh');
}

class ShowSubreddit extends GenericPage {
  public subreddit: Subreddit;

  public override fields: {
    options: HTMLElement;
    templates: HTMLElement;
  };

  public override async initialize(): Promise<void> {
    super.initialize();

    this.subreddit = Subreddit.build({ id: document.body.dataset.subreddit });

    await this.subreddit.reload();

    this.refresh();
  }

  public override refresh(): void {
    this.callDecoratedMethods('$autorefresh');
  }

  @autorefresh()
  protected refreshSettings(): void {
    const listItems = [];

    if (this.subreddit.options.sidebar?.enabled) {
      listItems.push('<li>Hourly Sidebar Updates</li>');
    }

    if (this.subreddit.options.gameThreads?.enabled) {
      const { postAt } = this.subreddit.options.gameThreads;

      listItems.push(`<li>Game Threads ${Subreddit.postAtFormat(postAt)}</li>`);
    }

    if (this.subreddit.options.pregame?.enabled) {
      const { postAt } = this.subreddit.options.pregame;

      listItems.push(`<li>Pregame Threads ${Subreddit.postAtFormat(postAt)}</li>`);
    }

    if (this.subreddit.options.postgame?.enabled) {
      listItems.push('<li>Postgame Threads</li>');
    }

    this.fields.options.innerHTML = listItems.join('');
  }

  @autorefresh()
  protected refreshTemplates(): void {
    const listItems = Template.buildList(this.subreddit.templates)
      .map((template) => `<li>${linkTo(startCase(template.type), template.path())}</li>`);

    this.fields.templates.innerHTML = listItems.join('');
  }

  protected callDecoratedMethods(tag: string): void {
    const descriptors = Object.getOwnPropertyDescriptors(Object.getPrototypeOf(this));

    Object.entries(descriptors).forEach(([name, descriptor]) => {
      if (descriptor.value?.[tag]) {
        this[name]();
      }
    });
  }
}

BaseballBot.start(ShowSubreddit);
