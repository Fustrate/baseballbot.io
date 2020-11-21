import GenericPage from '@fustrate/rails/dist/js/GenericPage';
import hljs from 'highlight.js';
import erb from 'highlight.js/lib/languages/erb';

import BaseballBot from 'js/baseballbot';
import Template from 'models/template';

hljs.registerLanguage('erb', erb);

class ShowTemplate extends GenericPage {
  public template: Template;

  public async initialize(): Promise<void> {
    super.initialize();

    this.template = new Template(document.body.dataset.template);

    await this.template.reload();

    this.refresh();
  }

  public refresh(): void {
    this.refreshBody();
  }

  protected refreshBody(): void {
    this.fields.body.textContent = this.template.body;

    hljs.highlightBlock(this.fields.body);
  }
}

BaseballBot.start(ShowTemplate);
