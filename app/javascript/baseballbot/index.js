import moment from 'moment-timezone';

import Fustrate from '../fustrate/fustrate';

class BaseballBot extends Fustrate {
  initialize() {
    super.initialize();

    moment.tz.setDefault(moment.tz.guess());
  }
}

export default BaseballBot;
