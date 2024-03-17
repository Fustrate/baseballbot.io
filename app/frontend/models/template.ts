import BaseRecord from '@fustrate/rails/record';

import { templatePath } from 'utilities/routes';

export type Types = 'game_thread' | 'game_thread_update' | 'no_hitter' | 'no_hitter_update' | 'off_day' | 'postgame'
| 'pregame' | 'sidebar';

export interface JSONData {
  body: string;
  id: number;
  type: Types;
}

export default class Template extends BaseRecord {
  public static override classname: 'Template';

  public body: string;
  public type: Types;

  public override path(options?: Record<string, any>): string {
    return templatePath(this.id, options);
  }
}
