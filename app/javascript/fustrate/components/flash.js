import $ from 'jquery';

import Fustrate from '..';
import Component from '../component';

const settings = {
  fadeInSpeed: 500,
  fadeOutSpeed: 2000,
  displayTime: 4000,
};

class Flash extends Component {
  constructor(message, { type, icon } = {}) {
    super();

    const bar = $(`<div class="flash ${type != null ? type : 'info'}"></div>`)
      .html(icon ? `${Fustrate.class.icon(icon)} ${message}` : message)
      .hide()
      .prependTo($('#flashes'))
      .fadeIn(settings.fadeInSpeed)
      .delay(settings.displayTime)
      .fadeOut(settings.fadeOutSpeed, () => bar.remove());
  }

  static initialize() {
    const flashes = document.createElement('div');
    flashes.id = 'flashes';
    document.body.appendChild(flashes);
  }
}

class Warning extends Flash {
  constructor(message, { icon } = {}) {
    super(message, { type: 'error', icon });
  }
}

class Info extends Flash {
  constructor(message, { icon } = {}) {
    super(message, { type: 'info', icon });
  }
}

class Success extends Flash {
  constructor(message, { icon } = {}) {
    super(message, { type: 'success', icon });
  }
}

Component.register(Flash);

export {
  Flash,
  Success,
  Warning,
  Info,
};
