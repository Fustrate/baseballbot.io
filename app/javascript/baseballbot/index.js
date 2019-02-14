import Fustrate from '../fustrate/fustrate'
import moment from 'moment-timezone'

class BaseballBot extends Fustrate {
  initialize() {
    super.initialize()

    moment.tz.setDefault(moment.tz.guess())
  }
}

window.BaseballBot = BaseballBot;

Fustrate.start('BaseballBot');

export default BaseballBot
