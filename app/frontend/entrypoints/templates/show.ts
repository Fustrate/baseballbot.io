import { GenericPage } from '@fustrate/rails';
import hljs from 'highlight.js/lib/core';
import erb from 'highlight.js/lib/languages/erb';

import BaseballBot from 'js/baseballbot';
import Template from 'models/template';

hljs.registerLanguage('erb', erb);

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

  public override refresh(): void {
    this.refreshBody();
  }

  protected refreshBody(): void {
    this.fields.body.textContent = this.template.body;

    hljs.highlightElement(this.fields.body);
  }
}

BaseballBot.start(ShowTemplate);
