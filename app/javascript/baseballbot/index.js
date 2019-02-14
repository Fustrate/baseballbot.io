import Fustrate from '../fustrate/fustrate'
import moment from 'moment-timezone'

class BaseballBot extends Fustrate {
  static start() {
    Fustrate.start('BaseballBot');
  }

  initialize() {
    super.initialize()

    moment.tz.setDefault(moment.tz.guess())
  }
}

window.BaseballBot = BaseballBot;

export default BaseballBot
