import { Record } from '@fustrate/rails';
import Routes from './routes.js.erb';

class Template extends Record {
  static get createPath() { return Routes.templates_path; }

  static get class() { return 'Template'; }

  path({ format } = {}) {
    return Routes.template_path(this.id, { format });
  }
}

export default Template;
