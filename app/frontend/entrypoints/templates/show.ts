import GenericPage, { refresh } from '@fustrate/rails/generic_page';

import hljs from 'highlight.js/lib/core';
import handlebars from 'highlight.js/lib/languages/handlebars';

import BaseballBot from 'js/baseballbot';
import Template from 'models/template';

hljs.registerLanguage('handlebars', handlebars);

class ShowTemplate extends GenericPage {
  public template: Template;

  public override fields: {
    body: HTMLElement;
  };

  public override async initialize(): Promise<void> {
    super.initialize();

    this.template = new Template(document.body.dataset.template);

    await this.template.reload();

    this.refresh();
  }

  @refresh
  protected refreshBody(): void {
    this.fields.body.textContent = this.template.body;

    hljs.highlightElement(this.fields.body);
  }
}

BaseballBot.start(ShowTemplate);
