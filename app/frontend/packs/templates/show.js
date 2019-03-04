import { GenericPage } from '@fustrate/rails';
import hljs from 'highlight.js';
import erb from 'highlight.js/lib/languages/erb';

import BaseballBot from '../../javascript/baseballbot';
import Template from '../../javascript/baseballbot/template';

require('../../stylesheets/highlight_erb.css');

hljs.registerLanguage('erb', erb);

class ShowTemplate extends GenericPage {
  initialize() {
    super.initialize();

    this.template = new Template(this.root.dataset.template);

    this.template.reload().done(() => {
      this.refresh();
    });
  }

  refreshBody() {
    this.fields.body.textContent = this.template.body;

    hljs.highlightBlock(this.fields.body);
  }
}

BaseballBot.start(new ShowTemplate(document.body));
