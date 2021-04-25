import { Record } from '@fustrate/rails';

import { templatePath } from 'js/routes';

export default class Template extends Record {
  public static classname: 'Template';

  public id: number;
  public body: string;
  public type: string;

  public path(options?: { [s: string]: any }): string {
    return templatePath(this.id, options);
  }

  public extractFromData(data: { [s: string]: any }): { [s: string]: any } {
    super.extractFromData(data);

    this.id = data.id;
    this.body = data.body;
    this.type = data.type;

    return data;
  }
}
