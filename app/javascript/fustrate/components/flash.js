import Component from '../component'

let settings = {
  fadeInSpeed: 500,
  fadeOutSpeed: 2000,
  displayTime: 4000
}

class Flash extends Component {
  constructor(message, { type, icon } = {}) {
    super();

    if (icon) {
      message = `${Fustrate.class.icon(icon)} ${message}`;
    }

    let bar = $(`<div class="flash ${type != null ? type : 'info'}"></div>`)
      .html(message)
      .hide()
      .prependTo($('#flashes'))
      .fadeIn(settings.fadeInSpeed)
      .delay(settings.displayTime)
      .fadeOut(settings.fadeOutSpeed, function() {
        return bar.remove();
      });
  }
};

class Warning extends Flash {
  constructor(message, { icon } = {}) {
    super(message, { type: 'error', icon: icon });
  }
}

class Info extends Flash {
  constructor(message, { icon } = {}) {
    super(message, { type: 'info', icon: icon });
  }
}

class Success extends Flash {
  constructor(message, { icon } = {}) {
    super(message, { type: 'success', icon: icon });
  }
}

export {
  Flash,
  Success,
  Warning,
  Info
}
