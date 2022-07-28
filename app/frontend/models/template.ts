import { Record } from '@fustrate/rails';

import { templatePath } from 'js/routes';

export type Types = 'game_thread' | 'game_thread_update' | 'no_hitter' | 'no_hitter_update' | 'off_day' | 'postgame'
| 'pregame' | 'sidebar';

export interface JSONData {
  body: string;
  id: number;
  type: Types;
}

export default class Template extends Record {
  public static override classname: 'Template';

  public body: string;
  public type: Types;

  public override path(options?: { [s: string]: any }): string {
    return templatePath(this.id, options);
  }
}
