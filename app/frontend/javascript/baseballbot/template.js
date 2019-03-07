import { Record } from '@fustrate/rails';
import { templatePath, templatesPath } from '../routes';

class Template extends Record {
  static get createPath() { return templatesPath; }

  static get class() { return 'Template'; }

  path({ format } = {}) {
    return templatePath(this.id, { format });
  }
}

export default Template;
