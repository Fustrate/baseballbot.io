import { JsonData } from '@fustrate/rails/dist/js/BasicObject';
import { Record } from '@fustrate/rails/dist/js/Record';
import { templatePath, templatesPath } from '../routes';

export default class Template extends Record {
  public static classname: 'Template';

  public id: number;
  public type: string;
  public body: string;

  public static createPath(parameters: { format?: string } = {}): string {
    return templatesPath(parameters);
  }

  path(parameters: { format?: string } = {}) {
    return templatePath(this.id, parameters);
  }

  public extractFromData(data?: JsonData): JsonData {
    if (!data) {
      return {};
    }

    this.id = data.id;

    return data;
  }
}
